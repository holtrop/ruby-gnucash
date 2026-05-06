require "date"
require "zlib"
require "nokogiri"

module Gnucash
  # Represent a GnuCash Book.
  class Book
    include Support::LightInspect

    # One row from +gnc:pricedb+.
    #
    # @since 1.6.0
    PriceRow = Struct.new(:commodity_space, :commodity_id, :currency_space, :currency_id, :date, :value)

    # @return [Array<Account>] Accounts in the book.
    attr_reader :accounts

    # @return [Array<Account>] Customers in the book.
    # @since 1.6.0
    attr_reader :customers

    # @return [Array<Transaction>] Transactions in the book.
    attr_reader :transactions

    # @return [Array<PriceRow>]
    #   Raw price-database rows (commodity/currency/value/date). Prefer
    #   {Security#value_on} for valuations.
    # @since 1.6.0
    attr_reader :price_rows

    # @return [Date] Date of the first transaction in the book.
    attr_reader :start_date

    # @return [Date] Date of the last transaction in the book.
    attr_reader :end_date

    # Construct a Book object.
    #
    # Normally called internally by {Gnucash.open}.
    #
    # @param fname [String]
    #   The file name of the GnuCash file to open. Only XML format (or gzipped
    #   XML format) GnuCash data files are recognized.
    def initialize(fname)
      begin
        @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
      rescue Zlib::GzipFile::Error
        @ng = Nokogiri.XML(File.read(fname))
      end
      book_nodes = @ng.xpath('/gnc-v2/gnc:book')
      if book_nodes.count != 1
        raise "Error: Expected to find one gnc:book entry"
      end
      @book_node = book_nodes.first
      build_customers
      build_accounts
      build_transactions
      build_price_quotes
      build_commodity_isin_index
      finalize
    end

    # Return a handle to the Account object that has the given GUID.
    #
    # @param id [String] GUID.
    #
    # @return [Account, nil] Account object, or nil if not found.
    def find_account_by_id(id)
      @accounts.find { |a| a.id == id }
    end

    # Return a handle to the Account object that has the given fully-qualified
    # name.
    #
    # @param full_name [String]
    #   Fully-qualified account name (ex: "Expenses::Auto::Gas").
    #
    # @return [Account, nil] Account object, or nil if not found.
    def find_account_by_full_name(full_name)
      @accounts.find { |a| a.full_name == full_name }
    end

    # Return a handle to the Customer object that has the given fully-qualified
    # name.
    #
    # @since 1.6.0
    #
    # @param full_name [String]
    #   Fully-qualified customer name (ex: "Joe Doe").
    #
    # @return [Customer, nil] Customer object, or nil if not found.
    def find_customer_by_full_name(full_name)
      @customers.find { |a| a.full_name == full_name }
    end

    # Return every {Security} that appears in the price database (unique commodity).
    #
    # @since 1.6.0
    #
    # @return [Array<Security>]
    def securities
      @securities ||= @price_rows.map { |r| [r.commodity_space, r.commodity_id] }.uniq.map do |space, id|
        Security.new(self, space, id)
      end
    end

    # Look up a security by GnuCash commodity +space+ and +id+.
    #
    # @since 1.6.0
    #
    # @return [Security, nil]
    def find_security(space, id)
      return nil unless @price_rows.any? { |r| r.commodity_space == space && r.commodity_id == id }
      Security.new(self, space, id)
    end

    # Look up a priced security whose commodity defines this ISIN (+cmdty:xcode+ or a slot
    # whose key matches +isin+, e.g. +user:ISIN+). Comparison ignores spaces, hyphens and case.
    #
    # @since 1.6.0
    #
    # @param isin [String] ISIN as stored or typed (e.g. +"US0378331005"+).
    #
    # @return [Security, nil]
    def find_security_by_isin(isin)
      key = ISIN.normalize(isin)
      return nil if key.empty?

      pair = @isin_index[key]
      return nil unless pair

      find_security(pair[0], pair[1])
    end

    # ISIN for a commodity if present in the book (+nil+ otherwise).
    #
    # @since 1.6.0
    #
    # @return [String, nil] Normalized ISIN (12 uppercase alphanumeric characters).
    def isin_for_commodity(space, id)
      @isin_for_commodity[[space, id]]
    end

    # Price-database rows for one commodity (used by {Security#value_on}).
    #
    # @since 1.6.0
    #
    # @return [Array<PriceRow>]
    def quotes_for_commodity(space, id)
      @price_rows.select { |r| r.commodity_space == space && r.commodity_id == id }
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[start_date end_date]
    end

    private

    # @return [void]
    def build_accounts
      @accounts = @book_node.xpath('gnc:account').map do |act_node|
        Account.new(self, act_node)
      end
    end

    def build_customers
      @customers = @book_node.xpath('gnc:GncCustomer').map do |customer_node|
        Customer.new(self, customer_node)
      end
    end

    # @return [void]
    def build_transactions
      @start_date = nil
      @end_date = nil
      @transactions = @book_node.xpath('gnc:transaction').map do |txn_node|
        Transaction.new(self, txn_node).tap do |txn|
          @start_date = txn.date if @start_date.nil? or txn.date < @start_date
          @end_date = txn.date if @end_date.nil? or txn.date > @end_date
        end
      end
    end

    # @return [void]
    def build_price_quotes
      pricedb = @book_node.at_xpath('gnc:pricedb')
      @price_rows = []
      return unless pricedb

      pricedb.element_children.each do |node|
        next unless node.element?
        row = parse_price_node(node)
        @price_rows << row if row
      end
    end

    # @return [PriceRow, nil]
    def parse_price_node(node)
      return nil unless node.at_xpath('price:commodity')

      cmd = node.at_xpath('price:commodity')
      cur = node.at_xpath('price:currency')
      return nil unless cmd && cur

      commodity_space = cmd.at_xpath('cmdty:space')&.text
      commodity_id = cmd.at_xpath('cmdty:id')&.text
      currency_space = cur.at_xpath('cmdty:space')&.text
      currency_id = cur.at_xpath('cmdty:id')&.text
      return nil if [commodity_space, commodity_id, currency_space, currency_id].any? { |s| s.nil? || s.empty? }

      ts = node.at_xpath('price:time/ts:date')&.text
      return nil if ts.nil? || ts.empty?

      date = Date.parse(ts.split(' ').first)
      val_text = node.at_xpath('price:value')&.text
      return nil if val_text.nil? || val_text.empty?

      PriceRow.new(commodity_space, commodity_id, currency_space, currency_id, date, Value.new(val_text))
    end

    # @return [void]
    def build_commodity_isin_index
      @isin_for_commodity = {}
      @isin_index = {}

      @book_node.xpath("gnc:commodity").each do |node|
        space = node.at_xpath("cmdty:space")&.text&.strip
        id = node.at_xpath("cmdty:id")&.text&.strip
        next if space.nil? || id.nil? || space.empty? || id.empty?

        raw = extract_isin_from_commodity_node(node)
        next unless raw

        key = ISIN.normalize(raw)
        next unless ISIN.valid_format?(key)

        @isin_for_commodity[[space, id]] = key
        @isin_index[key] ||= [space, id]
      end
    end

    # @return [String, nil] raw ISIN string from XML before normalization
    def extract_isin_from_commodity_node(node)
      node.xpath(".//slot").each do |slot|
        k = slot.at_xpath("slot:key")&.text
        next unless k&.match?(/isin/i)

        v = slot.at_xpath("slot:value")&.text&.strip
        next if v.nil? || v.empty?

        return v if ISIN.valid_format?(v)
      end

      xcode = node.at_xpath("cmdty:xcode")&.text&.strip
      return xcode if xcode && ISIN.valid_format?(xcode)

      nil
    end

    # @return [void]
    def finalize
      @accounts.sort! do |a, b|
        a.full_name <=> b.full_name
      end
      @accounts.each do |account|
        account.finalize
      end
    end
  end
end

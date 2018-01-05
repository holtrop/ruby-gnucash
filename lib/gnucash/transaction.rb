require "date"

module Gnucash
  # Represent a GnuCash transaction.
  #
  # Transactions have multiple splits with individual values.
  # Splits are created as AccountTransaction objects which are associated
  # with an individual account.
  class Transaction
    include Support::LightInspect

    # @return [Date] The date of the transaction.
    attr_reader :date

    # @return [String] The GUID of the transaction.
    attr_reader :id

    # @return [String] The description of the transaction.
    attr_reader :description

    # @return [Array<Hash>] Hashes with keys +:account+ and +:value+.
    attr_reader :splits

    # Create a new Transaction object.
    #
    # @param book [Book] The {Gnucash::Book} containing the transaction.
    # @param node [Nokogiri::XML::Node] Nokogiri XML node.
    def initialize(book, node)
      @book = book
      @node = node
      @id = node.xpath('trn:id').text
      @date = Date.parse(node.xpath('trn:date-posted/ts:date').text.split(' ').first)
      @description = node.xpath('trn:description').text
      @splits = node.xpath('trn:splits/trn:split').map do |split_node|
        # Note: split:value represents the split value in the transaction's
        # currency while split:quantity represents it in the currency
        # associated with the account associated with this split.
        value = Value.new(split_node.xpath('split:quantity').text)
        account_id = split_node.xpath('split:account').text
        account = @book.find_account_by_id(account_id)
        unless account
          raise "Could not find account with ID #{account_id} for transaction #{@id}"
        end
        account.add_transaction(AccountTransaction.new(self, value))
        {
          account: account,
          value: value,
        }
      end
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[id date description splits]
    end
  end
end

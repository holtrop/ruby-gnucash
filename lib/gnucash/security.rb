require "date"

module Gnucash
  # Price quote for a security (commodity) from the GnuCash price database: the
  # value of one unit of the security expressed in +currency+ as of +date+.
  #
  # @since 1.6.0
  class SecurityQuote
    include Support::LightInspect

    # @return [Value] Price of one unit of the security in the quote currency.
    attr_reader :value

    # @return [String] Commodity namespace (GnuCash "space") of the quote currency.
    attr_reader :currency_space

    # @return [String] Commodity id of the quote currency (e.g. +"USD"+).
    attr_reader :currency_id

    # @return [Date] Date of the price in the book (quote time, date-only).
    attr_reader :date

    def initialize(value:, currency_space:, currency_id:, date:)
      @value = value
      @currency_space = currency_space
      @currency_id = currency_id
      @date = date
    end

    def attributes
      %i[value currency_space currency_id date]
    end
  end

  # A security (stock, fund, etc.) identified by its GnuCash commodity
  # +space+ and +id+, with prices loaded from the book's price database.
  #
  # @since 1.6.0
  class Security
    include Support::LightInspect

    # @return [String] Commodity namespace (e.g. +"NASDAQ"+, +"ISO4217"+).
    attr_reader :space

    # @return [String] Commodity id (e.g. ticker or currency code).
    attr_reader :id

    # @param book [Book] Parent book.
    # @param space [String] Commodity space.
    # @param id [String] Commodity id.
    def initialize(book, space, id)
      @book = book
      @space = space
      @id = id
    end

    # @return [String, nil] ISIN from the commodity definition (+cmdty:xcode+ or ISIN slot), normalized.
    def isin
      @book.isin_for_commodity(@space, @id)
    end

    # Return the most recent price quote whose date is on or before the given
    # valuation date.
    #
    # If the security has multiple quote currencies, +currency_space+ and
    # +currency_id+ select one; if omitted, USD (+ISO4217+ / +USD+) is preferred
    # when present, otherwise an arbitrary quote chain is used.
    #
    # @param date [String, Date] Valuation date.
    # @param currency_space [String, nil] Restrict to this quote currency space.
    # @param currency_id [String, nil] Restrict to this quote currency id.
    #
    # @return [SecurityQuote, nil] Quote used for valuation, or nil if none applies.
    def value_on(date, currency_space: nil, currency_id: nil)
      date = Date.parse(date) if date.is_a?(String)
      if (currency_space.nil? ^ currency_id.nil?)
        raise ArgumentError, "currency_space and currency_id must both be set or both omitted"
      end

      quotes = @book.quotes_for_commodity(@space, @id)
      return nil if quotes.empty?

      filtered =
        if currency_space
          quotes.select { |q| q.currency_space == currency_space && q.currency_id == currency_id }
        else
          quotes
        end
      return nil if filtered.empty?

      pick_currency = lambda do |list|
        usd = list.select { |q| q.currency_space == "ISO4217" && q.currency_id == "USD" }
        (usd.empty? ? list : usd)
      end

      candidates = currency_space ? filtered : pick_currency.call(filtered)
      return nil if candidates.empty?

      candidates = candidates.select { |q| q.date <= date }
      return nil if candidates.empty?

      best = candidates.max_by(&:date)

      SecurityQuote.new(
        value: best.value,
        currency_space: best.currency_space,
        currency_id: best.currency_id,
        date: best.date
      )
    end

    def attributes
      %i[space id isin]
    end
  end
end

module Gnucash
  # Helpers for ISIN (ISO 6166) strings as stored on GnuCash commodities.
  #
  # @since 1.6.0
  module ISIN
    module_function

    # @param str [String, nil]
    # @return [String] Uppercase ISIN with spaces and hyphens removed.
    def normalize(str)
      return "" if str.nil? || str.to_s.empty?
      str.to_s.gsub(/[\s-]/, "").upcase
    end

    # Rough format check: 12 alphanumeric characters after normalization.
    #
    # @param str [String, nil]
    # @return [Boolean]
    def valid_format?(str)
      s = normalize(str)
      return false if s.length != 12
      s.match?(/\A[A-Z0-9]{12}\z/)
    end
  end
end

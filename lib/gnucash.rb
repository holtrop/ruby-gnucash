require_relative "gnucash/account"
require_relative "gnucash/account_transaction"
require_relative "gnucash/book"
require_relative "gnucash/transaction"
require_relative "gnucash/value"
require_relative "gnucash/version"

# Namespace module for gnucash gem functionality.
module Gnucash
  # Open a GnuCash book from file.
  #
  # The file can be either a plain-text XML file or a gzipped XML file.
  #
  # @param fname [String] Name of the file to open.
  def self.open(fname)
    Book.new(fname)
  end
end

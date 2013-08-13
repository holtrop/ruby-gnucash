require "gnucash/account"
require "gnucash/account_transaction"
require "gnucash/book"
require "gnucash/transaction"
require "gnucash/value"
require "gnucash/version"

# Namespace module for gnucash gem functionality
module Gnucash
  # Open a GnuCash book from file.
  # The file can be either a plain-text XML file or a gzipped XML file.
  # === Arguments
  # +fname+ _String_:: Name of the file to open.
  def self.open(fname)
    Book.new(fname)
  end
end

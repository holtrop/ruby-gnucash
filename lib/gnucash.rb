require "gnucash/account"
require "gnucash/book"
require "gnucash/transaction"
require "gnucash/value"
require "gnucash/version"

module Gnucash
  def self.open(fname)
    Book.new(fname)
  end
end

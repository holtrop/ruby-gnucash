require "gnucash/book"
require "gnucash/version"

module Gnucash
  def self.open(fname)
    Book.new(fname)
  end
end

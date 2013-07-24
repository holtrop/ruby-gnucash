require "gnucash/ledger"
require "gnucash/version"

module Gnucash
  def self.open(fname)
    Ledger.new(fname)
  end
end

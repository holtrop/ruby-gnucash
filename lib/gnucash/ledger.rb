require "zlib"
require "nokogiri"

module Gnucash
  class Ledger
    def initialize(fname)
      @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
    end
  end
end

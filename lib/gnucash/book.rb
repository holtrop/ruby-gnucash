require "zlib"
require "nokogiri"

module Gnucash
  class Book
    def initialize(fname)
      @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
    end
  end
end

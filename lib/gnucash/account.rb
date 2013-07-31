module Gnucash
  class Account
    def initialize(book, node)
      @node = node
      @name = node.xpath('act:name').text
      @type = node.xpath('act:type').text
    end
  end
end

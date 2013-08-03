module Gnucash
  class Transaction
    attr_accessor :value
    attr_accessor :id

    def initialize(book, node)
      @book = book
      @node = node
      @id = node.xpath('trn:id').text
      @date = node.xpath('trn:date-posted/ts:date').text.split(' ').first
      @splits = node.xpath('trn:splits/trn:split').map do |split_node|
        value_str = split_node.xpath('split:value').text
        value_parts = value_str.split('/')
        unless value_parts.size == 2 and value_parts[1] == '100'
          raise "Unexpected value format: #{value_str.inspect}"
        end
        {
          account_id: split_node.xpath('split:account').text,
          value: value_parts.first.to_i,
        }
      end
      @splits.each do |split|
        account = @book.find_account_by_id(split[:account_id])
        raise "Could not find account with ID #{split[:account_id]} for transaction #{@id}" unless account
        account.add_transaction(self, split[:value])
      end
    end
  end
end

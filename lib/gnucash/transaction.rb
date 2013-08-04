module Gnucash
  class Transaction
    attr_accessor :date
    attr_accessor :value
    attr_accessor :id

    def initialize(book, node)
      @book = book
      @node = node
      @id = node.xpath('trn:id').text
      @date = node.xpath('trn:date-posted/ts:date').text.split(' ').first
      @splits = node.xpath('trn:splits/trn:split').map do |split_node|
        value = Value.new(split_node.xpath('split:value').text)
        account_id = split_node.xpath('split:account').text
        account = @book.find_account_by_id(account_id)
        unless account
          raise "Could not find account with ID #{account_id} for transaction #{@id}"
        end
        account.add_transaction(self, value)
        {
          account_id: account_id,
          value: value,
        }
      end
    end
  end
end

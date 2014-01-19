module Gnucash
  # Represent a GnuCash transaction.
  # Transactions have multiple splits with individual values.
  # Splits are created as AccountTransaction objects which are associated
  # with an individual account.
  class Transaction
    # _Date_: The date of the transaction
    attr_reader :date

    # _String_: The GUID of the transaction
    attr_reader :id

    # _String_: The description of the transaction
    attr_reader :description

    # _Array_ of _Hash_ with keys +account+ and +value+
    attr_reader :splits

    # Create a new Transaction object
    # === Arguments
    # +book+ _Book_:: The Gnucash::Book containing the transaction
    # +node+ _Nokogiri::XML::Node_:: Nokogiri XML node
    def initialize(book, node)
      @book = book
      @node = node
      @id = node.xpath('trn:id').text
      @date = Date.parse(node.xpath('trn:date-posted/ts:date').text.split(' ').first)
      @description = node.xpath('trn:description').text
      @splits = node.xpath('trn:splits/trn:split').map do |split_node|
        value = Value.new(split_node.xpath('split:value').text)
        account_id = split_node.xpath('split:account').text
        account = @book.find_account_by_id(account_id)
        unless account
          raise "Could not find account with ID #{account_id} for transaction #{@id}"
        end
        account.add_transaction(AccountTransaction.new(self, value))
        {
          account: account,
          value: value,
        }
      end
    end
  end
end

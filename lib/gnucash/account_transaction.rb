module Gnucash
  class AccountTransaction
    attr_accessor :value

    def initialize(real_txn, value)
      @real_txn = real_txn
      @value = value
    end

    def method_missing(*args)
      @real_txn.send(*args)
    end
  end
end

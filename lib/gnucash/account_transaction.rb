module Gnucash
  # Class to link a transaction object to an Account.
  class AccountTransaction
    # _Gnucash::Value_: The transaction value for the linked account
    attr_accessor :value

    # Construct an AccountTransaction object.
    # This method is used internally when building a Transaction object.
    # === Arguments
    # +real_txn+ _Gnucash::Transaction_:: The linked Transaction object
    # +value+ _Gnucash::Value_::
    #   The value of the Transaction split for this account
    def initialize(real_txn, value)
      @real_txn = real_txn
      @value = value
    end

    # Pass through any missing method calls to the linked Transaction object
    def method_missing(*args)
      @real_txn.send(*args)
    end
  end
end

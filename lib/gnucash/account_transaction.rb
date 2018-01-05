module Gnucash
  # Class to link a transaction object to an Account.
  class AccountTransaction
    include Support::LightInspect

    # @return [Value] The transaction value for the linked account.
    attr_reader :value

    # Construct an AccountTransaction object.
    #
    # This method is used internally when building a Transaction object.
    #
    # @param real_txn [Transaction]
    #   The linked Transaction object.
    # @param value [Value]
    #   The value of the Transaction split for this account
    def initialize(real_txn, value)
      @real_txn = real_txn
      @value = value
    end

    # Pass through any missing method calls to the linked Transaction object.
    def method_missing(*args)
      @real_txn.send(*args)
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[value]
    end
  end
end

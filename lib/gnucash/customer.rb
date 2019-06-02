module Gnucash
  # Represent a GnuCash customer object.
  class Customer
    include Support::LightInspect
    # gnc:GncCustomer
    ## id, company, name, addr1, addr2, addr3, addr4, phone, fax, email, notes, shipname, shipaddr1, shipaddr2, shipaddr3, shipaddr4, shiphone, shipfax, shipmail

    # @return [String] The name of the customer (unqualified).
    attr_reader :name

    # @return [String] The GUID of the customer.
    attr_reader :guid

    # @return [String] The ID of the customer.
    attr_reader :id

    # Create an customer object.
    #
    # @param book [Book] The {Gnucash::Book} containing the customer.
    # @param node [Nokogiri::XML::Node] Nokogiri XML node.
    def initialize(book, node)
      @book = book
      @node = node
      @name = node.xpath('cust:name').text
      @id = node.xpath('cust:id').text
      @guid = node.xpath('cust:guid').text
    end

    # Return the fully qualified customer name.
    #
    # @return [String] Fully qualified customer name.
    def full_name
      name
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[id name guid]
    end

  end
end

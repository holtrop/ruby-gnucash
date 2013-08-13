module Gnucash
  # Represent a currency value as an integer so that integer math can be used
  # for accuracy in computations.
  class Value
    include Comparable

    # _Fixnum_:: The raw, undivided integer value
    attr_accessor :val

    # Create a new Value object with value 0
    def self.zero
      Value.new(0)
    end

    # Construct a Value object
    # === Arguments
    # +val+ _String_ or _Fixnum_::
    #   Either a _String_ in the form "1234/100" or an integer containing the
    #   raw value
    # +div+ _Fixnum_::
    #   The divisor value to use (when +val+ is given as a _Fixnum_)
    def initialize(val, div = 100)
      if val.is_a?(String)
        if val =~ /^(-?\d+)\/(\d+)$/
          @val = $1.to_i
          @div = $2.to_i
        else
          raise "Unexpected value string: #{val.inspect}"
        end
      elsif val.is_a?(Fixnum)
        @val = val
        @div = div
      else
        raise "Unexpected value type: #{val.class}"
      end
    end

    # Add two Value objects
    def +(other)
      Value.new(@val + other.val)
    end

    # Subtract two Value objects
    def -(other)
      Value.new(@val - other.val)
    end

    # Represent the Value as a string (two decimal places)
    def to_s
      sprintf("%.02f", to_f)
    end

    # Convert the Value to a Float
    def to_f
      @val / @div.to_f
    end

    # Compare two Value objects
    def <=>(other)
      @val <=> other.val
    end
  end
end

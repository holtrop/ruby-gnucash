module Gnucash
  # Represent a currency value as an integer so that integer math can be used
  # for accuracy in computations.
  class Value
    include Comparable

    # _Fixnum_:: The raw, undivided integer value
    attr_reader :val

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

    # Add to a Value object
    # +other+ can be another Value or a Numeric
    def +(other)
      if other.is_a?(Value)
        Value.new(@val + other.val)
      elsif other.is_a?(Numeric)
        (to_f + other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Subtract from a Value object
    # +other+ can be another Value or a Numeric
    def -(other)
      if other.is_a?(Value)
        Value.new(@val - other.val)
      elsif other.is_a?(Numeric)
        (to_f - other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Negate a Value
    def -@
      Value.new(-@val, @div)
    end

    # Multiply a Value object
    # +other+ should be a Numeric
    def *(other)
      if other.is_a?(Numeric)
        (to_f * other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Divide a Value object
    # +other+ should be a Numeric
    def /(other)
      if other.is_a?(Numeric)
        (to_f / other).round(2)
      else
        raise "Unexpected argument"
      end
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

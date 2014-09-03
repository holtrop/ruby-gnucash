module Gnucash
  # Represent a currency value as an integer so that integer math can be used
  # for accuracy in computations.
  class Value
    include Comparable

    # @return [Fixnum] The raw, undivided integer value.
    attr_reader :val

    # Create a new Value object with value 0.
    #
    # @return [Value] Zero value.
    def self.zero
      Value.new(0)
    end

    # Construct a Value object.
    #
    # @param val [String, Fixnum]
    #   Either a String in the form "1234/100" or an integer containing the
    #   raw value.
    # @param div [Fixnum]
    #   The divisor value to use (when +val+ is given as a Fixnum).
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

    # Add to a Value object.
    #
    # @param other [Value, Numeric]
    #
    # @return [Value] Result of addition.
    def +(other)
      if other.is_a?(Value)
        Value.new(@val + other.val)
      elsif other.is_a?(Numeric)
        (to_f + other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Subtract from a Value object.
    #
    # @param other [Value, Numeric]
    #
    # @return [Value] Result of subtraction.
    def -(other)
      if other.is_a?(Value)
        Value.new(@val - other.val)
      elsif other.is_a?(Numeric)
        (to_f - other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Negate a Value.
    #
    # @return [Value] Result of negation.
    def -@
      Value.new(-@val, @div)
    end

    # Multiply a Value object.
    #
    # @param other [Numeric] Multiplier.
    #
    # @return [Value] Result of multiplication.
    def *(other)
      if other.is_a?(Numeric)
        (to_f * other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Divide a Value object.
    #
    # @param other [Numeric] Divisor.
    #
    # @return [Value] Result of division.
    def /(other)
      if other.is_a?(Numeric)
        (to_f / other).round(2)
      else
        raise "Unexpected argument"
      end
    end

    # Represent the Value as a string (two decimal places).
    #
    # @return [String] Representation of value.
    def to_s
      sprintf("%.02f", to_f)
    end

    # Convert the Value to a Float.
    #
    # @return [Float] Value of the value as a Float.
    def to_f
      @val / @div.to_f
    end

    # Compare two Value objects.
    #
    # @return [Integer] Comparison result.
    def <=>(other)
      @val <=> other.val
    end
  end
end

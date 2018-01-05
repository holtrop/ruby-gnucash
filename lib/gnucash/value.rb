module Gnucash
  # Represent a currency value as an integer so that integer math can be used
  # for accuracy in computations.
  class Value
    include Comparable
    include Support::LightInspect

    # @return [Integer] The raw, undivided integer value.
    attr_reader :val

    # @return [Integer] Divisor value.
    attr_reader :div

    # Create a new Value object with value 0.
    #
    # @return [Value] Zero value.
    def self.zero
      Value.new(0)
    end

    # Construct a Value object.
    #
    # @param val [String, Integer]
    #   Either a String in the form "1234/100" or an integer containing the
    #   raw value.
    # @param div [Integer]
    #   The divisor value to use (when +val+ is given as a Integer).
    def initialize(val, div = 100)
      if val.is_a?(String)
        if val =~ /^(-?\d+)\/(\d+)$/
          @val = $1.to_i
          @div = $2.to_i
        else
          raise "Unexpected value string: #{val.inspect}"
        end
      elsif val.is_a?(Integer)
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
        lcm_div = @div.lcm(other.div)
        Value.new((@val * (lcm_div / @div)) + (other.val * (lcm_div / other.div)), lcm_div)
      elsif other.is_a?(Numeric)
        to_f + other
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
        lcm_div = @div.lcm(other.div)
        Value.new((@val * (lcm_div / @div)) - (other.val * (lcm_div / other.div)), lcm_div)
      elsif other.is_a?(Numeric)
        to_f - other
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
    # @param other [Numeric, Value] Multiplier.
    #
    # @return [Numeric] Result of multiplication.
    def *(other)
      if other.is_a?(Value)
        other = other.to_f
      end
      if other.is_a?(Numeric)
        to_f * other
      else
        raise "Unexpected argument (#{other.inspect})"
      end
    end

    # Divide a Value object.
    #
    # @param other [Numeric, Value] Divisor.
    #
    # @return [Numeric] Result of division.
    def /(other)
      if other.is_a?(Value)
        other = other.to_f
      end
      if other.is_a?(Numeric)
        to_f / other
      else
        raise "Unexpected argument (#{other.inspect})"
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

    # Convert the Value to a Rational.
    #
    # @return [Rational] Value of the value as a Rational.
    def to_r
      Rational(@val, @div)
    end

    # Compare two Value objects.
    #
    # @return [Integer] Comparison result.
    def <=>(other)
      lcm_div = @div.lcm(other.div)
      (@val * (lcm_div / @div)) <=> (other.val * (lcm_div / other.div))
    end

    # Test two Value objects for equality.
    #
    # @return [Boolean]
    #   Whether the two Value objects hold the same value.
    def ==(other)
      lcm_div = @div.lcm(other.div)
      (@val * (lcm_div / @div)) == (other.val * (lcm_div / other.div))
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[val div]
    end
  end
end

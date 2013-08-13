module Gnucash
  class Value
    include Comparable

    attr_accessor :val

    def self.zero
      Value.new(0)
    end

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

    def +(other)
      Value.new(@val + other.val)
    end

    def -(other)
      Value.new(@val - other.val)
    end

    def to_s
      sprintf("%.02f", to_f)
    end

    def to_f
      @val / @div.to_f
    end

    def <=>(other)
      @val <=> other.val
    end
  end
end

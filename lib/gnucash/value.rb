module Gnucash
  class Value
    attr_accessor :val
    def initialize(val)
      if val.is_a?(String)
        if val =~ /^(-?\d+)\/100$/
          @val = $1.to_i
        else
          raise "Unexpected value string: #{val.inspect}"
        end
      elsif val.is_a?(Fixnum)
        @val = val
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
      (@val / 100.0).round(2).to_s
    end
  end
end

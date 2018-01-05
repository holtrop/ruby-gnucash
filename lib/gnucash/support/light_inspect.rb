module Gnucash
  module Support
    # Allows lightweight inspection os Gnucash models by avoiding fetch XML nodes.
    module LightInspect

      # Attributes available for inspection
      #
      # @return [Array<Symbol>] Attributes used to build the inspection string
      def attributes
        []
      end

      # Custom implementation using only selected attributes.
      #
      # @return [String] Stringified version of the object
      # @see #attributes
      def inspect
        inspection = attributes.map { |att| "#{att}: #{send(att)}" }.join(", ")
        "#<#{self.class} #{inspection}>"
      end
    end
  end
end

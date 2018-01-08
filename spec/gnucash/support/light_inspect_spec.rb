module Gnucash
  module Support
    describe LightInspect do
      class Klass
        include LightInspect
      end

      describe "#attributes" do
        it "returns an empty Array if not overridden" do
          expect(Klass.new.attributes).to eq([])
        end
      end
    end
  end
end

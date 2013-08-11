describe Gnucash do
  describe '.open' do
    it 'opens a gzipped gnucash book' do
      book = Gnucash.open("spec/books/sample.gnucash")
      book.is_a?(Gnucash::Book).should be_true
    end
    it 'opens a plain text gnucash book' do
      book = Gnucash.open("spec/books/sample-text.gnucash")
      book.is_a?(Gnucash::Book).should be_true
    end
  end
end

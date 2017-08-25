describe Gnucash do
  describe '.open' do
    it 'opens a gzipped gnucash book' do
      book = Gnucash.open("spec/books/sample.gnucash")
      expect(book.is_a?(Gnucash::Book)).to be_truthy
    end
    it 'opens a plain text gnucash book' do
      book = Gnucash.open("spec/books/sample-text.gnucash")
      expect(book.is_a?(Gnucash::Book)).to be_truthy
    end
  end
end

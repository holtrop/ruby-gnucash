# Gnucash

Ruby library for extracting data from GnuCash data files

## Installation

Add this line to your application's Gemfile:

    gem 'gnucash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gnucash

## Usage

    require "gnucash"

    book = Gnucash.open("MyBook.gnucash")

    book.accounts.each do |account|
      puts "#{account.full_name}: #{account.final_balance}"
    end

    act = book.find_account_by_full_name("Assets:Checking")
    balance = Gnucash::Value.zero
    act.transactions.each do |txn|
      balance += txn.value
      $stdout.puts(sprintf("%s  %8s  %8s  %s",
                           txn.date,
                           txn.value,
                           balance,
                           txn.description))
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

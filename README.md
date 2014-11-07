# Gnucash

Ruby library for extracting data from xml formatted GnuCash data files

[![Gem Version](https://badge.fury.io/rb/gnucash.png)](http://badge.fury.io/rb/gnucash)

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

## Release Notes

### v1.2.0

- use Date objects instead of formatted strings for dates
- use a single colon instead of a double colon in account names
- use 'require_relative' instead of 'require'

### v1.1.0

- store and provide access to the account description
- change many attributes to read-only
- add 'placeholder' Account attribute

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

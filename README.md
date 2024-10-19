# Gnucash

Ruby library for extracting data from XML GnuCash data files

[![Gem Version](https://badge.fury.io/rb/gnucash.png)](http://badge.fury.io/rb/gnucash)

## Installation

Add this line to your application's Gemfile:

    gem 'gnucash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gnucash

## Usage

```ruby
require "gnucash"

book = Gnucash.open("MyBook.gnucash")

book.accounts.each do |account|
  puts "#{account.full_name}: #{account.final_balance}"
end

act = book.find_account_by_full_name("Assets:Checking")
balance = Gnucash::Value.zero
act.transactions.each do |txn|
  balance += txn.value
  $stdout.printf("%s  %8s  %8s  %s\n",
                 txn.date,
                 txn.value,
                 balance,
                 txn.description)
end

year = Date.today.year
delta = act.balance_on("#{year}-12-31") - act.balance_on("#{year - 1}-12-31")
puts "You've saved #{delta} this year so far!"
```

To get the balance of an account, use ```act.balance_on("#{year}-12-31")```.
To get the total balance of an account with all its children accounts,
use ```act.balance_on("#{year}-12-31", recursive: true)```.

## Full YARD Documentation

See <https://rubydoc.info/github/holtrop/ruby-gnucash/master>.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

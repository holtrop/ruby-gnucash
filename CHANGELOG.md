# ChangeLog

## v1.6.0

- add Customer class and Book#find_customer_by_full_name (#12, #13)

## v1.5.0

- add options Hash to Account#balance_on with :recursive option

## v1.4.0

- add Account#parent_id and #parent
- add Value#to_r to convert to Rational
- override #inspect for several Gnucash objects to improve REPL usage

## v1.3.1

- do not round numeric results of Value computations

## v1.3.0

- allow Value objects to be passed to / and * operators

## v1.2.2

- Allow mixing Value objects with different divisors - fix #7
- Replace Fixnum with Integer to avoid Ruby 2.4 deprecation warnings

## v1.2.1

- Determine a transaction split's value in the split account's currency - fix #6

## v1.2.0

- use Date objects instead of formatted strings for dates
- use a single colon instead of a double colon in account names
- use 'require_relative' instead of 'require'

## v1.1.0

- store and provide access to the account description
- change many attributes to read-only
- add 'placeholder' Account attribute

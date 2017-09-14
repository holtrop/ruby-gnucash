# ChangeLog

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

## Unreleased

## 1.0.0

- Breaking change: Bump `rails` dependency to `>=6.1`
- Breaking change: Make `Sift#filter_errors` return `ActiveModel::Errors` object instead of `Hash`
- Add `net-http` as explicit dependency. `net-http` is a default gem for Ruby 3.0

## 0.16.0

- Adds a `tap` method to `filter_on` to support mutating filter values

## 0.15.0

- Support for `null` filtering by `jsonb` type

## 0.14.0

- Add support for `jsonb` type (only for PostgreSQL)

## 0.13.0

## 0.12.0

- Change gem name to procore-sift

## 0.11.0

- Rename gem to Sift
- Add normalization and validation for date range values
- Tightened up ValueParser by privatizing unnecessarily public attr_accessors

## 0.10.0

- Support for integer filtering of JSON arrays

## 0.9.2 (January 26, 2018)

- Rename gem to Brita
- Publish to RubyGems

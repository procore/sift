# Filterable

[![CircleCI](https://circleci.com/gh/procore/filterable/tree/master.svg?style=svg&circle-token=25a8c0e33d452c46febab9cc9cdd13c85a67af47)](https://circleci.com/gh/procore/filterable/tree/master)

Short description and motivation.

## Usage
Include Filterable in your controllers, and define some filters.

```ruby
class PostsController < ApplicationController
  include Filterable

  filter_on :title, type: :string

  def index
    render json: filtrate(Post.all)
  end
end
```

This will allow users to pass `?filters[title]=foo` and get the `Post`s with the title `foo`.

Filterable will also handle rendering errors using the standard rails errors structure. You can add this to your controller by adding,

```ruby
before_action :render_filter_errors, unless: :filters_valid?

def render_filter_errors
  render json: { errors: filter_errors } and return
end
```

to your controller.

These errors are based on the type that you told filterable your param was.

## Filter Types
Every filter must have a type, so that Filterable knows what to do with it. The current valid filter types are:
* int - Filter on an integer column
* decimal - Filter on a decimal column
* boolean - Filter on a boolean column
* string - Filter on a string column
* text - Filter on a text column
* date - Filter on a date column
* time - Filter on a time column
* datetime - Filter on a datetime column
* scope - Filter on an ActiveRecord scope

## Scopes
Just as your filter values are used to scope queries on a column, values you
pass to a scope filter will be used as arguments to that scope. For example:

```ruby
class Post < ActiveRecord::Base
  scope :with_body, (text) -> { where(body: text) }
end

class PostsController < ApplicationController
  include Filterable

  filter_on :with_body, type: :text

  def index
    render json: filtrate(Post.all)
  end
end
```

Passing `?filters[with_body]=my_text` will call the `with_body` scope with
`my_text` as the argument. If you have a scope that takes multiple arguments,
you can pass an array of arguments instead of a single argument.

Scopes that accept no arguments are currently not supported.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'filterable'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install filterable
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

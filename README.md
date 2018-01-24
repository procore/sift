# Chemex

[![Build Status](https://travis-ci.org/procore/chemex.svg?branch=master)](https://travis-ci.org/procore/chemex)

A tool to build your own filters!

## Developer Usage
Include Chemex in your controllers, and define some filters.

```ruby
class PostsController < ApplicationController
  include Chemex

  filter_on :title, type: :string

  def index
    render json: filtrate(Post.all)
  end
end
```

This will allow users to pass `?filters[title]=foo` and get the `Post`s with the title `foo`.

Chemex will also handle rendering errors using the standard rails errors structure. You can add this to your controller by adding,

```ruby
before_action :render_filter_errors, unless: :filters_valid?

def render_filter_errors
  render json: { errors: filter_errors } and return
end
```

to your controller.

These errors are based on the type that you told chemex your param was.

### Filter Types
Every filter must have a type, so that Chemex knows what to do with it. The current valid filter types are:
* int - Filter on an integer column
* decimal - Filter on a decimal column
* boolean - Filter on a boolean column
* string - Filter on a string column
* text - Filter on a text column
* date - Filter on a date column
* time - Filter on a time column
* datetime - Filter on a datetime column
* scope - Filter on an ActiveRecord scope

### Filter on Scopes
Just as your filter values are used to scope queries on a column, values you
pass to a scope filter will be used as arguments to that scope. For example:

```ruby
class Post < ActiveRecord::Base
  scope :with_body, ->(text) { where(body: text) }
end

class PostsController < ApplicationController
  include Chemex

  filter_on :with_body, type: :scope

  def index
    render json: filtrate(Post.all)
  end
end
```

Passing `?filters[with_body]=my_text` will call the `with_body` scope with
`my_text` as the argument.

Scopes that accept no arguments are currently not supported.

#### Accessing Params with Filter Scopes

Filters with `type: :scope` have access to the params hash by passing in the desired keys to the `scope_params`. The keys passed in will be returned as a hash with their associated values, and should always appear as the last argument in your scope.

```ruby
class Post < ActiveRecord::Base
  scope :user_posts_on_date, ->(date, options) {
    where(user_id: options[:user_id], blog_id: options[:blog_id], date: date)
  }
end

class UsersController < ApplicationController
  include Chemex

  filter_on :user_posts_on_date, type: :scope, scope_params: [:user_id, :blog_id]

  def show
    render json: filtrate(Post.all)
  end
end
```
Passing `?filters[user_posts_on_date]=10/12/20` will call the `user_posts_on_date` scope with
`10/12/20` as the the first argument, and will grab the `user_id` and `blog_id` out of the params and pass them as a hash, as the second argument.

### Renaming Filter Params

A filter param can have a different field name than the column or scope. Use `internal_name` with the correct name of the column or scope.

```ruby
class PostsController < ApplicationController
  include Chemex

  filter_on :post_id, type: :int, internal_name: :id

end
```

### Sort Types
Every sort must have a type, so that Chemex knows what to do with it. The current valid sort types are:
* int - Sort on an integer column
* decimal - Sort on a decimal column
* string - Sort on a string column
* text - Sort on a text column
* date - Sort on a date column
* time - Sort on a time column
* datetime - Sort on a datetime column
* scope - Sort on an ActiveRecord scope

### Sort on Scopes
Just as your sort values are used to scope queries on a column, values you
pass to a scope sort will be used as arguments to that scope. For example:

```ruby
class Post < ActiveRecord::Base
  scope :order_on_body_no_params, -> { order(body: :asc) }
  scope :order_on_body, ->(direction) { order(body: direction) }
  scope :order_on_body_then_id, ->(body_direction, id_direction) { order(body: body_direction).order(id: id_direction) }
end

class PostsController < ApplicationController
  include Chemex

  sort_on :order_by_body_ascending, internal_name: :order_on_body_no_params, type: :scope
  sort_on :order_by_body, internal_name: :order_on_body, type: :scope, scope_params: [:direction]
  sort_on :order_by_body_then_id, internal_name: :order_on_body_then_id, type: :scope, scope_params: [:direction, :asc]


  def index
    render json: filtrate(Post.all)
  end
end
```

`scope_params` takes an order-specific array of the scope's arguments. Passing in the param :direction allows the consumer to choose which direction to sort in (ex. `-order_by_body` will sort `:desc` while `order_by_body` will sort `:asc`)

Passing `?sort=-order_by_body` will call the `order_on_body` scope with
`:desc` as the argument. The direction is the only argument that the consumer has control over.
Passing `?sort=-order_by_body_then_id` will call the `order_on_body_then_id` scope where the `body_direction` is `:desc`, and the `id_direction` is `:asc`. Note: in this example the user has no control over id_direction. To demonstrate:
Passing `?sort=order_by_body_then_id` will call the `order_on_body_then_id` scope where the `body_direction` this time is `:asc`, but the `id_direction` remains `:asc`.

Scopes that accept no arguments are currently supported, but you should note that the user has no say in which direction it will sort on.

`scope_params` can also accept symbols that are keys in the `params` hash. The value will be fetched and passed on as an argument to the scope.


## Consumer Usage

Filter:
`?filters[<field_name>]=<value>`

Filters are translated to Active Record `where`s and are chained together. The order they are applied is not guarenteed.

Sort:
`?sort=-published_at,position`

Sort is translated to Active Record `order` The sorts are applied in the order they are passed by the client.
the `-` symbol means to sort in `desc` order. By default, keys are sorted in `asc` order.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'chemex'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install chemex
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

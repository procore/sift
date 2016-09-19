# Filterable
Short description and motivation.

## Usage
Use filter by adding your filters to your controller.

```ruby
class PostsController < ApplicationController
  include Filterable

  filter_on :title, type: :string

  def index
    render json: filtrate(Post.all)
  end
end

```

That will allow users to pass `?title=foo` and get the `Post`s with the title `foo`.

Filterable will also handle rendering errors using the standard rails errors structure. You can add this to you controller by adding,

```ruby
before_action :render_filter_errors, unless: :filters_valid?

def render_filter_errors
  render json: { errors: filter_errors } and return
end
```

to your controller.

These errors are based on the type that you told filterable your param was.

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

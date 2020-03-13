class AltPostsController < PostsController
  filter_on :french_bread, type: :scope, internal_name: :body2, default: ->(c) { c.order(:body) }
  sort_on :foobar, type: :string, internal_name: :priority
end

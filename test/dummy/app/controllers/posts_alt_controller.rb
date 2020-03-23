class PostsAltController < PostsController
  filter_on :body, type: :int, internal_name: :priority
  sort_on :body, type: :int, internal_name: :priority
end

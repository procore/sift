class PostsController < ApplicationController
  include Filterable

  filter_on :priority
  filter_on :rating
  filter_on :visible
  filter_on :title
  filter_on :body
  filter_on :expiration
  filter_on :hidden_after
  filter_on :published_at

  def index
    puts params.inspect
    render json: filtrate(Post.all)
  end
end

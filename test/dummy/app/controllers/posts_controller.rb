class PostsController < ApplicationController
  include Filterable

  filter_on :id, type: :int
  filter_on :priority, type: :int
  filter_on :rating, type: :decimal
  filter_on :visible, type: :boolean
  filter_on :title, type: :string
  filter_on :body, type: :text
  filter_on :expiration, type: :date
  filter_on :hidden_after, type: :time
  filter_on :published_at, type: :datetime
  filter_on :expired_before, type: :scope

  before_action :render_filter_errors, unless: :filters_valid?

  def index
    render json: filtrate(Post.all)
  end

  private

  def render_filter_errors
    render json: { errors: filter_errors } and return
  end
end

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
  filter_on :published, type: :scope

  filter_on :french_bread, type: :string, internal_name: :title
  filter_on :body2, type: :scope, internal_name: :body2, default: ->(c) { c.order(:body) }

  filter_on :id_array, type: :int, internal_name: :id, validate: -> (validator) {
    value = validator.instance_variable_get("@id_array")
    if value.is_a? Array
      # Verify all variables in the array are integers
      unless value.all? { |v| (Integer(v) rescue false) }
        validator.errors.add(:id_array, "Not all values were valid integers")
      end
    else
      if !(Integer(value) rescue false)
        validator.errors.add(:id_array, "It not an integer")
      end
    end
  }

  before_action :render_filter_errors, unless: :filters_valid?

  sort_on :title, type: :string
  sort_on :priority, type: :string
  sort_on :foobar, type: :string, internal_name: :title

  def index
    render json: filtrate(Post.all)
  end

  private

  def render_filter_errors
    render json: { errors: filter_errors } and return
  end
end

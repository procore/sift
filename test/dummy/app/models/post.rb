class Post < ApplicationRecord
  scope :expired_before, -> (date) {
    where('expiration < ?', date)
  }

  scope :body2, -> (text) {
    where(body: text)
  }

  scope :body_and_priority, -> (text, priority) {
    where(body: text, priority: priority)
  }

  scope :published, -> {
    where.not(published_at: nil)
  }

  scope :order_on_body_no_params, -> {
    order(body: :desc)
  }

  scope :order_on_body_one_param, -> (direction) {
    order(body: direction)
  }

  scope :order_on_body_multi_param, -> (body, direction) {
    where(body: body).order(id: direction)
  }

  scope :expired_before_ordered_by_body, -> (date, direction) {
    expired_before(date).order_on_body_one_param(direction)
  }
end

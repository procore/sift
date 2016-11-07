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
end

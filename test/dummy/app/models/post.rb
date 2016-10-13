class Post < ApplicationRecord
  scope :expired_before, -> (date) {
    where('expiration < ?', date)
  }

  scope :body2, -> (text) {
    where(body: text)
  }
end

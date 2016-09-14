class Post < ApplicationRecord
  scope :expired_before, -> (date) {
    where('expiration < ?', date)
  }
end

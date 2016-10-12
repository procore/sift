class Post < ApplicationRecord
  scope :expired_before, -> (date) {
    where('expiration < ?', date)
  }

  scope :status, -> (status) {
    where(body: status)
  }
end

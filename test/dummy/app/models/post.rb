class Post < ApplicationRecord
  def self.default_scope
    order('created_at DESC')
  end

  scope :expired_before, -> (date) {
    where('expiration < ?', date)
  }

  scope :body2, -> (text) {
    where(body: text)
  }
end

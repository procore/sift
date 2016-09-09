class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer :priority
      t.decimal :rating
      t.boolean :visible
      t.string :title
      t.text :body
      t.date :expiration
      t.time :hidden_after
      t.datetime :published_at

      t.timestamps
    end
  end
end

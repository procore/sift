class AddMetadataToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :metadata, :json
  end
end

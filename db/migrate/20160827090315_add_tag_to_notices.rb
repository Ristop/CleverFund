class AddTagToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :tag, :string
  end
end

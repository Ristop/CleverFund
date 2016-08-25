class AddSortedToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :sorted, :boolean
  end
end

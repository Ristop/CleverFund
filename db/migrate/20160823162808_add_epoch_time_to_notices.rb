class AddEpochTimeToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :epich_time, :string
  end
end

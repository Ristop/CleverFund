class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.string :from_email
      t.string :from_name
      t.float :amount
      t.boolean :income

      t.timestamps null: false
    end
  end
end

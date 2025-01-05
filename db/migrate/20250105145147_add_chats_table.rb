class AddChatsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.string :hash_id, index: true, null: false
      t.text :messages
      t.timestamps
    end
  end
end

class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs do |t|
      t.string :key, limit: 64, null: false
      t.text :value, null: false
    end

    add_index :configs, :key, unique: true
  end
end

class BaseTables < ActiveRecord::Migration[5.0]
  def change
    create_table :things do |t|
      t.column :name, :string
      t.column :email, :string
      t.column :renamed_email, :string
    end

    create_table :thing_events do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :thing_name, :string
      t.column :thing_email, :string
      t.references :thing
    end
  end
end

class CreateTables < ActiveRecord::Migration
  def change
    create_table :calendars, id: false do |t|
      t.string :title
      t.string :description
      t.string :in_service_id
      t.string :service

      t.timestamps null: false
    end

    add_index :calendars, [:in_service_id, :service], unique: true

    create_table :writers, id: false do |t|
      t.string :name
      t.string :in_service_id
      t.string :service

      t.timestamps null: false
    end

    add_index :writers, [:in_service_id, :service], unique: true

    create_table :articles do |t|
      t.string :title
      t.string :description
      t.string :url
      t.date :date

      t.timestamps null: false

      t.belongs_to :calendar
      t.belongs_to :writer
    end
  end
end

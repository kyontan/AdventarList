class CreateTables < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :title
      t.string :description
      t.string :in_service_id,  null: false
      t.string :service,        null: false

      t.timestamps null: false
    end

    add_index :calendars, [:in_service_id, :service], unique: true

    create_table :writers do |t|
      t.string :name
      t.string :in_service_id,  null: false
      t.string :service,        null: false

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

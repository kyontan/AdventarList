class CreateTables < ActiveRecord::Migration
  def change
  	create_table :calendars do |t|
  		t.string :title
  		t.string :description
  		t.string :url

  		t.timestamps null: false
  	end

  	create_table :writers do |t|
  		t.string :name
  		t.string :service_id
  		t.string :service

  		t.timestamps null: false
  	end

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

class RecreateIndexOfCalendars < ActiveRecord::Migration
  def change
    remove_index :calendars, [:in_service_id, :service]
    add_index :calendars, [:in_service_id, :service, :year], unique: true
  end
end

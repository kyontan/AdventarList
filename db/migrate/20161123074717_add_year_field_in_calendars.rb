class AddYearFieldInCalendars < ActiveRecord::Migration
  def change
  	add_column :calendars, :year, :integer
  end
end

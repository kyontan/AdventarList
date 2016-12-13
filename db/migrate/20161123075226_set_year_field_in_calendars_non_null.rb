class SetYearFieldInCalendarsNonNull < ActiveRecord::Migration
  def change
  	change_column :calendars, :year, :integer, null: false
  end
end

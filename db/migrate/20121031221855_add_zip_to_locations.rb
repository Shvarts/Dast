class AddZipToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :zip, :float
  end
end

class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.integer :number
      t.string :title
      t.string :callsign

      t.timestamps
    end
  end

  def self.down
    drop_table :channels
  end
end

class AddIpToChannel < ActiveRecord::Migration
  def self.up
    add_column :channels, :ip, :string
    Channel.find([1,3]).map {|c| c.update_attribute(:ip, '10.1.50.52')}
    Channel.find([2,4]).map {|c| c.update_attribute(:ip, '10.1.50.53')}
  end

  def self.down
    remove_column :channels, :ip
  end
end

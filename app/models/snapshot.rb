class Snapshot < ActiveRecord::Base
  def url
    '/snaps/' + filename
  end
  
  def full_path
    Rails.root.join(Snapshot.base_path, filename).to_s
  end
  
  def self.base_path
    Rails.root.join('public','snaps').to_s
  end
end


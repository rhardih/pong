class Check < ApplicationRecord
  def self.protocols
    [:https, :http]
  end
end

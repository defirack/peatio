# frozen_string_literal: true

class Config < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true

  def self.platform_id
    find_by(key: 'platform_id').try(:value)
  end
end

# == Schema Information
# Schema version: 20210201100941
#
# Table name: configs
#
#  id    :bigint           not null, primary key
#  key   :string(64)       not null
#  value :text(65535)      not null
#
# Indexes
#
#  index_configs_on_key  (key) UNIQUE
#

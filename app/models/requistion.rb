class Requistion < ActiveRecord::Base
  validates :object, presence: true
  validates :main_address, presence: true
  validates :arrival_address, presence: true
  validates :contact_name, presence: true
  validates :contact_phone, presence: true
  validates :type_requistion, presence: true
  has_many :pairs
  has_many :users, through: :pairs
  belongs_to :building
  belongs_to :contract
  accepts_nested_attributes_for :pairs
end

class Batch < ApplicationRecord
    validates :reference, presence: true, uniqueness: true
    validates :purchaseChannel, presence: true
    validates :orders, presence: true
end

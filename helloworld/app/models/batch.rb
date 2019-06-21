class Batch < ApplicationRecord
    validates :reference, presence: true
    validates :purchaseChannel, presence: true
    validates :orders, presence: true
end

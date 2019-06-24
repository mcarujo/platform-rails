class Batch < ApplicationRecord
    validates :purchaseChannel, presence: true
    validates :orders, presence: true
end

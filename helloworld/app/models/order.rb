class Order < ApplicationRecord
    validates :purchaseChannel, presence: true
    validates :clientName, presence: true
    validates :address, presence: true
    validates :deliveryService, presence: true
    validates :totalValue, presence: true
    validates :lineItems, presence: true
    validates :status, presence: true
end

class Order < ApplicationRecord
    validates :reference, presence: true, uniqueness: true
    validates :purchaseChannel, presence: true
    validates :clientName, presence: true
    validates :address, presence: true
    validates :deliveryService, presence: true
    validates :totalValue, presence: true
    validates :lineItems, presence: true
    validates :status, presence: true
end

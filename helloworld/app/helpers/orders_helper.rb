module OrdersHelper
    def cutInformationByStatus orders
        aux = []
        orders.each do |order|
            local = {:id => order.id, :status => order.status}
            aux << local
        end
        aux
    end
    def definePKOrders
        prefix = "BR"
        ordersnumbers = Order.all.size.to_s.rjust(6, '0') # 00000X
        primarykey = prefix + ordersnumbers.to_s
    end
end

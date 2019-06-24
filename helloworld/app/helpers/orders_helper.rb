module OrdersHelper
    def cutInformationByStatus orders
        aux = []
        orders.each do |order|
            local = {:id => order.id, :status => order.status}
            aux << local
        end
        aux
    end
end

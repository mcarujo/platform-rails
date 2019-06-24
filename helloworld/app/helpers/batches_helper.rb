module BatchesHelper
    def definePKBatches
        year = Time.now.year
        month = Time.now.month.to_s.rjust(2, '0')
        numberBatches = Batch.where("created_at like '#{year}-#{month}%'").size.to_s.rjust(2, '0') # 0X
        primarykey = year.to_s + month.to_s.to_s.rjust(2, '0') + "-" + numberBatches.to_s
    end
end

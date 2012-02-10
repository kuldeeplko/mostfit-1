# these functions were in Loan.rb but they are not ebing used so moving them here for the time being
module IRR
  def cash_flow(type = :scheduled, exclude_fees = false)
    # Hash of dates and +/- amounts. 
    # This differs from payment_schedule and payments_hash in that it includes fees. 
    # Perhaps it would be better if those functions returned a comprehensive listing, but for the time being, this is okay
    # TODO : make payments_hash and payment_schedule return comprehensve cashflows (i.e. fees,etc  as well.)
    fs = type == :scheduled ? product_fee_schedule : fees_paid
    fsh = fs.map{|f,v| [f,{:fees => v.values.inject(0){|a,b| a+b}}]}.to_hash
    cf  = type == :scheduled ? payment_schedule : payments_hash
    #Double counting of fees in case of ssame date first payment is happening here
    if (cf.values.collect{|x| x[:fees]||0}.inject(0){|s,x| s+=x} == 0)
      cf  += fsh
    end
    dd  = type == :scheduled ? scheduled_disbursal_date : disbursal_date
    cf  += {dd => {:principal => -amount}}
    rv  = cf.keys.sort.map{|k| v=cf[k];[k,(v[:principal] || 0) + (v[:interest] || 0) + (exclude_fees ? 0 : (v[:fees] || 0))]}
    return rv
  end

  def product_fee_schedule
    # This is for IRR calculation, so we can get the fee schedule for the loan product
    # So we don't have to save dummy loans when we design a product.
    @fee_schedule = {}
    klass_identifier = "loan"
    loan_product.fees.each do |f|
      type, *payable_on = f.payable_on.to_s.split("_")
      date = send(payable_on.join("_")) if type == klass_identifier
      if date.class==Date
        @fee_schedule += {date => {f => f.fees_for(self)}} unless date.nil?
      elsif date.class==Array
        date.each{|date|
          @fee_schedule += {date => {f => f.fees_for(self)}} unless date.nil?
        }
      end
    end
    @fee_schedule
  end


  def irr(exclude_fees = false,iterations = 100)
    begin
      cf = cash_flow(:scheduled, exclude_fees)
      min_date = cf[0][0]
      rv = (1..iterations).inject do |rate,|
        # trust me, this is correct. i think
        i = 1
        npv_map = cf.map do |x| 
          yn = ((x[0]-min_date) / get_reciprocal).round
          yd = get_divider
          yf = yn / yd.to_f
          df = [1/(1+(yf*rate)),x[1]]
          df
        end
        npv = npv_map.inject(0){|a,b| a + (b[0]*b[1])}
        rate * (1 - npv / -amount)
      end
    rescue
      "NaN"
    end
  end
end

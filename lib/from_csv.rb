module FromCsv

  module Loan
    def self.from_csv(row, headers)
      interest_rate = (row[headers[:interest_rate]].to_f>1 ? row[headers[:interest_rate]].to_f/100 : row[headers[:interest_rate]].to_f)
      keys = [:product, :amount, :installment_frequency, :number_of_installments, :scheduled_disbursal_date, :scheduled_first_payment_date,
              :applied_on, :approved_on, :disbursal_date, :funding_line_serial_number, :applied_by_staff, :approved_by_staff, :repayment_style,
              :center, :reference, :client_reference]
      missing_keys = keys - headers.keys
      raise ArgumentError.new("missing keys #{missing_keys.join(',')}") unless missing_keys.blank?
      hash = {
        :loan_product                       => LoanProduct.first(:name => row[headers[:product]]), 
        :amount                             => row[headers[:amount]],
        :interest_rate                      => interest_rate,
        :installment_frequency              => row[headers[:installment_frequency]].downcase, 
        :number_of_installments             => row[headers[:number_of_installments]],
        :scheduled_disbursal_date           => Date.parse(row[headers[:scheduled_disbursal_date]]),
        :scheduled_first_payment_date       => Date.parse(row[headers[:scheduled_first_payment_date]]),
        :applied_on                         => Date.parse(row[headers[:applied_on]]), 
        :approved_on                        => Date.parse(row[headers[:approved_on]]),
        :disbursal_date                     => Date.parse(row[headers[:disbursal_date]]), 
        :upload_id                          => row[headers[:upload_id]],
        :disbursed_by_staff_id              => StaffMember.first(:name => row[headers[:disbursed_by_staff]]).id,
        :funding_line_id                    => FundingLine.first(:reference => row[headers[:funding_line_serial_number]]).id,
        :applied_by_staff_id                => StaffMember.first(:name => row[headers[:applied_by_staff]]).id,
        :approved_by_staff_id               => StaffMember.first(:name => row[headers[:approved_by_staff]]).id,
        :repayment_style_id                 => RepaymentStyle.first(:name => row[headers[:repayment_style]]).id,
        :c_center_id                        => Center.first(:name => row[headers[:center]]).id,
        :reference                          => row[headers[:reference]],
        :client                             => Client.first(:reference => row[headers[:client_reference]])}
      obj = new(hash)
      obj.history_disabled=true
      saved = obj.save
      if saved
        c = Checker.first_or_new(:model_name => "Loan", :reference => obj.reference)
        c.check_field = row[headers[:check_field]]
        c.as_on = Date.parse(row[headers[:arguments]])
        c.expected_value = row[headers[:expected_value]]
        c.unique_field = :reference
        c.upload_id = row[headers[:upload_id]]
        c.loan = obj
        c.save
      end
      [saved, obj]
    end
  end
end

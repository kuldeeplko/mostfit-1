class InsuranceCompanies < Application
  # provides :xml, :yaml, :js

  def index
    @insurance_companies = InsuranceCompany.all
    display @insurance_companies
  end

  def show
    id = params[:id]
    @insurance_company = InsuranceCompany.get(id)
    raise NotFound unless @insurance_company
    display @insurance_company
  end

  def new
    only_provides :html
    @insurance_company = InsuranceCompany.new    
    display @insurance_company, :layout => layout?
  end

  def edit
    id = params[:id]
    only_provides :html
    @insurance_company = InsuranceCompany.get(id)
    raise NotFound unless @insurance_company
    display @insurance_company
  end

  def create
    insurance_company = params[:insurance_company]
    @insurance_company = InsuranceCompany.new(insurance_company)
    if @insurance_company.save
      redirect(params[:return]||resource(:insurance_companies), :message => {:notice => "InsuranceCompany was successfully created"})
    else
      message[:error] = "InsuranceCompany failed to be created"
      render :new
    end
  end

  def update
    id = params[:id]
    insurance_company = params[:insurance_company]
    @insurance_company = InsuranceCompany.get(id)
    raise NotFound unless @insurance_company
    if @insurance_company.update(insurance_company)
       redirect resource(@insurance_company)
    else
      display @insurance_company, :edit
    end
  end

  def destroy
    id = params[:id]
    @insurance_company = InsuranceCompany.get(id)
    raise NotFound unless @insurance_company
    if @insurance_company.destroy
      redirect resource(:insurance_companies)
    else
      raise InternalServerError
    end
  end

end # InsuranceCompanies

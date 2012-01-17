class Claims < Application
  # provides :xml, :yaml, :js
  before :get_client

  def index
    @claims = Claim.all(:client => @client)
    display @claims
  end

  def show
    id = params[:id]
    @claim = Claim.get(id)
    raise NotFound unless @claim
    display @claim
  end

  def new
    only_provides :html
    @claim = Claim.new
    @claim.client = @client
    @claim.generate_claim_id
    display @claim
  end

  def edit
    id = params[:id]
    only_provides :html
    @claim = Claim.get(id)
    raise NotFound unless @claim
    display @claim
  end

  def create
    claim = params[:claim]
    claim[:documents] = claim[:documents].keys if claim[:documents]
    @claim = Claim.new(claim)
    @claim.client = @client
    
    if @claim.save
      redirect resource(@client, :claims), :message => {:notice => "Claim was successfully created"}
    else
      message[:error] = "Claim failed to be created"
      render :new
    end
  end

  def update
    id = params[:id]
    claim = params[:claim]
    claim[:documents] = claim[:documents].keys if claim[:documents]
    @claim = Claim.get(id)
    raise NotFound unless @claim
    if @claim.update(claim)
       redirect resource(@client, :claims)
    else
      display @claim, :edit
    end
  end

  def destroy
    id = params[:id]
    @claim = Claim.get(id)
    raise NotFound unless @claim
    if @claim.destroy
      redirect resource(:claims)
    else
      raise InternalServerError
    end
  end

  private
  include DateParser
  def get_client
    if params[:client_id]
      @client = Client.get(params[:client_id])
    end
  end

end # Claims

class Accounts < Application
  # provides :xml, :yaml, :js

  def index
    if request.xhr? and params[:account_type_id]
      @accounts = Account.all(:account_type_id => params[:account_type_id]).paginate(:page =>params[:page], :per_page => 5)
      partial :accounts_selection
    else
      @accounts = Account.all(:parent_id => "")
      display @accounts, :layout => layout?
    end
  end

  def show(id)
    @account = Account.get(id)
    raise NotFound unless @account
    display @account
  end

  def new
    only_provides :html
    @account = Account.new
    display @account
  end

  def edit(id)
    only_provides :html
    @account = Account.get(id)
    if @account.account_type
      @parent_accounts = (Account.all(:account_type => @account.account_type)-[@account])
    end
    raise NotFound unless @account
    display @account
  end

  def create(account)
    @account = Account.new(account)
    if @account.save
      redirect resource(:accounts), :message => {:notice => "Account was successfully created"}
    else
      message[:error] = "Account failed to be created"
      render :new
    end
  end

  def update(id, account)
    @account = Account.get(id)
    raise NotFound unless @account
    if @account.update(account)
       redirect resource(:accounts)
    else
      display @account, :edit
    end
  end

  def destroy(id)
    @account = Account.get(id)
    raise NotFound unless @account
    if @account.destroy
      redirect resource(:accounts)
    else
      raise InternalServerError
    end
  end

end # Accounts

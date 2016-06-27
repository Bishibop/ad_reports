class CustomersController < ApplicationController

  before_action :must_be_logged_in
  before_action do
    must_be :admin
  end

  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Customer not found."
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer
    else
      render :new
    end
  end

  def edit
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Customer not found."
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update(customer_params)
      redirect_to @customer
    else
      render :edit
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Customer not found."
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    redirect_to customers_path
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Customer not found."
  end

  private

  def customer_params
    params.require(:customer).permit([:name, :login_domain])
  end
end

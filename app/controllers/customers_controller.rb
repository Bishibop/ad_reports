class CustomersController < ApplicationController

  before_action :logged_in_using_omniauth?
  before_action do
    authorized_for 'god emperor'
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
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update(customer_params)
      redirect_to @customer
    else
      render :edit
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    redirect_to customers_path
  end

  private

  def customer_params
    params.require(:customer).permit([:name])
  end
end

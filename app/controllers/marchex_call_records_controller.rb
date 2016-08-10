class MarchexCallRecordsController < ApplicationController
  before_action :authenticate

  def index
    client = @current_user.current_client(params)
    render json: MarchexCallsDatatable.new(view_context, client)
  end
end

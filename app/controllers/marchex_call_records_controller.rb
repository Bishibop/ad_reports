class MarchexCallRecordsController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json: MarchexCallsDatatable.new(view_context) }
    end
  end
end

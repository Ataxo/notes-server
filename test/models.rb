# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base

  get "/test_success" do
    output = {valid_output: "ok"}
    render_output output
  end

  get "/test_error" do
    render_error params[:error_code], params[:error_type] ,"Message of #{params[:error_code]}"
  end

  get "/test_exception_400" do
    raise ArgumentError, "test"
  end

  get "/test_exception_500" do
    raise NoMethodError, "test"
  end

end

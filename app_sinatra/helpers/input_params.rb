# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  # fix input params (remove splats & captures)
  # for easier client show input arguments (mostly used in error responses)
  def input_params
    args = params.clone
    args.delete(:splat)
    args.delete(:captures)
    args
  end
end
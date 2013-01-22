# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  attr_accessor :benchmark

  # benchmarking request time length
  before do
    self.benchmark = Time.now
  end

end
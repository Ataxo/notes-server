# -*- encoding : utf-8 -*-

module ApiError
  class NotFound < Exception; end
  class RouteNotFound < Exception; end
  class Unauthorized < Exception; end
  class Forbidden < Exception; end
  class BadRequest < Exception; end
  class InvalidTaxonomy < Exception; end
end

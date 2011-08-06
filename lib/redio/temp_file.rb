module Redio
  class Tempfile < File
    include Expiration

    # 3 days
    self.default_expiration = 3 * 86400

  end
end

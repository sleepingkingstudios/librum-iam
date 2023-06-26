# frozen_string_literal: true

module Librum
  module Iam
    # Rails engine for Librum::Iam.
    class Engine < ::Rails::Engine
      isolate_namespace Librum::Iam
    end
  end
end

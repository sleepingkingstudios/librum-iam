# frozen_string_literal: true

Librum::Core::Responders::Html::ViewResponder.class_eval do
  include Librum::Iam::Responders::Html::AuthenticatedResponder
end

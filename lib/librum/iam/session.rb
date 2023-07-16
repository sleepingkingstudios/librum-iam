# frozen_string_literal: true

module Librum::Iam
  # Encapsulates the current user(s) and the credential used to authenticate.
  class Session
    # @param authenticated_user [Librum::Iam::User] The user used to
    #   authenticate to the system. Defaults to the authorized user.
    # @param credential [Librum::Iam::Credential] The credential used to
    #   authenticate to the system.
    # @param expires_at [ActiveSupport::TimeWithZone] The time the session
    #   expires. Defaults to one day from session creation. If the credential
    #   expires sooner than this value, the credential's expiration time will be
    #   used instead.
    def initialize(
      credential:,
      authenticated_user: nil,
      expires_at:         nil
    )
      @authorized_user    = credential.user
      @authenticated_user = authenticated_user || authorized_user
      @credential         = credential
      @expires_at         = [
        (expires_at || 1.day.from_now),
        credential.expires_at
      ].min
    end

    # @return [Librum::Iam::User] the user used to authenticate to the system.
    attr_reader :authenticated_user

    # @return [Librum::Iam::User] the user authorized to access the system.
    attr_reader :authorized_user
    alias current_user authorized_user

    # @return [Librum::Iam::Credential] The credential used to authenticate to
    #   the system.
    attr_reader :credential

    # @return [ActiveSupport::TimeWithZone] the time the session expires.
    attr_reader :expires_at

    # @return [true, false] true if the expires_at date is in the past,
    #   otherwise false.
    def expired?
      expires_at < Time.current
    end
  end
end

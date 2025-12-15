# frozen_string_literal: true

# Base controller from which all other controllers inherit
class ApplicationController < ActionController::Base
  # By default, requires authentication for all controllers.
  # Also provides the current_user method.
  include Authentication

  # Adds an after_action callback to verify that `authorize!` has been called.
  # See https://actionpolicy.evilmartians.io/#/rails?id=verify_authorized-hooks for how to skip.
  verify_authorized

  rescue_from ActionPolicy::Unauthorized, with: :unauthorized_user

  rescue_from ActionPolicy::AuthorizationContextMissing, with: :unauthorized_user

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def unauthorized_user
    error = current_user ? 'Unauthorized user' : 'Not logged in'
    render json: { error: }, status: :unauthorized
  end

  def stanford_access?
    current_user && allowed_to?(:view?, with: StanfordPolicy)
  end

  def business_access?
    current_user && allowed_to?(:view?, with: RestrictedPolicy)
  end

  def mint_jwt_token
    @mint_jwt_token ||= JwtService.encode
  end

  def implicit_authorization_target
    self
  end

  def require_turbo_frame
    redirect_to root_path unless turbo_frame_request?
  end
end

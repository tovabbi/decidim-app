# frozen_string_literal: true

# Show the four-colour Google logo (app/packs/images/google-color.svg) on the
# "log in with Google" button instead of the grey Remix icon.
#
# Setting Decidim.omniauth_providers[:google_oauth2][:icon_path] is not enough:
# when the provider is configured per organization in the admin panel, Decidim
# uses those stored settings, which carry a blank icon_path, so it falls back
# to the grey icon. Override the helper instead.
module GoogleOauthIcon
  def oauth_icon(provider)
    return super unless provider.to_sym == :google_oauth2

    external_icon("media/images/google-color.svg") || super
  end
end

Rails.application.config.to_prepare do
  Decidim::OmniauthHelper.prepend(GoogleOauthIcon)
end

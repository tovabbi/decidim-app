# frozen_string_literal: true

# Use the four-colour Google logo (app/packs/images/google-color.svg) on the
# "log in with Google" button instead of the default grey icon.
Rails.application.config.after_initialize do
  Decidim.omniauth_providers[:google_oauth2][:icon_path] = "media/images/google-color.svg"
end

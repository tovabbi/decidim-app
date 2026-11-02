# frozen_string_literal: true

# Google gives no nickname, so the "complete your profile" form starts with an
# empty Nickname field. Decidim uses `nickname || name`, and an empty string is
# truthy in Ruby, so the name never becomes the fallback. The account is then
# built with a blank nickname, validation fails, and Decidim shows a misleading
# "another account uses the same email address" error.
# Fall back to the name when the nickname is blank.
module OmniauthNicknameFallback
  def normalized_nickname
    Decidim::UserBaseEntity.nicknamize(nickname.presence || name, current_organization.id)
  end
end

Rails.application.config.to_prepare do
  Decidim::OmniauthRegistrationForm.prepend(OmniauthNicknameFallback)
end

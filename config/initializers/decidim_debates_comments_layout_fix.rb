# frozen_string_literal: true

# Decidim 0.32 disables the comments layout radio buttons in the admin debate
# form once a debate has comments. Disabled inputs are not submitted, so the
# layout arrives blank and the debate can never be saved again ("nem lehet
# üres", "nincs a listában", "comments layout cannot be changed").
# Keep the stored layout when it is locked; an empty stored value means
# "single_column", as in DebateForm#map_model.
module DebatesCommentsLayoutFormFix
  def comments_layout
    value = super
    return stored_comments_layout if value.blank? && comments_layout_locked?

    value
  end

  private

  def stored_comments_layout
    debate.comments_layout.presence || "single_column"
  end

  def comments_layout_change
    return if stored_comments_layout == comments_layout

    errors.add(:comments_layout, I18n.t("form.errors.comments_layout_locked", scope: "decidim.debates.admin.debates"))
  end
end

Rails.application.config.to_prepare do
  form = Decidim::Debates::Admin::DebateForm
  form.prepend(DebatesCommentsLayoutFormFix) unless form <= DebatesCommentsLayoutFormFix
end

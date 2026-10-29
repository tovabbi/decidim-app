# frozen_string_literal: true

# Decidim 0.32 passes the uploaded CSV's file path to ImportResultsCsvJob, but
# ResultsCsvImporter parses its argument as CSV text, so every results import
# reads zero rows and still reports success. Pass the file contents instead
# (read here, in the web process that received the upload; "bom|utf-8" also
# accepts CSVs saved by Excel).
module AccountabilityImportResultsFormFix
  def local_file_path
    process_file_locally(file) { |path| File.read(path, encoding: "bom|utf-8") }
  end
end

Rails.application.config.to_prepare do
  form = Decidim::Accountability::Admin::ImportResultsForm
  form.prepend(AccountabilityImportResultsFormFix) unless form <= AccountabilityImportResultsFormFix
end

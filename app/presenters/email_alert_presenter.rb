class EmailAlertPresenter
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json(*_args)
    {
      title: title,
      description: summary,
      change_note: change_note,
      subject: subject,
      tags: tags,
      links: links,
      urgent: urgent,
      document_type: document.document_type,
      email_document_supertype: "other",
      government_document_supertype: "other",
      content_id: content_id,
      public_updated_at: public_updated_at,
      publishing_app: "specialist-publisher",
      base_path: base_path,
      priority: priority,
    }.merge(extra_options)
  end

  def content_id
    document.content_id
  end

private

  # The tags are sent to email-alert-api and matched against subscriberlists.
  def tags
    {
      # This format should be the same as https://github.com/alphagov/finder-frontend/blob/2c1d5f25e7e4212795b485b6e4c290c6764c813c/app/controllers/email_alert_subscriptions_controller.rb#L41
      format: document.format,
    }.deep_merge(document.format_specific_metadata.reject { |_k, v| v.blank? })
  end

  def links
    DocumentLinksPresenter.new(document).to_json[:links]
  end

  def org_title
    {
      "aaib_report" => "Air Accidents Investigation Branch reports",
      "asylum_support_decision" => "Asylum Support Decision",
      "business_finance_support_scheme" => "Business finance support scheme",
      "cma_case" => "Competition and Markets Authority cases",
      "countryside_stewardship_grant" => "Countryside Stewardship Grants",
      "employment_appeal_tribunal_decision" => "Employment appeal tribunal decisions",
      "employment_tribunal_decision" => "Employment tribunal decisions",
      "esi_fund" => "European Structural and Investment Funds",
      "international_development_fund" => "International Development Funds",
      "maib_report" => "Marine Accident Investigation Branch reports",
      "medical_safety_alert" => "Alerts and recalls for drugs and medical devices",
      "raib_report" => "Rail Accident Investigation Branch reports",
      "tax_tribunal_decision" => "Upper Tribunal (Tax and Chancery Chamber)",
      "utaac_decision" => "Upper Tribunal (Administrative Appeals Chamber)",
    }
  end

  def document_noun
    {
      "aaib_report" => "report",
      "asylum_support_decision" => "decision",
      "business_finance_support_scheme" => "scheme",
      "cma_case" => "case",
      "countryside_stewardship_grant" => "grant",
      "employment_appeal_tribunal_decision" => "decision",
      "employment_tribunal_decision" => "decision",
      "esi_fund" => "fund",
      "international_development_fund" => "fund",
      "maib_report" => "report",
      "medical_safety_alert" => "alert",
      "raib_report" => "report",
      "tax_tribunal_decision" => "decision",
      "utaac_decision" => "decision",
    }
  end

  def title
    redrafted? ? document.title + " updated" : document.title
  end

  def summary
    document.summary
  end

  def change_note
    document.change_note
  end

  def subject
    title
  end

  def urgent
    document.urgent
  end

  def priority
    urgent ? "high" : "normal"
  end

  def footnote
    document.email_footnote
  end

  def public_updated_at
    document.public_updated_at
  end

  def base_path
    document.base_path
  end

  def updated_or_published
    redrafted? ? "updated" : "published"
  end

  def redrafted?
    document.draft? && !document.first_draft?
  end

  def extra_options
    {
      footnote: footnote,
    }.reject { |_k, v| v.nil? }
  end
end

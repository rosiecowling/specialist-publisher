class StatutoryInstrument < Document
  validates :laid_date, date: true
  validates :sift_end_date, date: true
  validates :sift_end_date, absence: { message: "must be blank when withdrawn" }, if: :withdrawn_sifting_status?
  validates :sifting_status, presence: true
  validates :subject, presence: true
  validates :primary_publishing_organisation, presence: true
  validates :withdrawn_date, presence: true, date: true, if: :withdrawn_sifting_status?
  validates :withdrawn_date, absence: { message: "must be blank if not withdrawn" }, unless: :withdrawn_sifting_status?

  FORMAT_SPECIFIC_FIELDS = %i(
    laid_date
    sift_end_date
    sifting_status
    subject
    withdrawn_date
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)
  attr_accessor :organisations, :primary_publishing_organisation

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    @primary_publishing_organisation = params[:primary_publishing_organisation]
    @organisations = params[:organisations]
  end

  def taxons
    [BREXIT_TAXON_ID]
  end

  def self.title
    "EU Withdrawal Act 2018 statutory instrument"
  end

  def links
    super.merge(
      organisations: organisations | [primary_publishing_organisation],
      primary_publishing_organisation: [primary_publishing_organisation],
    )
  end

  def has_organisations?
    true
  end

  def withdrawn_sifting_status?
    sifting_status == "withdrawn"
  end
end

require 'spec_helper'

describe RaibReport do

  def raib_report_content_item(n)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/raib-reports/example-raib-report-#{n}",
      "title" => "Example RAIB Report #{n}",
      "description" => "This is the summary of example RAIB Report #{n}",
      "format" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example RAIB Report" * 10),
        "metadata" => {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "raib_report"
        },
      },
      "routes" => [
        {
          "path" => "/raib-reports/example-raib-report-#{n}",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  let(:non_raib_report_content_item) {
    {
      "content_id" => SecureRandom.uuid,
      "format" => "specialist_document",
      "details" => {
        "metadata" => {
          "document_type" => "not_an_raib_report",
        },
      },
    }
  }

  let(:raib_org_content_item) {
    {
      "base_path" => "/government/organisations/rail-accidents-investigation-branch",
      "content_id" => "013872d8-8bbb-4e80-9b79-45c7c5cf9177",
      "title" => "Rail Accident Investigation Branch",
      "format" => "redirect",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-10-27T11:47:43.454Z",
      "public_updated_at" => "2014-12-19T14:16:32.000+00:00",
      "phase" => "live",
      "analytics_identifier" => nil,
      "links" => {
        "available_translations" => [
          {
            "content_id" => "c4c1bd4d-f252-43f1-91cf-a8cfdd526097",
            "title" => "Rail Accident Investigation Branch",
            "base_path" => "/government/organisations/rail-accidents-investigation-branch",
            "description" => "nil",
            "api_url" => "https://www.gov.uk/api/content/government/organisations/air-accidents-investigation-branch",
            "web_url" => "https://www.gov.uk/government/organisations/air-accidents-investigation-branch",
            "locale" => "en"
          }
        ]
      },
      "description" => nil,
      "details" => {
      }
    }
  }

  let(:indexable_attributes) {
    {
      "title" => "Example RAIB Report 0",
      "description" => "This is the summary of example RAIB Report 0",
      "link" => "/raib-reports/example-raib-report-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example RAIB Report" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
      "organisations" => ["rail-accidents-investigation-branch"],
    }
  }

  before do
    @fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
      :details,
      :description,
    ]

    @raib_reports = []

    10.times do |n|
      @raib_reports << raib_report_content_item(n)
    end

    publishing_api_has_fields_for_format('specialist_document', @raib_reports, @fields)

    @raib_reports.each do |raib_report|
      publishing_api_has_item(raib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context "#all" do
    it "returns all RAIB Reports" do
      expect(described_class.all.length).to be(@raib_reports.length)
    end

    it "rejects any non RAIB Reports" do
      all_specialist_documents = [non_raib_report_content_item] + @raib_reports
      publishing_api_has_fields_for_format('specialist_document', all_specialist_documents , @fields)
      publishing_api_has_item(non_raib_report_content_item)

      expect(described_class.all.length).to be(@raib_reports.length)
    end
  end

  context "#find" do
    it "returns a AAIB Report" do
      content_id = @raib_reports[0]["content_id"]
      raib_report = described_class.find(content_id)

      expect(raib_report.base_path).to            eq(@raib_reports[0]["base_path"])
      expect(raib_report.title).to                eq(@raib_reports[0]["title"])
      expect(raib_report.summary).to              eq(@raib_reports[0]["description"])
      expect(raib_report.body).to                 eq(@raib_reports[0]["details"]["body"])
      expect(raib_report.date_of_occurrence).to   eq(@raib_reports[0]["details"]["metadata"]["date_of_occurrence"])
    end
  end

  context "#save!" do
    it "saves the RAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_put_links

      raib_report = @raib_reports[0]

      raib_report.delete("publication_state")
      raib_report.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      raib_report["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(raib_report["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_including(raib_report))
      expect(raib_report.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  context "#publish!" do
    it "publishes the RAIB Report" do
      stub_publishing_api_publish(@raib_reports[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_format('organisation', [raib_org_content_item], [:base_path, :content_id])

      raib_report = described_class.find(@raib_reports[0]["content_id"])
      expect(raib_report.publish!).to eq(true)

      assert_publishing_api_publish(raib_report.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end

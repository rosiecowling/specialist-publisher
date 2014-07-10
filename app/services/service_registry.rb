require "list_documents_service"
require "show_document_service"
require "preview_document_service"
require "new_document_service"
require "publish_document_service"
require "update_document_service"
require "create_document_service"
require "withdraw_document_service"
require "show_manual_document_service"

class ServiceRegistry

  def initialize(dependencies)
    @cma_case_builder = dependencies.fetch(:cma_case_builder)
    @aaib_report_builder = dependencies.fetch(:aaib_report_builder)
    @cma_case_repository = dependencies.fetch(:cma_case_repository)
    @aaib_report_repository = dependencies.fetch(:aaib_report_repository)
    @document_renderer = dependencies.fetch(:document_renderer)
    @manual_repository_factory = dependencies.fetch(:manual_repository_factory)

    @observers = dependencies.fetch(:observers)
  end

  def list_aaib_reports
    ListDocumentsService.new(
      aaib_report_repository,
    )
  end

  def new_aaib_report
    NewDocumentService.new(
      aaib_report_builder,
    )
  end

  def create_aaib_report(attributes)
    CreateDocumentService.new(
      aaib_report_builder,
      aaib_report_repository,
      observers.aaib_report_creation,
      attributes,
    )
  end

  def show_aaib_report(document_id)
    ShowDocumentService.new(
      aaib_report_repository,
      document_id,
    )
  end

  def preview_aaib_report(document_id, attributes)
    PreviewDocumentService.new(
      aaib_report_repository,
      aaib_report_builder,
      document_renderer,
      document_id,
      attributes,
    )
  end

  def preview_manual_document(context)
    PreviewManualDocumentService.new(
      manual_repository(context),
      # TODO This doesn't look right!
      cma_case_builder,
      document_renderer,
      context,
    )
  end

  def publish_aaib_report(document_id)
    PublishDocumentService.new(
      aaib_report_repository,
      observers.aaib_report_publication,
      document_id,
    )
  end

  def update_aaib_report(document_id, attributes)
    UpdateDocumentService.new(
      repo: aaib_report_repository,
      listeners: [],
      document_id: document_id,
      attributes: attributes,
    )
  end

  def withdraw_aaib_report(document_id)
    WithdrawDocumentService.new(
      aaib_report_repository,
      observers.aaib_report_withdrawal,
      document_id,
    )
  end

  def new_cma_case_attachment(document_id)
    NewDocumentAttachmentService.new(
      cma_case_repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create_cma_case_attachment(context, document_id)
    CreateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def update_cma_case_attachment(context, document_id)
    UpdateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def show_cma_case_attachment(context, document_id)
    ShowDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def create_manual_document(context)
    CreateManualDocumentService.new(
      manual_repository: manual_repository(context),
      listeners: observers.manual_document_creation,
      context: context,
    )
  end

  def update_manual_document(context)
    UpdateManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def show_manual_document(context)
    ShowManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def new_manual_document(context)
    NewManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def create_manual_document_attachment(context)
    CreateManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def update_manual_document_attachment(context)
    UpdateManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def show_manual_document_attachment(context)
    ShowManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def new_manual_document_attachment(context)
    NewManualDocumentAttachmentService.new(
      manual_repository(context),
      # TODO: This be should be created from the document or just be a form object
      Attachment.method(:new),
      context,
    )
  end

  private

  def manual_repository(context)
    manual_repository_factory.call(context.current_organisation_slug)
  end

  attr_reader(
    :aaib_report_builder,
    :aaib_report_repository,
    :cma_case_builder,
    :document_renderer,
    :cma_case_repository,
    :manual_repository_factory,
    :observers,
  )
end

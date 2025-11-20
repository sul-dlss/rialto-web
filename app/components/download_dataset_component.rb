# frozen_string_literal: true

# Link to download datasets
class DownloadDatasetComponent < ViewComponent::Base
  def initialize(set: 'pubs')
    @set = set
    super()
  end

  attr_reader :set

  def call
    tag.div(class: 'd-flex flex-row align-items-center gap-3') do
      link_to helpers.download_set_path(set), data: { turbo: false }, aria: { label: "Download #{file.filename}" },
                                              class: 'btn btn-primary my-2' do
        tag.i(class: 'bi bi-download me-2') + file.filename
      end + file_size + last_updated
    end
  end

  private

  def file
    DownloadFile.new(set:)
  end

  def file_size
    tag.div { "Size: #{file.size} (uncompressed)" }
  end

  def last_updated
    tag.div { tag.i { "Last updated: #{file.last_updated}" } }
  end
end

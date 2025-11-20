# frozen_string_literal: true

# PublicationsController
class PublicationsController < ApplicationController
  skip_verify_authorized
  def index; end

  def download
    authorize! to: :view?, with: RestrictedPolicy

    send_file file.filepath,
              filename: file.filename,
              type: 'application/zip',
              disposition: 'attachment'
  end

  def file
    DownloadFile.new(set: params[:set])
  end
end

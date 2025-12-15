# frozen_string_literal: true

# DownloadsController
class DownloadsController < ApplicationController
  skip_verify_authorized

  def index; end

  def download
    return redirect_to download_path(session_timeout: true) unless current_user

    unless business_access?
      return render status: :unauthorized,
                    json: { error: 'You are not authorized to access this file.' }
    end

    send_file file.filepath,
              filename: file.filename,
              type: 'application/zip',
              disposition: 'attachment'
  end

  def file
    DownloadFile.new(set: params[:set])
  end
end

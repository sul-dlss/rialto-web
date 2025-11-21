# frozen_string_literal: true

# Download File
class DownloadFile
  require 'zip'

  def initialize(set:)
    @set = set
  end

  attr_reader :set

  def filename
    return 'publications.zip' if set == 'pubs'

    "publications_by_#{set}.zip"
  end

  def filepath
    File.join(Settings.downloads.path, filename)
  end

  def size
    zip = Zip::File.open(filepath)
    entry = zip.find_entry(filename.gsub('.zip', '.csv'))
    entry.size
  end

  def last_updated
    File.mtime(filepath).strftime('%B %-d, %Y')
  end
end

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
    size = entry.size
    # for some reason zip gives binary file size, i.e. 1.53 gb file returns 1533884797
    # We need to convert the binary file size to decimal size (1024) for number_to_human_size
    # power_of gives the ratio of exponents which tells us our exponent for converted_bytes
    power_of = (Math.log(size) / Math.log(1000)).floor
    converted_bytes = size * (1.024**power_of)
    ActiveSupport::NumberHelper.number_to_human_size(converted_bytes)
  end

  def last_updated
    File.mtime(filepath).strftime('%B %-d, %Y')
  end
end

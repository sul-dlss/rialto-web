# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'openssl'

namespace :google_docs do
  desc 'harvest google docs'
  task harvest: :environment do
    Settings.docs.each do |path, doc|
      uri = URI(doc)
      views_path = Rails.root.join('app', 'views', 'documentation', "#{path}.html.erb")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get(uri.request_uri)
      end

      html = Nokogiri::HTML(res.body, nil, 'UTF-8')

      element = html.at_css('#contents')
      # Google docs updates it's classes every 5 minutes (when it re-publishes)
      # So even if the doc isn't update the file will update.
      # This check removes unnecessary updating of the files unless the text has actually changed
      same_text = Nokogiri::HTML(File.read(views_path), nil,
                                 'UTF-8').at_css('.doc-content').text.delete("\n") ==
                  element.at_css('.doc-content').text.delete("\n")
      next if same_text

      doc_contents = element.to_html +
                     "<div class='last-updated mb-4 fst-italic'>
                        Last updated: #{Time.zone.today.strftime('%B %d, %Y')}
                      </div>\n"
      views_path.write(doc_contents)
    end
  end
end

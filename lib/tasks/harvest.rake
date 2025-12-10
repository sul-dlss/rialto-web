# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'openssl'
require 'csv'

namespace :harvest do # rubocop:disable Metrics/BlockLength
  desc 'harvest google docs and data dictionaries'
  task all: %i[data_dictionaries google_docs]

  desc 'harvest data dictionaries'
  task data_dictionaries: :environment do
    def table_row(row, tag = 'td')
      "<tr>#{row.map { |field| "<#{tag}>#{field}</#{tag}>" }.join("\n")}</tr>"
    end

    data_dictionaries = ['https://raw.githubusercontent.com/sul-dlss/rialto-airflow/refs/heads/main/rialto_airflow/publish/documentation/publications_by_author_data_dictionary.csv',
                         'https://raw.githubusercontent.com/sul-dlss/rialto-airflow/refs/heads/main/rialto_airflow/publish/documentation/publications_by_department_data_dictionary.csv',
                         'https://raw.githubusercontent.com/sul-dlss/rialto-airflow/refs/heads/main/rialto_airflow/publish/documentation/publications_by_school_data_dictionary.csv',
                         'https://raw.githubusercontent.com/sul-dlss/rialto-airflow/refs/heads/main/rialto_airflow/publish/documentation/publications_data_dictionary.csv']

    data_dictionaries.each do |url|
      uri = URI(url)
      path = url.split('/')[-1].gsub('.csv', '')
      views_path = Rails.root.join('app', 'views', 'downloads', "_#{path}.html.erb")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get(uri.request_uri)
      end

      data = CSV.parse(res.body, headers: false, encoding: 'UTF-8')
      html = '<table class="table table-bordered">'
      data.each_with_index do |row, index|
        html += if index.zero?
                  "<thead>#{table_row(row, 'th')}</thead>"
                else
                  "<tbody>#{table_row(row)}</tbody>"
                end
      end
      views_path.write("#{html}</table>\n")
    end
  end

  desc 'harvest google docs'
  task google_docs: :environment do
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

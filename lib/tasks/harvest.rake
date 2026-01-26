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

      File.write(views_path, '') unless views_path.exist?

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get(uri.request_uri)
      end

      html = Nokogiri::HTML(res.body, nil, 'UTF-8')

      element = html.at_css('#contents')
      element.css('img').each do |img|
        img.remove_attribute('style')
        img.parent.remove_attribute('style')
      end

      # google sets li, p, header css without qualifliers.
      # This is messing with CSS on the rest of the page. This only applies the google docs style to .doc-content
      contents = element.to_html.gsub('<style type="text/css">', '<style type="text/css">.doc-content {').gsub(
        '</style>', '}</style>'
      )
      # clean css to make more readable
      contents = contents.gsub(');', ");\n").gsub('{', "{\n").gsub('}', "\n}")

      doc_contents = contents +
                     "<div class='last-updated mb-4 fst-italic'>
                        Last updated: #{Time.zone.today.strftime('%B %d, %Y')}
                      </div>\n"

      views_path.write(doc_contents)
    end
  end
end

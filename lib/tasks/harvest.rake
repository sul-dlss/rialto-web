# frozen_string_literal: true

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
      GoogleDocHarvester.new(slug: path, url: doc).call
    end
  end
end

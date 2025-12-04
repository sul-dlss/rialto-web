# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

namespace :google_docs do
  desc 'harvest google docs'
  task harvest: :environment do
    docs = { orcid_adoption: 'https://docs.google.com/document/d/e/2PACX-1vQnZ5BuBlDs4rpN7ylIjYwEGO2k-Z1LdqG-TmMLMn30XHA61F4zhtfnSeEy8StKDCF6MihejfZLZnQT/pub' }
    docs.each do |path, doc|
      html_contents = URI.open(doc) do |f|
        f.read
      end
      html = Nokogiri::HTML(html_contents)
      
      element = html.at_css('#contents')

      Rails.root.join('app', 'views', 'documentation', "#{path}.html.erb").write(element.to_html)
    end
  end
end

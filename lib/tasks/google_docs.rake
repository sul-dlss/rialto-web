# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

namespace :google_docs do
  desc 'harvest google docs'
  task harvest: :environment do
    docs = { orcid_adoption: 'https://docs.google.com/document/d/e/2PACX-1vQwktJc0dtPGQgfbewgS2wIMZxw0nvZqKHdnu2R9QHv4R0pGFoF_LlMabxSMqN2ThiOtKGDfCaptF3q/pub' }
    docs.each do |path, doc|
      doc = Nokogiri::HTML(URI.open(doc))

      element = doc.at_css('#contents')

      Rails.root.join('app', 'views', 'documentation', "#{path}.html.erb").write(element.to_html)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleDocHarvester do
  let(:slug) { 'test-doc' }
  let(:image_url) { 'https://docs.google.com/docs-images-rt/ABC123=s2048' }
  let(:image_bytes) { "\x89PNG\r\n\x1a\n".b + ('fake-png-bytes' * 10).b }
  let(:views_path) { Rails.root.join('app/views/documentation', "#{slug}.html.erb") }
  let(:images_dir) { Rails.root.join('app/assets/images/documentation', slug) }

  before do
    doc_url = 'https://docs.google.com/document/d/e/TESTID/pub'
    doc_html = <<~HTML
      <html><body>
        <div id="contents">
          <style type="text/css">.c1{color:red;}</style>
          <p><img src="#{image_url}" alt="" style="width:100px"></p>
        </div>
      </body></html>
    HTML
    stub_request(:get, doc_url)
      .to_return(status: 200, body: doc_html, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, image_url)
      .to_return(status: 200, body: image_bytes, headers: { 'Content-Type' => 'image/png' })
    described_class.new(slug: slug, url: doc_url).call
  end

  after do
    FileUtils.rm_f(views_path)
    FileUtils.rm_rf(images_dir)
  end

  it 'writes the harvested view file' do
    expect(views_path).to exist
  end

  it 'downloads the remote image into the slug images directory' do
    expect(File.binread(images_dir.join('img-1.png'))).to eq(image_bytes)
  end

  it 'rewrites img src to reference the local asset via image_path' do
    expect(views_path.read).to include("<%= image_path 'documentation/#{slug}/img-1.png' %>")
  end

  it 'removes the remote google image url from the harvested view' do
    expect(views_path.read).not_to include(image_url)
  end
end

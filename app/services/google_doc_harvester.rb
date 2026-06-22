# frozen_string_literal: true

require 'nokogiri'
require 'net/http'

# Fetches a published Google Doc and writes it as a documentation partial,
# downloading any remote images into the asset pipeline so they don't depend
# on short-lived Google-hosted URLs.
class GoogleDocHarvester
  IMAGE_EXTENSIONS = %w[png jpg jpeg gif svg webp].freeze
  CONTENT_TYPE_EXTENSIONS = {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/svg+xml' => 'svg',
    'image/webp' => 'webp'
  }.freeze

  def initialize(slug:, url:)
    @slug = slug
    @url = url
  end

  def call
    prepare_paths
    views_path.write(build_contents + footer)
  end

  private

  attr_reader :slug, :url

  def views_path
    @views_path ||= Rails.root.join('app/views/documentation', "#{slug}.html.erb")
  end

  def images_dir
    @images_dir ||= Rails.root.join('app/assets/images/documentation', slug.to_s)
  end

  def prepare_paths
    File.write(views_path, '') unless views_path.exist?
    FileUtils.rm_rf(images_dir)
    FileUtils.mkdir_p(images_dir)
  end

  def build_contents
    element = fetch_contents
    placeholders = localize_images(element)
    html = scope_styles(element.to_html)
    placeholders.each { |placeholder, erb| html = html.gsub(placeholder, erb) }
    html
  end

  def fetch_contents
    Nokogiri::HTML(fetch(url).body, nil, 'UTF-8').at_css('#contents')
  end

  def localize_images(element)
    element.css('img').each_with_index.with_object({}) do |(img, index), placeholders|
      img.remove_attribute('style')
      img.parent.remove_attribute('style')

      src = img['src']
      next unless src&.start_with?('http')

      filename = download_image(src, index)
      placeholder = "__RIALTO_IMG_PLACEHOLDER_#{index}__"
      img['src'] = placeholder
      placeholders[placeholder] = "<%= image_path 'documentation/#{slug}/#{filename}' %>"
    end
  end

  def download_image(src, index)
    response = fetch(src)
    filename = "img-#{index + 1}.#{extension_for(response, src)}"
    images_dir.join(filename).binwrite(response.body)
    filename
  end

  def extension_for(response, src)
    ext = File.extname(URI(src).path).delete_prefix('.').downcase
    return ext if IMAGE_EXTENSIONS.include?(ext)

    content_type = response['content-type'].to_s.split(';').first
    CONTENT_TYPE_EXTENSIONS.fetch(content_type, 'png')
  end

  # Google sets li, p, header css without qualifiers, which messes with CSS on
  # the rest of the page. Scope it to .doc-content and add line breaks so the
  # output diff is readable.
  def scope_styles(html)
    html
      .gsub('<style type="text/css">', '<style type="text/css">.doc-content {')
      .gsub('</style>', '}</style>')
      .gsub(');', ");\n")
      .gsub('{', "{\n")
      .gsub('}', "\n}")
  end

  def footer
    <<~HTML
      <div class='last-updated mb-4 fst-italic'>
        Last updated: #{Time.zone.today.strftime('%B %d, %Y')}
      </div>
    HTML
  end

  def fetch(target_url)
    uri = URI(target_url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.get(uri.request_uri)
    end
  end
end

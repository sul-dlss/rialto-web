# frozen_string_literal: true

# Workaround for https://github.com/teamcapybara/capybara/issues/2865
#
# Capybara 3.40.0's ChromeDriver#reset! calls the CDP command
# Storage.clearDataForOrigin with origin: '*'. Chrome 158+ rejects '*' as
# "not a valid URL", so every system spec errors during session reset.
#
# This patch replaces that call: cookies are cleared with
# Network.clearBrowserCookies, and any other storage types are cleared for
# the origins the tests actually use.
#
# Remove this file once a Capybara release includes a fix.
module CapybaraChromeResetPatch
  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    types = params[:storageTypes].to_s.split(',')
    super('Network.clearBrowserCookies') if types.delete('cookies')
    return if types.empty?

    test_origins.each do |origin|
      super('Storage.clearDataForOrigin', origin:, storageTypes: types.join(','))
    end
  end

  private

  def test_origins
    [Capybara.app_host, Capybara.current_session.server&.base_url].compact.map do |url|
      uri = URI.parse(url)
      "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end.uniq
  end
end

require 'capybara/selenium/driver'
require 'capybara/selenium/driver_specializations/chrome_driver'
Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetPatch)

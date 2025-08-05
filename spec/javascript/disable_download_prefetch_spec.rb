require 'open3'

RSpec.describe 'disable_download_prefetch.js' do
  it 'blocks download-like links without preventing normal ones' do
    stdout, status = Open3.capture2e('node', '--test', File.join(__dir__, 'disable_download_prefetch.test.js'))
    expect(status.success?).to be(true), stdout
  end
end

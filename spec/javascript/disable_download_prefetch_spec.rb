require 'open3'

RSpec.describe 'disable_download_prefetch.js' do
  def run_node(script)
    Open3.capture3('node', stdin_data: script)
  end

  let(:setup_js) do
    <<~JS
      const { JSDOM } = require('jsdom');
      const fs = require('fs');

      const dom = new JSDOM('<a id="link" href="/"></a>', { url: 'http://example.com/' });
      global.window = dom.window;
      global.document = dom.window.document;
      global.Element = dom.window.Element;
      global.URL = dom.window.URL;
      eval(fs.readFileSync('app/javascript/disable_download_prefetch.js', 'utf8'));
      const link = document.getElementById('link');
    JS
  end

  it 'prevents prefetch for download-like links' do
    js = setup_js + <<~JS
        link.setAttribute('href', '/downloads/123');
        const ev = new window.Event('turbo:before-prefetch', { bubbles: true, cancelable: true });
        link.dispatchEvent(ev);
        console.log(ev.defaultPrevented);
    JS
    out, err, status = run_node(js)
    expect(status.exitstatus).to eq(0), err
    expect(out.strip).to eq('true')
  end

  it 'allows prefetch for normal internal links' do
    js = setup_js + <<~JS
        link.setAttribute('href', '/about');
        const ev = new window.Event('turbo:before-prefetch', { bubbles: true, cancelable: true });
        link.dispatchEvent(ev);
        console.log(ev.defaultPrevented);
    JS
    out, err, status = run_node(js)
    expect(status.exitstatus).to eq(0), err
    expect(out.strip).to eq('false')
  end

  it 'ignores external links' do
    js = setup_js + <<~JS
        link.setAttribute('href', 'https://external.test/file.pdf');
        const ev = new window.Event('turbo:before-prefetch', { bubbles: true, cancelable: true });
        link.dispatchEvent(ev);
        console.log(ev.defaultPrevented);
    JS
    out, err, status = run_node(js)
    expect(status.exitstatus).to eq(0), err
    expect(out.strip).to eq('false')
  end

  it 'respects opt-in attribute to allow prefetch' do
    js = setup_js + <<~JS
        link.setAttribute('href', '/downloads/123');
        link.dataset.allowDownloadPrefetch = 'true';
        const ev = new window.Event('turbo:before-prefetch', { bubbles: true, cancelable: true });
        link.dispatchEvent(ev);
        console.log(ev.defaultPrevented);
    JS
    out, err, status = run_node(js)
    expect(status.exitstatus).to eq(0), err
    expect(out.strip).to eq('false')
  end
end

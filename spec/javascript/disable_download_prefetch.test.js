const test = require('node:test');
const assert = require('node:assert');

function loadModule() {
  delete require.cache[require.resolve('../../app/javascript/disable_download_prefetch.js')];
  require('../../app/javascript/disable_download_prefetch.js');
}

function setup(href, options = {}) {
  global.__listeners = {};
  global.document = {
    addEventListener(type, handler) {
      global.__listeners[type] = handler;
    }
  };
  global.window = {
    location: {
      href: options.locationHref || 'http://example.com/',
      origin: options.locationOrigin || 'http://example.com'
    }
  };
  class FakeLink {
    constructor(href, dataset = {}) {
      this.href = href;
      this.dataset = dataset;
    }
    getAttribute(name) {
      if (name === 'href') return this.href;
      return null;
    }
    closest() { return this; }
  }
  global.Element = FakeLink;
  loadModule();
  return new FakeLink(href, options.dataset);
}

function dispatch(link) {
  const event = {
    target: link,
    defaultPrevented: false,
    preventDefault() { this.defaultPrevented = true; }
  };
  global.__listeners['turbo:before-prefetch'](event);
  return event.defaultPrevented;
}

test('blocks /downloads/ path', () => {
  const link = setup('/downloads/123');
  assert.strictEqual(dispatch(link), true);
});

test('blocks /resources/:id/download path', () => {
  const link = setup('/resources/99/download');
  assert.strictEqual(dispatch(link), true);
});

test('blocks common file extensions', () => {
  const link = setup('/files/report.pdf');
  assert.strictEqual(dispatch(link), true);
});

test('blocks when query param download=1', () => {
  const link = setup('/files?id=5&download=1');
  assert.strictEqual(dispatch(link), true);
});

test('allows regular internal links', () => {
  const link = setup('/about');
  assert.strictEqual(dispatch(link), false);
});

test('allows external links', () => {
  const link = setup('https://example.org/downloads/123');
  assert.strictEqual(dispatch(link), false);
});

test('allows opt-in via data-allow-download-prefetch', () => {
  const link = setup('/downloads/123', { dataset: { allowDownloadPrefetch: 'true' } });
  assert.strictEqual(dispatch(link), false);
});

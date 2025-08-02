/**
 * disable_download_prefetch.js
 *
 * Prevents Turbo from prefetching internal links that look like file downloads
 * (e.g. /downloads/123, *.pdf) to avoid inflating download counts. Adjust the
 * DOWNLOAD_RULES constant below to add or remove path patterns or extensions.
 * To completely disable Turbo's hover prefetch for a page, add
 * `<meta name="turbo-prefetch" content="false">` in the HTML.
 *
 * Manual verification:
 *   - Hover an internal `/downloads/123` link → network shows no prefetch request.
 *   - Hover a normal internal page link → prefetch still happens.
 *   - Hover an external link → no interception.
 *   - Add `data-allow-download-prefetch="true"` to a link → prefetch proceeds.
 */

(() => {
  const DOWNLOAD_RULES = {
    // Paths that should be treated as downloads
    pathPatterns: [
      /^\/downloads\//i,
      /^\/resources\/\d+\/download/i,
    ],
    // File extensions typically used for downloads
    extensionRegex: /\.(pdf|zip|csv|xlsx?|pptx?|docx?)(?:$|\?)/i,
  };

  let attached = false;

  function isInternal(url) {
    return url.origin === window.location.origin;
  }

  function looksLikeDownload(url) {
    if (DOWNLOAD_RULES.pathPatterns.some((re) => re.test(url.pathname))) {
      return true;
    }
    if (DOWNLOAD_RULES.extensionRegex.test(url.pathname)) {
      return true;
    }
    if (url.searchParams.get('download') === '1') {
      return true;
    }
    return false;
  }

  function handlePrefetch(event) {
    const target = event.target;
    if (!(target instanceof Element)) return;
    const link = target.closest('a[href]');
    if (!link) return;

    const url = new URL(link.getAttribute('href'), window.location.href);
    if (!isInternal(url)) return;
    if (link.dataset.allowDownloadPrefetch === 'true') return;

    if (looksLikeDownload(url)) {
      event.preventDefault();
    }
  }

  function attach() {
    if (attached) return;
    document.addEventListener('turbo:before-prefetch', handlePrefetch, true);
    attached = true;
  }

  attach();
})();


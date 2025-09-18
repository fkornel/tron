const {chromium} = require('playwright');
(async () => {
  try {
    console.log('Launching Chromium...');
    const browser = await chromium.launch({args:['--no-sandbox','--disable-dev-shm-usage']});
    const context = await browser.newContext();
    const page = await context.newPage();
    page.on('console', msg => console.log('BROWSER CONSOLE:', msg.text()));
    page.on('pageerror', err => console.log('PAGE ERROR:', err.toString()));
    await page.goto('http://localhost:8081/', {waitUntil: 'networkidle'});

    const fetchRes = await page.evaluate(async () => {
      try {
        const r = await fetch('/');
        const t = await r.text();
        return {status: r.status, text: t};
      } catch (e) {
        return {error: String(e)};
      }
    });
    console.log('PAGE FETCH RESULT:', fetchRes);

    // Attempt to dynamically import the wasm module and call greet()
    const wasmRes = await page.evaluate(async () => {
      try {
        let mod;
        // try both root and /static paths
        try {
          mod = await import('/frontend_wasm.js');
        } catch (e) {
          try {
            mod = await import('/static/frontend_wasm.js');
          } catch (e2) {
            throw new Error('Import failed: ' + e + ' ; ' + e2);
          }
        }

        // initialize if default export is an init function
        if (typeof mod.default === 'function') {
          await mod.default();
        }

        // call greet if available
        if (typeof mod.greet === 'function') {
          const g = mod.greet();
          return {greet: g};
        }

        return {info: 'module imported, no greet export'};
      } catch (err) {
        return {error: String(err)};
      }
    });

    console.log('WASM IMPORT RESULT:', wasmRes);

    await page.waitForTimeout(1000);
    await browser.close();
    process.exit(0);
  } catch (e) {
    console.error('ERROR:', e);
    process.exit(2);
  }
})();

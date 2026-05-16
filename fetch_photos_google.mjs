import puppeteer from './node_modules/puppeteer/lib/esm/puppeteer/puppeteer.js';
import http from 'http';
import https from 'https';

const BE = 'http://localhost:8080';
const BLOCKED = ['google', 'gstatic', 'googleapis', 'googleusercontent', 'googleadservices', 'ggpht'];

async function googleImageUrls(browser, query) {
  const page = await browser.newPage();
  try {
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36');
    await page.goto(`https://www.google.com/search?q=${encodeURIComponent(query)}&tbm=isch&hl=en`, {
      waitUntil: 'networkidle2', timeout: 25000
    });

    const urls = await page.evaluate((blocked) => {
      const found = new Set();
      const re = /https?:\/\/[^\s"'\\<>]{30,300}\.(?:jpg|jpeg|png|webp)/gi;
      for (const s of document.querySelectorAll('script')) {
        let m;
        const txt = s.textContent || '';
        while ((m = re.exec(txt)) !== null) {
          const u = m[0];
          if (!blocked.some(b => u.includes(b))) found.add(u);
        }
      }
      return [...found];
    }, BLOCKED);

    return urls;
  } finally {
    await page.close();
  }
}

function download(url) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https') ? https : http;
    const req = mod.get(url, {
      headers: { 'User-Agent': 'Mozilla/5.0', 'Accept': 'image/*,*/*' },
      timeout: 15000
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return download(res.headers.location).then(resolve).catch(reject);
      if (res.statusCode !== 200) return reject(new Error(`HTTP ${res.statusCode}`));
      const ct = (res.headers['content-type'] || '').split(';')[0].trim();
      if (!ct.startsWith('image/')) return reject(new Error(`not image: ${ct}`));
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => {
        const buf = Buffer.concat(chunks);
        if (buf.length < 5000) return reject(new Error(`too small`));
        resolve({ buffer: buf, contentType: ct });
      });
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')); });
  });
}

async function upload(itemId, buffer, contentType) {
  const ext = contentType.replace('image/', '').replace('jpeg', 'jpg').split('+')[0] || 'jpg';
  const boundary = '----B' + Math.random().toString(36).slice(2);
  const head = Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="files"; filename="p${itemId}.${ext}"\r\nContent-Type: ${contentType}\r\n\r\n`);
  const tail = Buffer.from(`\r\n--${boundary}--\r\n`);
  const body = Buffer.concat([head, buffer, tail]);
  return new Promise((resolve, reject) => {
    const req = http.request(`${BE}/api/items/${itemId}/photos`, {
      method: 'POST',
      headers: { 'Content-Type': `multipart/form-data; boundary=${boundary}`, 'Content-Length': body.length }
    }, res => { res.resume(); resolve(res.statusCode); });
    req.on('error', reject);
    req.write(body); req.end();
  });
}

async function getItems() {
  return new Promise((resolve, reject) => {
    http.get(`${BE}/api/items`, res => {
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve(JSON.parse(Buffer.concat(chunks).toString())));
    }).on('error', reject);
  });
}

async function run() {
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  try {
    const all = await getItems();
    const catalog = all.filter(i => !i.dealId);

    // One search per unique product name
    const groups = new Map();
    for (const item of catalog) {
      if (!groups.has(item.name)) groups.set(item.name, []);
      groups.get(item.name).push(item);
    }
    console.log(`${catalog.length} items, ${groups.size} unique names\n`);

    let ok = 0, fail = 0;

    for (const [name, items] of groups) {
      const query = `${name} build material`;
      process.stdout.write(`[${items.length}x] "${name}" ... `);

      let result = null;
      try {
        const urls = await googleImageUrls(browser, query);
        for (const url of urls.slice(0, 12)) {
          try { result = await download(url); break; } catch {}
        }
      } catch (e) {
        process.stdout.write(`error: ${e.message}\n`);
        fail += items.length; continue;
      }

      if (!result) { process.stdout.write(`✗ no image\n`); fail += items.length; continue; }

      let uploaded = 0;
      for (const item of items) {
        const s = await upload(item.id, result.buffer, result.contentType);
        if (s === 200 || s === 201) uploaded++;
      }
      process.stdout.write(`✓ ${uploaded}/${items.length} (${(result.buffer.length / 1024).toFixed(0)}KB)\n`);
      ok += uploaded;

      await new Promise(r => setTimeout(r, 1200));
    }

    console.log(`\nDone — ${ok} uploaded, ${fail} failed`);
  } finally {
    await browser.close();
  }
}

run().catch(console.error);

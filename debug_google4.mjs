import puppeteer from './node_modules/puppeteer/lib/esm/puppeteer/puppeteer.js';
import https from 'https';
import http from 'http';

const BLOCKED = ['google', 'gstatic', 'googleapis', 'googleusercontent', 'googleadservices', 'ggpht'];

function download(url) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https') ? https : http;
    const req = mod.get(url, {
      headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'Accept': 'image/*,*/*' },
      timeout: 10000
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return download(res.headers.location).then(resolve).catch(reject);
      const ct = (res.headers['content-type'] || '').split(';')[0].trim();
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, ct, size: Buffer.concat(chunks).length }));
    });
    req.on('error', e => resolve({ status: 0, error: e.message }));
    req.on('timeout', () => { req.destroy(); resolve({ status: 0, error: 'timeout' }); });
  });
}

const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
const page = await browser.newPage();
await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36');
await page.goto('https://www.google.com/search?q=WD40+Oil+Spray+build+material&tbm=isch&hl=en', { waitUntil: 'networkidle2', timeout: 25000 });

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

console.log(`Found ${urls.length} URLs. Testing first 8:\n`);
for (const url of urls.slice(0, 8)) {
  const result = await download(url);
  console.log(`  ${result.status} ${result.ct || result.error} ${result.size ? result.size+'B' : ''}`);
  console.log(`  ${url.slice(0, 100)}\n`);
}

await browser.close();

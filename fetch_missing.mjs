import https from 'https';
import http from 'http';

const BE = 'http://localhost:8080';

function get(url, opts = {}) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https') ? https : http;
    const req = mod.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept': opts.img ? 'image/*,*/*' : 'text/html,*/*',
        'Referer': 'https://www.bing.com/',
      },
      timeout: 20000
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        const next = res.headers.location.startsWith('http') ? res.headers.location : new URL(res.headers.location, url).href;
        return get(next, opts).then(resolve).catch(reject);
      }
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks) }));
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')); });
  });
}

async function searchImages(query) {
  const url = `https://www.bing.com/images/search?q=${encodeURIComponent(query)}&form=HDRSC2&first=1`;
  const res = await get(url);
  const html = res.body.toString('utf-8');
  const urls = [];
  const re = /mediaurl=([^&"]+)/gi;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      const decoded = decodeURIComponent(m[1]);
      if (decoded.startsWith('http') && /\.(jpg|jpeg|png|webp)/i.test(decoded)) urls.push(decoded);
    } catch {}
  }
  return [...new Set(urls)];
}

async function download(url) {
  const res = await get(url, { img: true });
  if (res.status !== 200) throw new Error(`HTTP ${res.status}`);
  const ct = (res.headers['content-type'] || 'image/jpeg').split(';')[0].trim();
  if (!ct.startsWith('image/')) throw new Error(`not image`);
  if (res.body.length < 5000) throw new Error(`too small`);
  return { buffer: res.body, contentType: ct };
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

async function findImage(...queries) {
  for (const q of queries) {
    const urls = await searchImages(q);
    for (const url of urls.slice(0, 12)) {
      try { return await download(url); } catch {}
    }
  }
  return null;
}

// Retry with alternate queries for the two failed products
const missing = [
  { ids: [11862,11863,11864,11865,11866,11867,11868,11869,11870,11871], name: 'KERACOLOR FF - Premium Grout',
    queries: ['KERACOLOR FF premium grout tile', 'tile grout construction material bag'] },
  { ids: [11874,11894,11913,11932,11951], name: 'Blue Plasterboard (Exterior)',
    queries: ['blue exterior plasterboard drywall board', 'moisture resistant plasterboard blue build material'] },
];

for (const { ids, name, queries } of missing) {
  process.stdout.write(`"${name}" ... `);
  const result = await findImage(...queries);
  if (!result) { process.stdout.write(`✗\n`); continue; }
  let ok = 0;
  for (const id of ids) {
    const s = await upload(id, result.buffer, result.contentType);
    if (s === 200 || s === 201) ok++;
  }
  process.stdout.write(`✓ ${ok}/${ids.length} (${(result.buffer.length/1024).toFixed(0)}KB)\n`);
}
console.log('Done');

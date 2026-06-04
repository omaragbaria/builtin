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
        'Accept': opts.img ? 'image/webp,image/apng,image/*,*/*' : 'text/html,*/*',
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
  if (!ct.startsWith('image/')) throw new Error(`not image: ${ct}`);
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

async function getItems() {
  return new Promise((resolve, reject) => {
    http.get(`${BE}/api/items`, res => {
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve(JSON.parse(Buffer.concat(chunks).toString())));
    }).on('error', reject);
  });
}

async function findImage(query) {
  const urls = await searchImages(query);
  for (const url of urls.slice(0, 12)) {
    try { return await download(url); } catch {}
  }
  return null;
}

async function run() {
  const all = await getItems();
  const catalog = all.filter(i => !i.dealId);

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

    const result = await findImage(query);
    if (!result) { process.stdout.write(`✗\n`); fail += items.length; continue; }

    let uploaded = 0;
    for (const item of items) {
      const s = await upload(item.id, result.buffer, result.contentType);
      if (s === 200 || s === 201) uploaded++;
    }
    process.stdout.write(`✓ ${uploaded}/${items.length} (${(result.buffer.length / 1024).toFixed(0)}KB)\n`);
    ok += uploaded;

    await new Promise(r => setTimeout(r, 700));
  }

  console.log(`\nDone — ${ok} uploaded, ${fail} failed`);
}

run().catch(console.error);

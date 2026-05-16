import https from 'https';

function get(url, headers = {}) {
  return new Promise((resolve, reject) => {
    https.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept': 'text/html,*/*',
        ...headers
      },
      timeout: 15000
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return get(res.headers.location, headers).then(resolve).catch(reject);
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString('utf-8') }));
    }).on('error', reject);
  });
}

const query = 'WD40 Oil Spray build material';
const url = `https://www.google.com/search?q=${encodeURIComponent(query)}&tbm=isch&hl=en`;
const res = await get(url);

// Find all http occurrences to understand what's in the page
const allHttps = (res.body.match(/https?:\/\//g) || []).length;
console.log('Total https:// occurrences:', allHttps);

// Show a 2000-char window around "encrypted" or img-like patterns
const patterns = ['data:image', 'base64', '.jpg', '.jpeg', '.png', 'gstatic', 'encrypted-tbn'];
for (const p of patterns) {
  const idx = res.body.indexOf(p);
  if (idx >= 0) {
    console.log(`\nFound "${p}" at ${idx}:`);
    console.log(res.body.slice(Math.max(0, idx - 20), idx + 200));
  }
}

// Try Google Images JSON endpoint
const url2 = `https://www.google.com/search?q=${encodeURIComponent(query)}&tbm=isch&hl=en&asearch=ichunk&async=_id:rg_s,_pms:s,_fmt:pc`;
const res2 = await get(url2);
console.log('\n\nJSON endpoint status:', res2.status, 'length:', res2.body.length);
// Look for image urls in JSON
const jsonUrls = (res2.body.match(/https?:\/\/[^\\"]{30,200}\.(?:jpg|jpeg|png|webp)/gi) || []);
console.log('Image URLs in JSON endpoint:', jsonUrls.length);
jsonUrls.slice(0,5).forEach(u => console.log(' ', u.slice(0,120)));

import https from 'https';

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept': 'text/html,*/*'
      },
      timeout: 15000
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return get(res.headers.location).then(resolve).catch(reject);
      }
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString('utf-8') }));
    }).on('error', reject);
  });
}

const query = 'WD40 Oil Spray product';
const url = `https://www.bing.com/images/search?q=${encodeURIComponent(query)}&form=HDRSC2&first=1`;
const res = await get(url);

// Find imgurl
const idx = res.body.indexOf('imgurl');
console.log('Around imgurl:', res.body.slice(Math.max(0, idx-50), idx+300));

// Look for JSON-like structures with image src
const srcMatch = res.body.match(/src="(https?:\/\/[^"]{20,}\.(?:jpg|jpeg|png|webp)[^"]*)"/gi) || [];
console.log('\nimg src URLs:', srcMatch.length);
srcMatch.slice(0,5).forEach(m => console.log(' ', m));

// Look for turl (thumbnail url) - bing sometimes uses this
const turlCount = (res.body.match(/turl/g)||[]).length;
console.log('\nturl occurrences:', turlCount);

// Find th?id pattern (bing thumbnail)
const thMatch = res.body.match(/th\?id=[^"&\s]{5,100}/gi) || [];
console.log('\nth?id patterns:', thMatch.length);
if (thMatch.length > 0) console.log('Sample:', thMatch[0]);

// Look for mediaurl
const mxMatch = res.body.match(/mediaurl[^,]{3,200}/gi) || [];
console.log('\nmediaurl patterns:', mxMatch.length);
if (mxMatch.length > 0) console.log('Sample:', mxMatch[0].slice(0,150));

// Look for iurl (image url in older bing format)
const iurlMatch = res.body.match(/"iurl":"([^"]+)"/gi) || [];
console.log('\niurl patterns:', iurlMatch.length);
if (iurlMatch.length > 0) console.log('Sample:', iurlMatch[0].slice(0,150));

// Try the Bing images API endpoint
console.log('\n\n--- Trying Bing images async API ---');

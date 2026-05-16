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
console.log('Status:', res.status);
console.log('Body length:', res.body.length);

// Show first 3000 chars
console.log('\n--- First 3000 chars ---');
console.log(res.body.slice(0, 3000));

// Check for murl
const murlCount = (res.body.match(/"murl"/g) || []).length;
console.log('\nmurl occurrences:', murlCount);

// Check for imgurl
const imgurlCount = (res.body.match(/"imgurl"/g) || []).length;
console.log('imgurl occurrences:', imgurlCount);

// Check for m=
const mCount = (res.body.match(/"m":"/g) || []).length;
console.log('"m":" occurrences:', mCount);

// Show any URLs found
const httpMatches = res.body.match(/https?:\/\/[^"'\s]{20,200}\.(jpg|jpeg|png|webp)/gi) || [];
console.log('\nDirect image URLs found:', httpMatches.length);
if (httpMatches.length > 0) console.log('First 3:', httpMatches.slice(0,3));

import https from 'https';

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept': 'text/html,*/*',
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

const query = 'WD40 Oil Spray build material';
const url = `https://www.google.com/search?q=${encodeURIComponent(query)}&tbm=isch&hl=en`;
const res = await get(url);

console.log('Status:', res.status, '  Body length:', res.body.length);

// Pattern 1: full https image URLs in quotes
const pat1 = res.body.match(/https:\/\/[^"'\s]{30,300}\.(?:jpg|jpeg|png|webp)/gi) || [];
console.log('\nPattern1 (raw https .jpg/.png URLs):', pat1.length);
pat1.slice(0,5).forEach(u => console.log(' ', u.slice(0,120)));

// Pattern 2: Google's \x22 encoded URLs inside script blocks
const pat2 = [];
const re2 = /\\x22(https:\/\/[^\\]{30,300}\.(?:jpg|jpeg|png|webp))\\x22/gi;
let m2;
while ((m2 = re2.exec(res.body)) !== null) pat2.push(m2[1]);
console.log('\nPattern2 (\\x22 encoded):', pat2.length);
pat2.slice(0,3).forEach(u => console.log(' ', u.slice(0,120)));

// Pattern 3: ou": patterns (Google image JSON)
const pat3 = [];
const re3 = /"ou":"(https:\/\/[^"]+\.(?:jpg|jpeg|png|webp)[^"]*)"/gi;
let m3;
while ((m3 = re3.exec(res.body)) !== null) pat3.push(m3[1]);
console.log('\nPattern3 ("ou": image result URLs):', pat3.length);
pat3.slice(0,3).forEach(u => console.log(' ', u.slice(0,120)));

// Pattern 4: imgurl= (like bing but google)
const pat4 = [];
const re4 = /imgurl=(https?:\/\/[^&"]{30,}\.(?:jpg|jpeg|png|webp))/gi;
let m4;
while ((m4 = re4.exec(res.body)) !== null) pat4.push(decodeURIComponent(m4[1]));
console.log('\nPattern4 (imgurl= param):', pat4.length);
pat4.slice(0,3).forEach(u => console.log(' ', u.slice(0,120)));

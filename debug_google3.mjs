import puppeteer from './node_modules/puppeteer/lib/esm/puppeteer/puppeteer.js';

const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
const page = await browser.newPage();
await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36');

await page.goto('https://www.google.com/search?q=WD40+Oil+Spray+build+material&tbm=isch&hl=en', {
  waitUntil: 'networkidle2', timeout: 30000
});

const info = await page.evaluate(() => {
  const imgs = Array.from(document.querySelectorAll('img'));
  const allSrcs = imgs.map(i => ({ src: i.src?.slice(0,100), dataSrc: i.getAttribute('data-src')?.slice(0,100) })).filter(i => i.src || i.dataSrc);

  // Grab all script content lengths
  const scripts = Array.from(document.querySelectorAll('script'));
  const scriptInfo = scripts.map(s => s.textContent?.length || 0);

  // Try to find image URLs in scripts
  const found = [];
  for (const s of scripts) {
    const txt = s.textContent || '';
    const matches = txt.match(/https?:\/\/[^\s"'\\]{30,200}\.(?:jpg|jpeg|png|webp)/gi) || [];
    found.push(...matches);
  }

  return {
    title: document.title,
    imgCount: imgs.length,
    allSrcs: allSrcs.slice(0, 10),
    scriptCount: scripts.length,
    scriptSizes: scriptInfo.sort((a,b) => b-a).slice(0,5),
    urlsInScripts: [...new Set(found)].slice(0, 10),
    bodyLength: document.body.innerHTML.length,
    // Check for consent/captcha
    bodySnippet: document.body.innerText.slice(0, 300)
  };
});

console.log(JSON.stringify(info, null, 2));
await browser.close();

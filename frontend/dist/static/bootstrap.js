// Minimal bootstrap (auto-generated placeholder)
// Initializes the frontend placeholder and performs a fetch to the backend root

(async function() {
  console.log("Bootstrap: placeholder initialization");
  try {
    const resp = await fetch('/');
    if (!resp.ok) {
      console.error('Bootstrap fetch failed:', resp.status);
      return;
    }
    const text = (await resp.text()).trim();
    console.log(text);
  } catch (err) {
    console.error('Bootstrap fetch error:', err);
  }
})();

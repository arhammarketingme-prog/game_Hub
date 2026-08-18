/* ============================================================
   ADVERTISING SERVICE LAYER
   No real ad network is connected yet. This renders clearly
   labeled placeholder slots so the layout, timing, and UX are
   correct on day one — swap `AdService.provider` for a real
   SDK call (AdMob, IronSource, etc.) later without touching
   any page markup. Works identically whether the page is open
   in a browser tab or running as an installed PWA — both load
   the same web content, so ads appear in both automatically
   once a real network is wired in.
   ============================================================ */

const AdService = {
  provider: null, // e.g. 'admob' once connected — see supabase_schema.sql ad_events table

  /** Renders a banner placeholder into the given container id. */
  showBanner(containerId, label){
    const el = document.getElementById(containerId);
    if(!el) return;
    if(this.provider){
      // real network render call goes here
      return;
    }
    el.innerHTML = `
      <div class="ad-slot">
        <span class="ad-slot-label">AD SPACE</span>
        <span class="ad-slot-sub">${label || 'Banner placeholder — connects once an ad network is live'}</span>
      </div>`;
  },

  /** Shows a skippable pre-game interstitial, then calls onDone(). */
  showInterstitial(onDone){
    if(this.provider){
      // real network interstitial call goes here, then onDone()
      onDone();
      return;
    }
    const overlay = document.createElement('div');
    overlay.className = 'ad-interstitial';
    overlay.innerHTML = `
      <div class="ad-interstitial-card">
        <span class="ad-slot-label">AD SPACE</span>
        <div class="ad-interstitial-title">Pre-game advertisement</div>
        <div class="ad-interstitial-sub">Placeholder — real ads appear here once a network is connected.</div>
        <button class="ad-skip" id="adSkipBtn" disabled>Skip in <span id="adSkipCount">3</span>s</button>
      </div>`;
    document.body.appendChild(overlay);

    let n = 3;
    const skipBtn = overlay.querySelector('#adSkipBtn');
    const countEl = overlay.querySelector('#adSkipCount');
    const tick = setInterval(() => {
      n--;
      if(n <= 0){
        clearInterval(tick);
        skipBtn.disabled = false;
        skipBtn.textContent = 'Continue ▶';
      } else {
        countEl.textContent = n;
      }
    }, 1000);

    skipBtn.addEventListener('click', () => {
      overlay.remove();
      onDone();
    });
  }
};

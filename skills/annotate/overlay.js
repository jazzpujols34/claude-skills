/* annotate-overlay — drop-in inline-annotation layer for HTML artifacts.
   Lets a human click or select any part of an agent-generated HTML page,
   leave inline notes, and copy them back as a ready-to-paste prompt.
   Self-contained, zero dependencies, zero network. Notes persist in
   localStorage keyed by filename.

   Credit: inspired by Kun Chen's Lavish (the file-path-keyed annotation
   loop). This is an independent, dependency-free reimplementation — no
   server, no telemetry. Inline this whole file in a <script> tag before
   </body>. */
(function () {
  if (window.__annotateLoaded) return;
  window.__annotateLoaded = true;

  const FILE = decodeURIComponent(location.pathname.split('/').pop() || '') || 'artifact.html';
  // Storage is keyed by filename so notes persist across regenerations while you iterate.
  // wrap.py --rev bumps an optional revision suffix so a regeneration can start clean
  // (e.g. after the author has addressed and resolved the previous round of notes).
  const STORE = '__annot__:' + FILE + (window.__annotRev ? ':' + window.__annotRev : '');
  let notes = [];
  try { notes = JSON.parse(localStorage.getItem(STORE) || '[]'); } catch (_) { notes = []; }
  let armed = false;
  let pendingSel = '';
  const save = () => { try { localStorage.setItem(STORE, JSON.stringify(notes)); } catch (_) {} };
  const esc = s => (s || '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

  const style = document.createElement('style');
  style.textContent = `
    .__an-btn{position:fixed;right:18px;bottom:18px;z-index:2147483000;background:#1f6f54;color:#fff;
      border:none;border-radius:999px;padding:11px 16px;font:600 13px/1 system-ui,sans-serif;cursor:pointer;
      box-shadow:0 4px 14px rgba(0,0,0,.25)}
    .__an-btn.on{background:#b3402f}
    .__an-panel{position:fixed;right:18px;bottom:64px;z-index:2147483000;width:332px;max-height:72vh;
      display:none;flex-direction:column;background:#fff;color:#1d1c1a;border:1px solid #ddd;border-radius:14px;
      box-shadow:0 12px 40px rgba(0,0,0,.28);font:13px/1.5 system-ui,sans-serif;overflow:hidden}
    .__an-panel.open{display:flex}
    .__an-head{padding:11px 14px;border-bottom:1px solid #eee;display:flex;gap:8px;align-items:center}
    .__an-head .__an-x{margin-left:auto;cursor:pointer;color:#888;font-size:17px;background:none;border:none;line-height:1}
    .__an-list{overflow-y:auto;padding:8px;flex:1;min-height:60px}
    .__an-empty{color:#999;padding:16px;text-align:center;font-size:12.5px}
    .__an-item{border:1px solid #eee;border-radius:9px;padding:9px;margin:7px 0;background:#faf9f6}
    .__an-meta{font-size:11px;color:#1f6f54;font-weight:700;margin-bottom:3px}
    .__an-snip{font-size:11.5px;color:#666;font-style:italic;margin-bottom:6px;overflow:hidden;
      text-overflow:ellipsis;white-space:nowrap}
    .__an-item textarea{width:100%;border:1px solid #ddd;border-radius:6px;padding:5px 7px;
      font:12.5px/1.45 system-ui,sans-serif;resize:vertical;min-height:42px;box-sizing:border-box}
    .__an-del{color:#b3402f;cursor:pointer;background:none;border:none;font-size:11px;margin-top:4px;padding:0}
    .__an-foot{padding:9px;border-top:1px solid #eee;display:flex;gap:7px}
    .__an-foot button{flex:1;border:none;border-radius:8px;padding:8px;font:600 12px system-ui,sans-serif;cursor:pointer}
    .__an-copy{background:#1f6f54;color:#fff}
    .__an-clear{background:#f0efe9;color:#555}
    .__an-hi{outline:2px dashed #b3402f !important;outline-offset:1px}
    body.__an-armed,body.__an-armed *{cursor:crosshair !important}`;
  document.head.appendChild(style);

  const btn = document.createElement('button');
  btn.className = '__an-btn'; btn.setAttribute('data-annot-ui', '');
  const panel = document.createElement('div');
  panel.className = '__an-panel'; panel.setAttribute('data-annot-ui', '');
  panel.innerHTML =
    `<div class="__an-head"><b>Inline notes</b>` +
    `<span style="color:#999;font-size:11px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:150px">${esc(FILE)}</span>` +
    `<button class="__an-x" title="close">&times;</button></div>` +
    `<div class="__an-list"></div>` +
    `<div class="__an-foot"><button class="__an-copy">Copy as prompt</button><button class="__an-clear">Clear</button></div>`;
  document.body.appendChild(btn); document.body.appendChild(panel);
  const listEl = panel.querySelector('.__an-list');

  function refreshBtn() {
    btn.textContent = (armed ? '✓ Done' : '✎ Annotate') + (notes.length ? ' (' + notes.length + ')' : '');
    btn.classList.toggle('on', armed);
  }
  function render() {
    listEl.innerHTML = '';
    if (!notes.length) {
      listEl.innerHTML = '<div class="__an-empty">Click any part of the page (or select text first), then it becomes a note.</div>';
      refreshBtn(); return;
    }
    notes.forEach((n, i) => {
      const it = document.createElement('div'); it.className = '__an-item'; it.setAttribute('data-annot-ui', '');
      it.innerHTML =
        `<div class="__an-meta">${esc(n.section || '(top)')}</div>` +
        `<div class="__an-snip" title="${esc(n.snippet)}">“${esc(n.snippet)}”</div>` +
        `<textarea placeholder="What should change here?">${esc(n.comment || '')}</textarea>` +
        `<button class="__an-del">delete</button>`;
      it.querySelector('textarea').addEventListener('input', e => { notes[i].comment = e.target.value; save(); });
      it.querySelector('.__an-del').addEventListener('click', () => { notes.splice(i, 1); save(); render(); });
      listEl.appendChild(it);
    });
    refreshBtn();
  }

  function nearestHeading(el) {
    let n = el;
    while (n && n !== document.body) {
      let p = n.previousElementSibling;
      while (p) {
        if (/^H[1-6]$/.test(p.tagName)) return p.textContent.trim();
        const h = p.querySelector && p.querySelector('h1,h2,h3,h4');
        if (h) return h.textContent.trim();
        p = p.previousElementSibling;
      }
      n = n.parentElement;
    }
    return '';
  }
  function snippetFor(el) {
    if (pendingSel) return pendingSel.slice(0, 120);
    const t = (el.textContent || '').trim().replace(/\s+/g, ' ');
    return t.slice(0, 80) || ('<' + el.tagName.toLowerCase() + '>');
  }

  document.addEventListener('mouseup', () => {
    if (armed) pendingSel = (window.getSelection && window.getSelection().toString().trim()) || '';
  }, true);

  document.addEventListener('click', e => {
    if (!armed || e.target.closest('[data-annot-ui]')) return;
    e.preventDefault(); e.stopPropagation();
    notes.push({ section: nearestHeading(e.target), snippet: snippetFor(e.target), comment: '' });
    pendingSel = ''; save(); panel.classList.add('open'); render();
    const last = listEl.querySelector('.__an-item:last-child textarea'); if (last) last.focus();
  }, true);

  let hov = null;
  document.addEventListener('mouseover', e => {
    if (!armed || e.target.closest('[data-annot-ui]')) return;
    if (hov) hov.classList.remove('__an-hi');
    hov = e.target; hov.classList.add('__an-hi');
  });

  btn.addEventListener('click', () => {
    armed = !armed; document.body.classList.toggle('__an-armed', armed);
    if (armed) panel.classList.add('open');
    if (!armed && hov) { hov.classList.remove('__an-hi'); hov = null; }
    render();
  });
  panel.querySelector('.__an-x').addEventListener('click', () => panel.classList.remove('open'));
  panel.querySelector('.__an-clear').addEventListener('click', () => { if (confirm('Clear all notes?')) { notes = []; save(); render(); } });
  panel.querySelector('.__an-copy').addEventListener('click', () => {
    if (!notes.length) { alert('No notes yet.'); return; }
    const body = notes.map((n, i) =>
      `${i + 1}. Section “${n.section || '(top)'}” → on “${n.snippet}”:\n   ${n.comment || '(no comment)'}`).join('\n\n');
    const out = `Revise **${FILE}** based on my inline review notes:\n\n${body}`;
    const ok = () => {
      const b = panel.querySelector('.__an-copy'); b.textContent = 'Copied ✓';
      setTimeout(() => b.textContent = 'Copy as prompt', 1500);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(out).then(ok, () => prompt('Copy your feedback:', out));
    } else {
      prompt('Copy your feedback:', out);  // file:// / non-secure context: clipboard API absent
    }
  });

  render();
})();

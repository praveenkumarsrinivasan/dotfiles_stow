-- ghostty_switcher.lua
-- Fuzzy window/tab switcher for Ghostty, rendered in a hs.webview so we
-- control the styling (glassy translucent, rounded corners, no icons).
--
-- Keyboard:
--   type to fuzzy filter (title + screen name)
--   ↑/↓ or Ctrl+P / Ctrl+N to move selection
--   Enter to focus, ⌘1..9 to jump to the N-th result, Esc to dismiss

local M = {}

M.appName = "Ghostty"

local webview, usercontent
local WIDTH, HEIGHT = 640, 440

local HTML = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body {
    height: 100%;
    width: 100%;
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
    color: #eaeaea;
    overflow: hidden;
  }
  body {
    background: rgba(24, 24, 27, 0.78);
    -webkit-backdrop-filter: blur(28px) saturate(150%);
    backdrop-filter: blur(28px) saturate(150%);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    opacity: 0.95;
  }
  #search {
    width: 100%;
    padding: 18px 22px;
    background: transparent;
    border: none;
    color: #fff;
    font-size: 18px;
    outline: none;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    caret-color: #7aa2f7;
  }
  #search::placeholder { color: rgba(255, 255, 255, 0.35); }
  #list {
    max-height: 360px;
    overflow-y: auto;
    padding: 6px 0;
  }
  #list::-webkit-scrollbar { width: 6px; }
  #list::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }
  .row {
    padding: 9px 22px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    border-left: 2px solid transparent;
  }
  .row.selected {
    background: rgba(122, 162, 247, 0.18);
    border-left-color: #7aa2f7;
  }
  .main { flex: 1; min-width: 0; }
  .title {
    font-size: 14px;
    color: #fff;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .subtitle {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.45);
    margin-top: 2px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .shortcut {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 11px;
    color: rgba(255, 255, 255, 0.4);
    margin-left: 12px;
    padding: 2px 6px;
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 4px;
  }
  .empty {
    padding: 24px;
    text-align: center;
    color: rgba(255, 255, 255, 0.4);
    font-size: 13px;
  }
</style>
</head>
<body>
<input id="search" type="text" placeholder="Search Ghostty windows/tabs…" autofocus spellcheck="false" />
<div id="list"></div>
<script>
  let all = [];
  let filtered = [];
  let selected = 0;

  function post(msg) {
    try { window.webkit.messageHandlers.controller.postMessage(msg); } catch (e) {}
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  }

  function fuzzy(q, text) {
    if (!q) return 0.1;
    const lq = q.toLowerCase();
    const lt = text.toLowerCase();
    let qi = 0, score = 0, last = -2;
    for (let i = 0; i < lt.length && qi < lq.length; i++) {
      if (lt[i] === lq[qi]) {
        score += (i - last === 1) ? 8 : 1;
        if (i === 0 || /\W/.test(lt[i-1])) score += 4;
        last = i;
        qi++;
      }
    }
    return qi === lq.length ? score : -1;
  }

  function render(query) {
    const q = (query || '').trim();
    filtered = all
      .map(c => ({ c, s: fuzzy(q, c.title + ' ' + (c.subtitle || '')) }))
      .filter(x => x.s >= 0)
      .sort((a, b) => b.s - a.s)
      .map(x => x.c);
    selected = 0;
    const list = document.getElementById('list');
    if (!filtered.length) {
      list.innerHTML = '<div class="empty">No matches</div>';
      return;
    }
    list.innerHTML = filtered.map((c, i) => `
      <div class="row${i === selected ? ' selected' : ''}" data-idx="${i}">
        <div class="main">
          <div class="title">${escapeHtml(c.title)}</div>
          <div class="subtitle">${escapeHtml(c.subtitle || '')}</div>
        </div>
        ${i < 9 ? `<div class="shortcut">⌘${i + 1}</div>` : ''}
      </div>
    `).join('');
  }

  function updateSelection() {
    document.querySelectorAll('.row').forEach((el, i) => {
      el.classList.toggle('selected', i === selected);
      if (i === selected) el.scrollIntoView({ block: 'nearest' });
    });
  }

  window.setChoices = function(c) {
    all = c || [];
    document.getElementById('search').value = '';
    render('');
    document.getElementById('search').focus();
  };

  document.getElementById('search').addEventListener('input', e => render(e.target.value));

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
      e.preventDefault();
      post({ action: 'cancel' });
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (filtered[selected]) post({ action: 'pick', winId: filtered[selected].winId });
    } else if (e.key === 'ArrowDown' || (e.ctrlKey && e.key === 'n')) {
      e.preventDefault();
      if (filtered.length) { selected = (selected + 1) % filtered.length; updateSelection(); }
    } else if (e.key === 'ArrowUp' || (e.ctrlKey && e.key === 'p')) {
      e.preventDefault();
      if (filtered.length) { selected = (selected - 1 + filtered.length) % filtered.length; updateSelection(); }
    } else if (e.metaKey && /^[1-9]$/.test(e.key)) {
      e.preventDefault();
      const idx = parseInt(e.key, 10) - 1;
      if (filtered[idx]) post({ action: 'pick', winId: filtered[idx].winId });
    }
  });

  document.addEventListener('click', e => {
    const row = e.target.closest('.row');
    if (row) {
      const idx = parseInt(row.dataset.idx, 10);
      if (filtered[idx]) post({ action: 'pick', winId: filtered[idx].winId });
    }
  });
</script>
</body>
</html>
]]

local function buildChoices()
  local app = hs.application.find(M.appName)
  if not app then return {} end
  local list = {}
  for _, win in ipairs(app:allWindows()) do
    local title = win:title()
    if title and title ~= "" then
      local screen = win:screen()
      table.insert(list, {
        title = title,
        subtitle = (screen and screen:name()) or "",
        winId = win:id(),
      })
    end
  end
  table.sort(list, function(a, b) return a.title:lower() < b.title:lower() end)
  return list
end

local function hide()
  if webview then webview:hide() end
end

local function onMessage(msg)
  local body = msg and msg.body
  if type(body) ~= "table" then return end
  if body.action == "cancel" then
    hide()
  elseif body.action == "pick" and body.winId then
    hide()
    local win = hs.window.get(body.winId)
    if win then win:focus() end
  end
end

local function ensureWebview()
  if webview then return end
  usercontent = hs.webview.usercontent.new("controller")
  usercontent:setCallback(onMessage)

  webview = hs.webview.new({ x = 0, y = 0, w = WIDTH, h = HEIGHT }, {}, usercontent)
    :windowStyle({ "borderless", "closable" })
    :closeOnEscape(false)
    :transparent(true)
    :shadow(true)
    :bringToFront(true)
    :allowTextEntry(true)
    :level(hs.drawing.windowLevels.modalPanel)
    :html(HTML)
end

function M.show()
  local list = buildChoices()
  if #list == 0 then
    hs.alert.show("No " .. M.appName .. " windows found")
    return
  end

  ensureWebview()

  local screen = hs.mouse.getCurrentScreen() or hs.screen.primaryScreen()
  local f = screen:frame()
  webview:frame({
    x = f.x + (f.w - WIDTH) / 2,
    y = f.y + (f.h - HEIGHT) / 3,
    w = WIDTH,
    h = HEIGHT,
  })

  webview:html(HTML)
  webview:show()
  webview:bringToFront(true)

  hs.timer.doAfter(0.08, function()
    if webview then
      webview:evaluateJavaScript("window.setChoices(" .. hs.json.encode(list) .. ")")
    end
  end)
end

return M

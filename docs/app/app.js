
const LUMINARIES = {
    Lumo: { color: '#ed4054', avatar: '/assets/characters/lumo-portrait.png', role: 'Hyperfixation Gremlin' },
    Lila: { color: '#b59aff', avatar: '/assets/characters/lila-portrait.png', role: 'Spooky Poet' },
    Moki: { color: '#ff83bd', avatar: '/assets/characters/moki-portrait.png', role: 'Chaos Gremlin' },
    Nori: { color: '#75d8ef', avatar: '/assets/characters/nori-portrait.png', role: 'Cosmic Weirdo' },
    Pip:  { color: '#57db91', avatar: '/assets/characters/pip-portrait.png', role: 'Speed Demon' }
};

const MAGIC_KEYWORDS = ['transform', 'turn into', 'become', 'change to', 'make it a', 'morph', 'convert'];

let activeView = 'home';
let currentChatLumming = null;
let currentChatName = null;
let isCreating = false;

const API_BASE = '';
let apiAvailable = false;
let capabilityState = null;
let apiToken = '';
let chatVersion = 0;
let sending = false;
const chatDrafts = {};
const chatTranscripts = {};
async function refreshCapabilities() {
    const status = document.getElementById('connection-status');
    try {
        const response = await fetch('/api/v1/capabilities', {cache:'no-store'});
        if (!response.ok) throw Error('Server unavailable');
        capabilityState = await response.json();
        apiToken = capabilityState.token;
        apiAvailable = true;
        const ready = Object.values(capabilityState.characters).filter(c=>c.available).length;
        status.textContent = ready ? `${ready}/5 character models available · Creator preview` : 'Character models offline · Your drafts stay here';
    } catch {
        apiAvailable = false;
        status.textContent = 'Server unavailable · Your drafts stay here';
    }
}
refreshCapabilities();

document.addEventListener('DOMContentLoaded', () => {
    generateFeed();
    generateArtifacts();
});

function generateFeed() {
    const feed = document.getElementById('discovery-feed');
    const adventures = [
        { title: "The Great Quill Quest", text: "Lila is searching for the legendary quill in the Whispering Woods!", author: "Lila (Spooky Poet)", img: "/assets/characters/lila-portrait.png", key: 'Lila' },
        { title: "Moki's Prank Gone Wild", text: "A tiny prank with a magic wand turned everything pink...", author: "Moki (Chaos Gremlin)", img: "/assets/characters/moki-portrait.png", key: 'Moki' },
        { title: "Deep Space Discovery", text: "Lumo discovered a new constellation! Is it part of the mission?", author: "Lumo (Hyperfixation Gremlin)", img: "/assets/characters/lumo-portrait.png", key: 'Lumo' }
    ];
    feed.innerHTML = adventures.map(adv => `
        <div class="feed-card" onclick="openChat('${adv.key}')">
            <div class="text-[10px] uppercase tracking-widest opacity-50 mb-2 font-bold">${adv.author}</div>
            <div class="feed-image-container">
                <img src="${adv.img}">
            </div>
            <h3 class="font-extrabold text-lg mb-1 tracking-tight text-white">${adv.title}</h3>
            <p class="text-sm text-gray-400 line-clamp-2 mb-4 leading-snug">${adv.text}</p>
            <button class="w-full py-3 rounded-xl bg-zinc-800/50 hover:bg-orange-500/20 font-semibold transition-colors border border-white/5">Join Adventure</button>
        </div>
    `).join('');
}

function generateArtifacts() {
    const gallery = document.getElementById('artifact-gallery');
    if (!gallery) return;
    const icons = ['✨', '🖋️', '🎲', '⏸️', '📢', '🌟', '🔮'];
    gallery.innerHTML = icons.map(i => `
        <div class="w-16 h-16 flex-shrink-0 bg-[#0d0d0e] rounded-xl border border-zinc-700 flex items-center justify-center text-2xl">${i}</div>
    `).join('');
}

function showView(viewId) {
    document.querySelector('.view-content').classList.toggle('chat-active', viewId === 'chat');
    const views = ['home', 'chat', 'world', 'profile', 'library', 'creator'];
    views.forEach(v => {
        const el = document.getElementById(v + '-view');
        if (el) {
            el.style.display = 'none';
            el.classList.add('opacity-0', 'scale-95');
            el.classList.remove('opacity-100', 'scale-100');
        }
    });

    const target = document.getElementById(viewId + '-view');
    if (!target) return;
    target.style.display = (viewId === 'chat') ? 'flex' : 'block';
    setTimeout(() => {
        target.classList.remove('opacity-0', 'scale-95');
        target.classList.add('opacity-100', 'scale-100');
        if (viewId === 'chat') scrollToBottom();
    }, 50);

    activeView = viewId;
    if (viewId === 'library') loadLibrary();
    if (viewId === 'creator') loadCreatorJobs();
    if (viewId !== 'library') closeMediaPreview();
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    const activeNav = document.getElementById('nav-' + viewId);
    if (activeNav) activeNav.classList.add('active');
    if (isCreating) toggleCreateMenu();
}

function toggleCreateMenu() {
    const overlay = document.getElementById('create-overlay');
    isCreating = !isCreating;
    overlay.classList.toggle('active', isCreating);
}

function openChat(name) {
    const lumming = LUMINARIES[name];
    if (!lumming) return;
    if (currentChatName) {
        chatDrafts[currentChatName] = document.getElementById('chat-input').value;
        chatTranscripts[currentChatName] = Array.from(document.getElementById('message-scroller').children);
    }
    chatVersion++;
    document.getElementById('chat-state').textContent = 'Ready to imagine';
    currentChatLumming = lumming;
    currentChatName = name.toLowerCase();
    showView('chat');
    document.getElementById('chat-name').textContent = name;
    document.getElementById('chat-avatar').src = lumming.avatar;
    document.getElementById('message-scroller').replaceChildren();
    document.getElementById('chat-input').value = chatDrafts[currentChatName] || '';
    if (chatTranscripts[currentChatName]) document.getElementById('message-scroller').replaceChildren(...chatTranscripts[currentChatName]);
    else appendMessage(`I'm ${name}. What shall we imagine together?`, 'lummings');
    loadAppearance();
    refreshCapabilities();
}

async function sendMessage() {
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    if (!text || !currentChatName || sending) return;
    const version = chatVersion;
    const name = currentChatName;
    const btn = document.querySelector('button[onclick="sendMessage()"]');
    sending = true;
    document.getElementById("chat-state").textContent = "Thinking…";
    btn.disabled = true;
    renderAppearance(true);
    try {
        await refreshCapabilities();
        if (version !== chatVersion) return;
        if (!apiAvailable || !capabilityState?.characters[name]?.available) {
            appendMessage('My conversation model is unavailable. Your draft is still in the box. Connect my local model, then try again.', 'lummings');
            return;
        }
        const response = await fetch('/chat', {
            method:'POST',
            headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken},
            body:JSON.stringify({persona:name,message:text})
        });
        const data = await response.json();
        if (version !== chatVersion) return;
        if (!response.ok || !data.reply) throw Error(data.error || 'No reply received.');
        appendMessage(text, 'user');
        appendMessage(data.reply, 'lummings');
        if (input.value.trim() === text) input.value = '';
    } catch (error) {
        if (version === chatVersion) appendMessage(error.message || 'Could not connect. Your draft is retained.', 'lummings');
    } finally {
        sending = false;
        document.getElementById("chat-state").textContent = "Ready to imagine";
        btn.disabled = false;
        renderAppearance();
    }
}

function extractTransformationTarget(text) {
    const lower = text.toLowerCase();
    for (const k of MAGIC_KEYWORDS) {
        const idx = lower.indexOf(k);
        if (idx !== -1) {
            let t = text.substring(idx + k.length).trim();
            t = t.replace(/^(into|to|as|a|an)\s+/i, '').trim();
            t = t.replace(/^(a|an|the)\s+/i, '').trim();
            return t || 'Magic Object';
        }
    }
    return null;
}

function appendMessage(text, sender) {
    const scroller = document.getElementById('message-scroller');
    const msg = document.createElement('div');
    msg.className = 'msg msg-' + sender;
    if (sender === 'lummings') {
        const portrait = document.createElement('img');
        portrait.src = currentChatLumming.avatar;
        portrait.alt = '';
        const content = document.createElement('span');
        content.textContent = text;
        msg.append(portrait, content);
    } else {
        msg.innerText = text;
    }
    scroller.appendChild(msg);
    scrollToBottom();
}

function scrollToBottom() {
    const s = document.getElementById('message-scroller');
    s.scrollTop = s.scrollHeight;
}

async function performTransformation(target) {
    const stage = document.getElementById('transformation-stage');
    const morphTarget = document.getElementById('morph-target');
    const title = document.getElementById('morph-title');
    const caption = document.getElementById('morph-caption');

    stage.style.display = 'flex';
    title.innerText = 'The Magic is Waking...';
    caption.innerText = '';

    const color = currentChatLumming.color;
    morphTarget.innerHTML = `<path d="M120,40 C80,40 40,80 40,132 C40,184 80,200 120,200 C160,200 200,184 200,132 C200,80 160,40 120,40" fill="${color}" opacity="0.7"/><circle cx="120" cy="120" r="50" fill="white" opacity="0.3"/>`;
    morphTarget.style.transform = 'scale(1) rotate(0deg)';
    morphTarget.style.opacity = '1';

    await delay(1500);
    title.innerText = 'TRANSFORMING...';
    caption.innerText = `Morphing into: ${target}`;
    morphTarget.style.transform = 'scale(3) rotate(720deg)';
    morphTarget.style.opacity = '0';

    await delay(1800);

    const emoji = inferEmoji(target);
    morphTarget.innerHTML = `<text x="50%" y="50%" text-anchor="middle" font-size="120" fill="white">${emoji}</text>`;
    morphTarget.style.transform = 'scale(1) rotate(-360deg)';
    morphTarget.style.opacity = '1';
    title.innerText = 'VISUAL PREVIEW';
    caption.innerText = `${currentChatLumming === LUMINARIES.Lumo ? 'Lumo' : 'Your Lumming'} became: ${target}`;

    if (typeof confetti !== 'undefined') {
        confetti({ particleCount: 120, spread: 70, origin: { y: 0.6 }, colors: [color, '#ffffff', '#ffcf7a'] });
    }

    await delay(3500);
    stage.style.display = 'none';
    appendMessage(`Preview: ${target}. This effect is temporary and is not AI-generated media.`, 'lummings');
    addArtifact(emoji);
}

function inferEmoji(target) {
    const t = target.toLowerCase();
    if (t.includes('dragon')) return '🐉';
    if (t.includes('sword') || t.includes('blade')) return '⚔️';
    if (t.includes('shield')) return '🛡️';
    if (t.includes('wand') || t.includes('magic')) return '🪄';
    if (t.includes('crown')) return '👑';
    if (t.includes('star')) return '⭐';
    if (t.includes('rocket')) return '🚀';
    if (t.includes('tree')) return '🌳';
    if (t.includes('flower')) return '🌸';
    if (t.includes('book')) return '📚';
    if (t.includes('key')) return '🔑';
    if (t.includes('gem') || t.includes('diamond') || t.includes('crystal')) return '💎';
    if (t.includes('fire')) return '🔥';
    if (t.includes('water') || t.includes('ocean')) return '🌊';
    if (t.includes('moon')) return '🌙';
    if (t.includes('sun')) return '☀️';
    return '✨';
}

function addArtifact(emoji) {
    const gallery = document.getElementById('artifact-gallery');
    if (!gallery) return;
    const div = document.createElement('div');
    div.className = 'w-16 h-16 flex-shrink-0 bg-[#0d0d0e] rounded-xl border border-orange-500/50 flex items-center justify-center text-2xl';
    div.innerText = emoji;
    gallery.insertBefore(div, gallery.firstChild);
}

async function startSceneryGeneration(prompt) {
    const stage = document.getElementById('transformation-stage');
    const morphTarget = document.getElementById('morph-target');
    const title = document.getElementById('morph-title');
    const caption = document.getElementById('morph-caption');

    stage.style.display = 'flex';
    title.innerText = 'IMAGINING...';
    caption.innerText = `Building: ${prompt}`;

    let progress = 0;
    morphTarget.innerHTML = '';
    return new Promise(resolve => {
        const interval = setInterval(async () => {
            progress += 3;
            const r = progress * 2.5;
            morphTarget.innerHTML = `
                <defs>
                    <radialGradient id="skyGrad">
                        <stop offset="0%" stop-color="${currentChatLumming.color}" stop-opacity="0.6"/>
                        <stop offset="100%" stop-color="#0d0d0e" stop-opacity="0"/>
                    </radialGradient>
                </defs>
                <circle cx="120" cy="120" r="${r}" fill="url(#skyGrad)" opacity="0.5"/>
                <circle cx="120" cy="120" r="${Math.max(0, r-15)}" fill="none" stroke="white" stroke-width="1" opacity="0.4"/>
                <text x="50%" y="50%" text-anchor="middle" font-size="14" fill="white" opacity="0.8">${progress}%</text>
            `;
            if (progress >= 100) {
                clearInterval(interval);
                morphTarget.innerHTML = `
                    <rect x="0" y="160" width="240" height="80" fill="#2a2a2c"/>
                    <polygon points="0,160 80,80 160,140 240,60 240,160" fill="#1a1a1c"/>
                    <circle cx="190" cy="50" r="20" fill="${currentChatLumming.color}" opacity="0.8"/>
                    <text x="50%" y="220" text-anchor="middle" font-size="40">🏔️✨</text>
                `;
                title.innerText = 'SCENERY PREVIEW';
                caption.innerText = `Temporary preview for "${prompt}".`;
                if (typeof confetti !== 'undefined') confetti({ particleCount: 80, spread: 60, origin: { y: 0.6 } });
                await delay(3000);
                stage.style.display = 'none';
                appendMessage(`Scenery preview: ${prompt}. This demonstration has not generated or saved a world.`, 'lummings');
                resolve();
            }
        }, 80);
    });
}

function startStoryMode(name) {
    toggleCreateMenu();
    openChat(name);
    setTimeout(() => {
        appendMessage(`Let's write a story! Tell me who our story is about and where it begins.`, 'lummings');
    }, 400);
}

function startMoodMode() {
    toggleCreateMenu();
    showView('profile');
    alert("Take a quiet moment. Your Lumming cannot sense your mood; you can tell them how you feel if you want.");
}

function startSceneryMode() {
    toggleCreateMenu();
    openChat('Lumo');
    setTimeout(() => {
        const prompt = window.prompt('Describe a world you want to imagine:');
        if (prompt) {
            appendMessage(prompt, 'user');
            startSceneryGeneration(prompt);
        }
    }, 400);
}

function startComicMode() {
    toggleCreateMenu();
    showView('home');
    alert("Comic Maker: Choose a Lumming and type 'transform into [panel]' to draw their story! (Visual panels coming in v2)");
}

function delay(ms) { return new Promise(r => setTimeout(r, ms)); }

document.getElementById('chat-input').addEventListener('keypress', e => {
    if (e.key === 'Enter') sendMessage();
});

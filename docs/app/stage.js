/* Canonical assets and saved appearance are supplied by the creator gateway. */
let characterRegistry = [];
let savedAppearance = null;
let appearanceRequest = 0;
let appearanceBusy = false;
const studio = document.getElementById('character-studio');
const expressionSelect = document.getElementById('appearance-expression');
const backdropSelect = document.getElementById('appearance-backdrop');
const appearanceStatus = document.getElementById('appearance-status');
const titleCase = text => text[0].toUpperCase() + text.slice(1);

const registryReady = fetch('/api/v1/characters').then(async response => {
    if (!response.ok) throw Error('Character artwork could not load. Refresh to retry.');
    characterRegistry = (await response.json()).characters;
    const picker = document.getElementById('character-picker');
    for (const character of characterRegistry) {
        LUMINARIES[character.name] = {color:character.color, avatar:character.portraits.warm.url, role:character.role};
        const button = document.createElement('button');
        button.type = 'button';
        button.textContent = character.name;
        button.dataset.character = character.id;
        button.setAttribute('aria-pressed', 'false');
        button.addEventListener('click', () => openChat(character.name));
        picker.append(button);
    }
}).catch(error => { appearanceStatus.textContent = error.message; });

function appearanceButtons() {
    document.getElementById('save-appearance').disabled = appearanceBusy || !savedAppearance;
    document.getElementById('undo-appearance').disabled = appearanceBusy || !savedAppearance?.canUndo;
    expressionSelect.disabled = backdropSelect.disabled = appearanceBusy || !savedAppearance;
}

function renderAppearance(thinking = false) {
    const character = characterRegistry.find(c => c.id === currentChatName);
    if (!character || !savedAppearance) return;
    const expression = thinking ? 'curious' : expressionSelect.value;
    const url = (character.portraits[expression] || character.portraits.warm).url;
    const stage = document.getElementById('character-stage');
    stage.dataset.backdrop = backdropSelect.value;
    stage.dataset.thinking = String(thinking);
    document.getElementById('stage-portrait').src = url;
    document.getElementById('stage-portrait').alt = `${character.name} illustrated portrait`;
    document.getElementById('chat-avatar').src = url;
    currentChatLumming.avatar = url;
}

async function loadAppearance() {
    const request = ++appearanceRequest;
    const name = currentChatName;
    savedAppearance = null;
    appearanceBusy = false;
    appearanceButtons();
    appearanceStatus.textContent = 'Loading your saved look…';
    document.getElementById('stage-portrait').removeAttribute('src');
    await registryReady;
    if (request !== appearanceRequest) return;
    const character = characterRegistry.find(c => c.id === name);
    if (!character) return;
    currentChatLumming = LUMINARIES[character.name];
    studio.style.setProperty('--character-color', character.color);
    document.getElementById('stage-heartlight').textContent = character.heartlight;
    document.getElementById('stage-role').textContent = character.role;
    document.querySelectorAll('[data-character]').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.character === name)));
    for (const [select, values] of [[expressionSelect, character.expressions], [backdropSelect, character.backdrops]]) {
        select.replaceChildren(...values.map(value => new Option(titleCase(value), value)));
    }
    try {
        const response = await fetch(`/api/v1/characters/${name}/appearance`);
        if (!response.ok) throw Error('Saved look unavailable. Refresh to retry.');
        const data = await response.json();
        if (request !== appearanceRequest) return;
        applySavedAppearance(data);
    } catch (error) {
        if (request === appearanceRequest) appearanceStatus.textContent = error.message;
    }
}

function applySavedAppearance(data) {
    savedAppearance = data;
    expressionSelect.value = 'warm';
    backdropSelect.value = data.backdrop;
    renderAppearance();
    appearanceButtons();
    appearanceStatus.textContent = data.revision ? `Saved on this device · Version ${data.revision}` : 'Original artwork · Choose an atmosphere';
}

async function saveAppearance(undo = false) {
    if (!savedAppearance || appearanceBusy) return;
    const request = appearanceRequest;
    const name = currentChatName;
    const body = {expectedRevision:savedAppearance.revision};
    if (!undo) Object.assign(body, {expression:savedAppearance.expression, backdrop:backdropSelect.value});
    appearanceBusy = true;
    appearanceButtons();
    appearanceStatus.textContent = undo ? 'Restoring previous look…' : 'Saving your look…';
    try {
        await refreshCapabilities();
        if (request !== appearanceRequest) return;
        const response = await fetch(`/api/v1/characters/${name}/appearance${undo ? '/undo' : ''}`, {
            method:'POST', headers:{'Content-Type':'application/json', 'X-Lummings-Token':apiToken}, body:JSON.stringify(body)
        });
        const data = await response.json();
        if (request !== appearanceRequest) return;
        if (response.status === 409 && data.appearance) applySavedAppearance(data.appearance);
        if (!response.ok) throw Error(data.error || 'Could not save. Try again.');
        applySavedAppearance(data);
    } catch (error) {
        if (request === appearanceRequest) appearanceStatus.textContent = error.message;
    } finally {
        if (request === appearanceRequest) { appearanceBusy = false; appearanceButtons(); }
    }
}

for (const select of [expressionSelect, backdropSelect]) select.addEventListener('change', () => {
    renderAppearance();
    appearanceStatus.textContent = 'Preview · Save look to keep this choice';
});
document.getElementById('save-appearance').addEventListener('click', () => saveAppearance());
document.getElementById('undo-appearance').addEventListener('click', () => saveAppearance(true));
appearanceButtons();

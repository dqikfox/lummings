let libraryItems = [];
let libraryLoading = false;
let libraryLoaded = false;
let previewItem = null;
const mediaDialog = document.getElementById('media-dialog');
const libraryStatus = document.getElementById('library-status');
const categoryLabel = { 'current-portrait':'Current portrait', concept:'Concept artwork', video:'Film' };

async function loadLibrary(force = false) {
    if (libraryLoading || (libraryLoaded && !force)) return;
    libraryLoading = true;
    libraryStatus.textContent = 'Opening your collection…';
    document.getElementById('library-retry').hidden = true;
    try {
        const response = await fetch('/api/v1/media', {cache:'no-store'});
        if (!response.ok) throw Error('The collection could not load. Your files are still on this device.');
        libraryItems = (await response.json()).items;
        libraryLoaded = true;
        renderLibrary();
    } catch (error) {
        libraryStatus.textContent = error.message;
        document.getElementById('library-retry').hidden = false;
    } finally { libraryLoading = false; }
}

function renderLibrary() {
    const query = document.getElementById('library-search').value.trim().toLowerCase();
    const filter = document.getElementById('library-filter').value;
    const items = libraryItems.filter(item =>
        (filter === 'all' || (filter === 'shortlist' ? item.shortlisted : item.category === filter)) &&
        `${item.title} ${item.source}`.toLowerCase().includes(query));
    const grid = document.getElementById('library-grid');
    grid.replaceChildren();
    for (const item of items) {
        const card = document.createElement('button');
        card.type = 'button'; card.className = 'media-card';
        card.setAttribute('aria-label', `Preview ${item.title}`);
        const image = document.createElement('img');
        image.src = item.previewUrl || (item.kind === 'image' && item.available ? item.url : '');
        image.alt = ''; image.loading = 'lazy';
        const body = document.createElement('div'); body.className = 'media-card-body';
        const tag = document.createElement('span'); tag.className = 'media-tag';
        tag.textContent = (categoryLabel[item.category] || 'Source media') + (item.shortlisted ? ' · Shortlisted' : '');
        const title = document.createElement('h2'); title.textContent = item.title;
        const detail = document.createElement('p');
        detail.textContent = item.available ? `${item.width} × ${item.height}${item.kind === 'video' ? ` · ${Math.round(item.duration || 0)} sec` : ''}` : 'Source file unavailable';
        body.append(tag,title,detail); card.append(image,body);
        card.addEventListener('click', () => openMediaPreview(item)); grid.append(card);
    }
    libraryStatus.textContent = items.length ? `${items.length} of ${libraryItems.length} assets · Originals remain on this device` : (libraryItems.length ? 'No matching assets. Try a different search or collection.' : 'No catalogued media yet.');
}

function closeMediaPreview() {
    document.querySelectorAll('#media-preview video').forEach(video => video.pause());
    if (mediaDialog.open) mediaDialog.close();
    document.getElementById('media-preview').replaceChildren();
    previewItem = null;
}

function openMediaPreview(item) {
    previewItem = item;
    document.getElementById('media-title').textContent = item.title;
    const host = document.getElementById('media-preview'); host.replaceChildren();
    if (item.available) {
        const media = document.createElement(item.kind === 'video' ? 'video' : 'img');
        if (item.kind === 'video') { media.controls = true; media.preload = 'metadata'; media.playsInline = true; if (item.previewUrl) media.poster = item.previewUrl; }
        else media.alt = item.title;
        media.src = item.url;
        media.addEventListener('error', () => { document.getElementById('media-status').textContent = 'This source could not be opened. It may have moved or changed.'; });
        host.append(media);
    }
    document.getElementById('media-detail').textContent = `${categoryLabel[item.category]} · ${item.width} × ${item.height} · ${(item.bytes / 1048576).toFixed(1)} MB` + (item.kind === 'video' ? ` · ${item.hasAudio ? 'Audio track present; content not reviewed' : 'No audio track'}` : '');
    document.getElementById('media-source').textContent = `Source: ${item.source}`;
    document.getElementById('media-status').textContent = item.available ? 'Shortlisting does not replace any character artwork.' : 'Source file unavailable. Restore it to the path shown above.';
    const link = document.getElementById('media-original'); link.href = item.url; link.hidden = !item.available;
    const button = document.getElementById('media-shortlist'); button.textContent = item.shortlisted ? 'Remove from shortlist' : 'Add to shortlist'; button.disabled = false;
    mediaDialog.showModal();
}

document.getElementById('media-shortlist').addEventListener('click', async () => {
    const item = previewItem; if (!item) return;
    const button = document.getElementById('media-shortlist'); button.disabled = true;
    try {
        await refreshCapabilities();
        const response = await fetch(`/api/v1/media/${item.id}/shortlist`, {method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:JSON.stringify({selected:!item.shortlisted})});
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'Could not save your shortlist. Try again.');
        item.shortlisted = data.shortlisted;
        renderLibrary();
        if (previewItem === item) {
            button.textContent = item.shortlisted ? 'Remove from shortlist' : 'Add to shortlist';
            document.getElementById('media-status').textContent = item.shortlisted ? 'Saved to your shortlist on this device.' : 'Removed from shortlist. Original file retained.';
        }
    } catch (error) { if (previewItem === item) document.getElementById('media-status').textContent = error.message; }
    finally { if (previewItem === item) button.disabled = false; }
});
mediaDialog.addEventListener('cancel', event => { event.preventDefault(); closeMediaPreview(); });
document.getElementById('media-close').addEventListener('click', closeMediaPreview);
document.getElementById('library-search').addEventListener('input', renderLibrary);
document.getElementById('library-filter').addEventListener('change', renderLibrary);
document.getElementById('library-retry').addEventListener('click', () => loadLibrary(true));

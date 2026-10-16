/* Reference-based image/video creation and human review. Provider calls require
   both a configured server provider and explicit consent for each submission. */
let creatorCurrentJob = null;
let creatorQuote = null;
const creatorForm = document.getElementById('creator-form');
const creatorStatus = document.getElementById('creator-status');
const creatorConsent = document.getElementById('creator-consent');
const creatorGenerate = document.getElementById('creator-generate');

async function openCreatorStudio() {
    if (isCreating) toggleCreateMenu();
    await registryReady;
    const picker = document.getElementById('creator-character');
    if (!picker.options.length) {
        picker.replaceChildren(...characterRegistry.map(c => new Option(c.name, c.id)));
    }
    if (currentChatName && characterRegistry.some(c => c.id === currentChatName)) picker.value = currentChatName;
    renderCreatorReference();
    showView('creator');
}

function renderCreatorReference() {
    const character = selectedCreatorCharacter();
    if (!character) return;
    const image = document.getElementById('creator-reference');
    image.src = character.portraits.warm.url;
    image.alt = `Approved ${character.name} portrait reference`;
    document.getElementById('creator-reference-name').textContent = character.name;
}

function selectedCreatorCharacter() {
    return characterRegistry.find(c => c.id === document.getElementById('creator-character').value);
}

async function createCreatorJob(kind, sourceJob = null) {
    const character = selectedCreatorCharacter();
    if (!character) throw Error('Choose a Lumming first.');
    const body = {
        requestKey: `ui_${crypto.randomUUID()}`,
        kind,
        character: character.id,
        prompt: document.getElementById('creator-prompt').value.trim(),
        wardrobe: document.getElementById('creator-wardrobe').value,
        scene: document.getElementById('creator-scene').value,
        referenceHash: character.portraits.warm.sha256,
        sourceJob
    };
    const response = await fetch('/api/v1/creator/jobs', {
        method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:JSON.stringify(body)
    });
    const data = await response.json();
    if (!response.ok) throw Error(data.error || 'Could not save this scene draft.');
    await loadCreatorJobs();
    setCurrentCreatorJob(data.id);
    await requestCreatorQuote(data.id);
    return data;
}

async function requestCreatorQuote(jobId) {
    creatorQuote = null;
    creatorGenerate.disabled = true;
    const quoteLabel = document.getElementById('creator-quote');
    if (!capabilityState?.mediaGeneration) {
        quoteLabel.textContent = capabilityState?.mediaProviderConfigured
            ? 'Paid generation is locked. Configure a positive daily USD budget on the server to request a quote.'
            : 'No provider configured, so no charge or quote is available.';
        return;
    }
    quoteLabel.textContent = 'Preparing a five-minute quote…';
    try {
        const response = await fetch(`/api/v1/creator/jobs/${jobId}/quote`, {
            method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:'{}'
        });
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'Could not quote this job.');
        if (creatorCurrentJob !== jobId) return;
        creatorQuote = data;
        quoteLabel.textContent = `Quote: US$${data.amountUSD} · ${data.model} · ${data.basis} · valid 5 minutes`;
        creatorGenerate.disabled = !creatorConsent.checked;
    } catch (error) {
        quoteLabel.textContent = error.message;
    }
}

function setCurrentCreatorJob(jobId) {
    if (creatorCurrentJob !== jobId) {
        creatorConsent.checked = false;
        creatorQuote = null;
    }
    creatorCurrentJob = jobId;
    document.querySelectorAll('[data-job-select]').forEach(button => {
        button.setAttribute('aria-pressed', String(button.dataset.jobSelect === jobId));
    });
    const canGenerate = Boolean(capabilityState?.mediaGeneration && creatorConsent.checked && jobId && creatorQuote?.jobId === jobId);
    creatorGenerate.disabled = !canGenerate;
}

function textNode(tag, className, value) {
    const element = document.createElement(tag);
    if (className) element.className = className;
    element.textContent = value;
    return element;
}

function addCreatorAction(card, label, callback, className = '') {
    const button = textNode('button', `creator-job-action ${className}`, label);
    button.type = 'button';
    button.addEventListener('click', callback);
    card.append(button);
}

async function loadCreatorJobs() {
    const container = document.getElementById('creator-jobs');
    const capability = document.getElementById('creator-capability');
    try {
        const [jobsResponse, capabilityResponse] = await Promise.all([
            fetch('/api/v1/creator/jobs', {cache:'no-store'}), fetch('/api/v1/capabilities', {cache:'no-store'})
        ]);
        if (!jobsResponse.ok || !capabilityResponse.ok) throw Error('Studio data is unavailable. Refresh to retry.');
        const payload = await jobsResponse.json();
        const caps = await capabilityResponse.json();
        capabilityState = caps;
        apiToken = caps.token;
        capability.textContent = caps.mediaGeneration
            ? `Daily media limit: US$${caps.mediaBudget.dailyLimitUSD} · reserved or used: US$${caps.mediaBudget.usedUSD} · available: US$${caps.mediaBudget.availableUSD}. Image: US$${caps.mediaPricing.image.amountUSD}; 5-second 720p animation: US$${caps.mediaPricing.video.amountUSD}. Each send needs your confirmation above.`
            : caps.mediaProviderConfigured
                ? `Provider is configured, but paid generation is locked until a positive daily USD budget is configured. Current limit: US$${caps.mediaBudget.dailyLimitUSD}.`
                : 'Creation service not configured. You can prepare drafts locally; nothing is being sent.';
        creatorGenerate.disabled = !(caps.mediaGeneration && creatorConsent.checked && creatorCurrentJob);
        container.replaceChildren();
        if (!payload.jobs.length) {
            container.append(textNode('p', 'creator-empty', 'Your scene drafts and reviewed creations will appear here.'));
            return;
        }
        for (const job of payload.jobs) {
            const card = document.createElement('article');
            card.className = 'creator-job-card';
            if (job.id === creatorCurrentJob) card.classList.add('is-selected');
            const heading = document.createElement('div');
            heading.className = 'creator-job-heading';
            heading.append(textNode('h3', '', `${job.character[0].toUpperCase()}${job.character.slice(1)} · ${job.kind === 'image' ? 'Scene' : 'Animation'}`));
            heading.append(textNode('span', `creator-state state-${job.state}`, job.state.replaceAll('_', ' ')));
            card.append(heading);
            card.append(textNode('p', 'creator-job-description', job.prompt));
            card.append(textNode('p', 'creator-job-meta', `${job.wardrobe.replaceAll('-', ' ')} · ${job.scene.replaceAll('-', ' ')}`));
            if (job.assetUrl) {
                const media = job.kind === 'video' ? document.createElement('video') : document.createElement('img');
                media.src = job.assetUrl;
                media.className = 'creator-output';
                if (job.kind === 'video') { media.controls = true; media.playsInline = true; }
                else media.alt = `Generated ${job.character} scene awaiting review`;
                card.append(media);
            }
            if (job.error) card.append(textNode('p', 'creator-job-error', job.error));
            if (job.chargeStatus === 'reserved') {
                card.append(textNode('p', 'creator-job-meta', `US$${job.quotedAmountUSD} remains reserved. Check provider history before resolving this charge.`));
            }
            const actions = document.createElement('div');
            actions.className = 'creator-job-actions';
            if (job.state === 'draft') {
                addCreatorAction(actions, 'Select draft', () => { setCurrentCreatorJob(job.id); requestCreatorQuote(job.id); });
            } else if (job.state === 'awaiting_review') {
                addCreatorAction(actions, 'Accept this creation', () => reviewCreatorJob(job.id, 'accept'), 'is-primary');
                addCreatorAction(actions, 'Reject', () => reviewCreatorJob(job.id, 'reject'));
            } else if (job.kind === 'image' && job.state === 'accepted') {
                addCreatorAction(actions, 'Animate this accepted still', () => animateCreatorStill(job));
            }
            if (job.state === 'queued') {
                addCreatorAction(actions, 'Cancel before submission', () => cancelCreatorJob(job.id));
            }
            if (job.state === 'failed' && job.chargeStatus === 'reserved') {
                addCreatorAction(actions, 'Record quoted charge', () => reconcileCreatorJob(job.id, 'charged'));
                addCreatorAction(actions, 'Confirm no charge', () => reconcileCreatorJob(job.id, 'not-charged'));
            }
            card.append(actions);
            container.append(card);
        }
    } catch (error) {
        creatorStatus.textContent = error.message;
    }
}

async function cancelCreatorJob(jobId) {
    creatorStatus.textContent = 'Cancelling before provider submission…';
    try {
        const response = await fetch(`/api/v1/creator/jobs/${jobId}/cancel`, {
            method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:'{}'
        });
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'This job is no longer queued for safe cancellation.');
        creatorStatus.textContent = 'Cancelled before submission. No provider request was sent and the reservation was released.';
        await loadCreatorJobs();
    } catch (error) { creatorStatus.textContent = error.message; }
}

async function reconcileCreatorJob(jobId, decision) {
    const prompt = decision === 'charged'
        ? 'After checking provider history, record the quoted amount as charged?'
        : 'After checking provider history, confirm this job was not charged?';
    if (!window.confirm(prompt)) return;
    try {
        const response = await fetch(`/api/v1/creator/jobs/${jobId}/reconcile`, {
            method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:JSON.stringify({decision})
        });
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'Could not reconcile this charge.');
        creatorStatus.textContent = decision === 'charged'
            ? `Recorded US$${data.quotedAmountUSD} as charged.`
            : 'Marked not charged. The reserved amount is available again.';
        await loadCreatorJobs();
    } catch (error) { creatorStatus.textContent = error.message; }
}

async function reviewCreatorJob(jobId, decision) {
    creatorStatus.textContent = decision === 'accept' ? 'Saving your approval…' : 'Removing this from review…';
    try {
        const response = await fetch(`/api/v1/creator/jobs/${jobId}/review`, {
            method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken}, body:JSON.stringify({decision})
        });
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'Could not update review status.');
        creatorStatus.textContent = decision === 'accept' ? 'Accepted. Your original portrait is unchanged.' : 'Rejected. Your original portrait is unchanged.';
        await loadCreatorJobs();
    } catch (error) { creatorStatus.textContent = error.message; }
}

async function animateCreatorStill(job) {
    document.getElementById('creator-character').value = job.character;
    document.getElementById('creator-prompt').value = job.prompt;
    creatorConsent.checked = false;
    try {
        const video = await createCreatorJob('video', job.id);
        creatorStatus.textContent = 'Animation draft saved from the accepted still. Review the provider disclosure and confirm before generating.';
        setCurrentCreatorJob(video.id);
    } catch (error) { creatorStatus.textContent = error.message; }
}

creatorForm.addEventListener('submit', async event => {
    event.preventDefault();
    creatorStatus.textContent = 'Saving a local scene draft…';
    try {
        const job = await createCreatorJob('image');
        creatorStatus.textContent = `Scene draft saved for ${job.character}. It has not been sent or generated.`;
    } catch (error) { creatorStatus.textContent = error.message; }
});

creatorConsent.addEventListener('change', () => setCurrentCreatorJob(creatorCurrentJob));
creatorGenerate.addEventListener('click', async () => {
    if (!creatorCurrentJob || !creatorConsent.checked || !capabilityState?.mediaGeneration || creatorQuote?.jobId !== creatorCurrentJob) return;
    creatorGenerate.disabled = true;
    creatorStatus.textContent = 'Submitting the confirmed job…';
    try {
        const response = await fetch(`/api/v1/creator/jobs/${creatorCurrentJob}/generate`, {
            method:'POST', headers:{'Content-Type':'application/json','X-Lummings-Token':apiToken},
            body:JSON.stringify({confirmExternalProcessing:true,quoteId:creatorQuote.id})
        });
        const data = await response.json();
        if (!response.ok) throw Error(data.error || 'Generation could not start.');
        creatorStatus.textContent = 'Job submitted. The result will appear here for your review.';
        creatorConsent.checked = false;
        creatorQuote = null;
        await loadCreatorJobs();
        const poll = setInterval(async () => {
            await loadCreatorJobs();
            const statusResponse = await fetch(`/api/v1/creator/jobs/${creatorCurrentJob}`, {cache:'no-store'});
            const current = await statusResponse.json();
            if (!['queued','running'].includes(current.state)) {
                clearInterval(poll);
                creatorStatus.textContent = current.state === 'awaiting_review' ? 'Ready for your review.' : `Job ${current.state}.`;
            }
        }, 1500);
    } catch (error) {
        creatorStatus.textContent = error.message;
        await loadCreatorJobs();
    }
});

document.getElementById('creator-refresh').addEventListener('click', loadCreatorJobs);
document.getElementById('creator-character').addEventListener('change', renderCreatorReference);
loadCreatorJobs();
if (location.hash === '#studio') openCreatorStudio();

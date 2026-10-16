(function (root) {
  'use strict';
  function validate(story) {
    if (!story || !story.id || !story.version || !story.title || !story.nodes || !story.nodes[story.start]) throw new Error('Missing story metadata or start');
    const types = ['narration', 'choice', 'reflection', 'closing'];
    const links = node => [...(node.next ? [node.next] : []), ...(node.skipNext ? [node.skipNext] : []), ...(node.choices || []).map(choice => choice.next)];
    for (const [id, node] of Object.entries(story.nodes)) {
      if (!types.includes(node.type) || !node.text) throw new Error('Invalid node: ' + id);
      if (node.type === 'choice' && (!node.choices?.length || !node.skipNext)) throw new Error('Choice needs options and skip: ' + id);
      if (node.type !== 'closing' && !links(node).length) throw new Error('Dead end: ' + id);
      if (node.choices && new Set(node.choices.map(c => c.id)).size !== node.choices.length) throw new Error('Duplicate choices: ' + id);
      for (const target of links(node)) if (!story.nodes[target]) throw new Error('Missing destination: ' + target);
    }
    // Every reachable node must be able to reach an ending, not just the start.
    const reachable = new Set();
    function visit(id) { if (reachable.has(id)) return; reachable.add(id); links(story.nodes[id]).forEach(visit); }
    visit(story.start);
    let endings = new Set(Object.keys(story.nodes).filter(id => story.nodes[id].type === 'closing'));
    let changed = true;
    while (changed) { changed = false; for (const id of reachable) if (!endings.has(id) && links(story.nodes[id]).some(next => endings.has(next))) { endings.add(id); changed = true; } }
    for (const id of reachable) if (!endings.has(id)) throw new Error('No reachable ending: ' + id);
    return true;
  }
  function start(story) { validate(story); return { nodeId: story.start, history: [], paused: false, finished: false, hint: false }; }
  function transition(story, state, action) {
    if (action.from && action.from !== state.nodeId) return state;
    if (action.type === 'pause') return { ...state, paused: true };
    if (action.type === 'resume') return { ...state, paused: false };
    if (state.paused) return state;
    if (action.type === 'hint') return { ...state, hint: true };
    if (action.type === 'back') { if (!state.history.length) return state; return { ...state, nodeId: state.history.at(-1), history: state.history.slice(0, -1), hint: false, finished: false }; }
    const node = story.nodes[state.nodeId];
    if (action.type === 'finish' && node.type === 'closing') return { ...state, finished: true };
    let next;
    if (action.type === 'choose') next = node.choices?.find(c => c.id === action.choiceId)?.next;
    if (action.type === 'next') next = node.next;
    if (action.type === 'skip') next = node.skipNext;
    if (!next) return state;
    return { ...state, nodeId: next, history: [...state.history, state.nodeId], hint: false, finished: false };
  }
  const api = { validate, start, transition };
  if (typeof module !== 'undefined') module.exports = api;
  else root.LummingStoryEngine = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);

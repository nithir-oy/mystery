require('./qdata.js');
const G = globalThis.GAME;
const assert = require('assert');
const f = {};
G.initFlags(f);

// 1. data integrity
Object.entries(G.QUESTIONS).forEach(([qid, q]) => {
  q.answers.forEach(a => a.forEach(id => assert(G.EVIDENCE[id], qid + ': unknown evidence ' + id)));
  if (q.choices) {
    assert(q.wrong && q.wrong.length === q.choices.length, qid + ': wrong length');
    assert(q.wrong[q.correct] === null, qid + ': wrong[correct] must be null');
    q.wrong.forEach((w, i) => { if (i !== q.correct) assert(w, qid + ': missing wrong msg ' + i); });
    assert(q.answers.length === 0 ? q.slots === 0 : q.answers.every(a => a.length === q.slots), qid + ': slot count');
  }
  assert(q.hints.length === 3, qid + ': 3 hints');
  q.requires.flat().forEach(k => assert(k in f, qid + ': requires unknown flag ' + k));
});
Object.values(G.EVIDENCE).forEach(e => assert(e.flag in f, 'evidence flag not in FLAGS: ' + e.flag));
G.CATEGORIES.forEach(c => c.flags.forEach(k => assert(k in f, 'category flag unknown ' + k)));
console.log('1. data integrity OK');

// 2. stage 1
assert(!G.isUnlocked(f, 'q1a'));
['seen_D1','seen_D2','seen_D3','seen_D6','rin_r1','ren_n1','saeko_t1'].forEach(k => f[k] = true);
assert(G.isUnlocked(f, 'q1a') && G.isUnlocked(f, 'q1b'));
assert(G.judge('q1a', ['D2','D1']).ok);
assert(!G.judge('q1a', ['D1']).ok);
assert(!G.judge('q1a', ['D1','D2','D3']).ok);
let r = G.judge('q1b', ['D3','D6'], 0);
assert(!r.ok && r.slotsOk && !r.choiceOk && r.message.includes('D2'));
assert(G.judge('q1b', ['D6','D3'], 2).ok);
assert(G.hint('q1a', 1).includes('出入り口') && G.hint('q1a', 2).includes('D1') && G.hint('q1a', 9) === G.QUESTIONS.q1a.hints[2]);
assert(G.markWrong(f, 'q1a') === 1 && f.clock_min === 10);
G.markSolved(f, 'q1a'); assert(!f.deduce1);
G.markSolved(f, 'q1b'); assert(f.deduce1);
console.log('2. stage1 OK');

// 3. event order
assert(G.nextEvent(f) === 'ren_shift'); f.ren_shift = true;
assert(G.nextEvent(f) === 'env1_accuse'); f.env1 = true; f.accuse_done = true;
assert(G.nextEvent(f) === 'env2'); f.env2 = true;
assert(G.nextEvent(f) === null);
f.saeko_confess_secret = true;
assert(G.nextEvent(f) === 'saeko_deflect'); f.done_saeko_deflect = true;
assert(G.nextEvent(f) === 'env3'); f.env3 = true;
assert(G.nextEvent(f) === null);
f.seen_D3 = true; f.seen_K5 = true;
assert(G.nextEvent(f) === 'memory_m3'); f.cap_memory = true;
assert(G.nextEvent(f) === null);
assert(G.isViewable(f, 'K5') && G.isViewable(f, 'K1'));
console.log('3. event order OK');

// 4. alternative answers & stage 2-5
f.seen_K1 = f.seen_K2 = f.seen_K3 = f.seen_K4 = true;
f.seen_D9_5 = f.seen_D10 = f.seen_P2 = true; f.p1_inspected = true;
f.saeko_e2 = true; f.saeko_enteric = true; f.ren_n4 = true; f.ren_n5 = true; f.rin_r3 = true;
f.m1 = f.m2 = true; f.obs_rin_no_look = f.obs_ren_look_rin = true;
['q2a','q2b','q2c','q3a','q3b','q3c','q4a1','q4a2','q4b'].forEach(q => assert(G.isUnlocked(f, q), q));
assert(!G.isUnlocked(f, 'q5'));
assert(G.judge('q2a', ['K5','D3']).ok && G.judge('q2a', ['E2','D3']).ok && !G.judge('q2a', ['E2','K5']).ok);
assert(G.judge('q2b', ['D3','E3']).ok);
assert(G.judge('q2c', ['N4','E3','M3'], 1).ok && !G.judge('q2c', ['N4','E3','M3'], 0).ok);
assert(G.judge('q3a', ['P1','K2']).ok && G.judge('q3b', ['K1','K2']).ok);
assert(G.judge('q3c', ['D6','D8','K2'], 2).ok);
assert(G.judge('q4a1', [], 2).ok && !G.judge('q4a1', [], 3).ok);
assert(G.judge('q4a2', ['K1','K3'], 1).ok);
assert(G.judge('q4b', ['K1','K2','D9_5'], 1).ok && !G.judge('q4b', ['K1','K2','D9_5'], 0).ok);
// 4b: K4 alternative via saeko_e5
const g = {}; G.initFlags(g);
['seen_K1','seen_K2','seen_K3','saeko_e5','seen_D9_5','seen_D10','seen_P2'].forEach(k => g[k] = true);
assert(G.isUnlocked(g, 'q4a1'));
['q2a','q2b','q2c','q3a','q3b','q3c','q4a1','q4a2','q4b'].forEach(q => G.markSolved(f, q));
assert(f.deduce2 && f.deduce3 && f.deduce4 && f.protag_clear);
f.ren_b1 = f.ren_b2 = f.ren_b3 = true; G.recompute(f); assert(f.ren_lie_broken);
assert(G.isUnlocked(f, 'q5')); assert(G.judge('q5', ['N5','O2','O1'], 1).ok);
G.markSolved(f, 'q5'); assert(f.deduce5);
console.log('4. stages 2-5 OK');

// 5. final judgement
let m = G.missing(f).map(c => c.name);
console.log('   still missing:', m);
f.rin_plug = f.rin_safe = f.rin_missing6 = true;
assert(G.evidenceEnough(f), 'should be enough: ' + JSON.stringify(G.missing(f).map(c=>c.name)));
assert(G.finalJudge(f, [1,1,1]) === 'clear');
assert(G.finalJudge(f, [2,1,1]) === 'gameover');
assert(G.finalJudge(f, [1,0,1]) === 'gameover');
assert(G.finalJudge(f, [1,1,3]) === 'gameover');
const h = {}; G.initFlags(h);
assert(G.finalJudge(h, [1,1,1]) === 'insufficient' && G.finalJudge(h, [0,0,0]) === 'insufficient');
assert(G.missingHints(h, 2).length === 2 && G.missingHints(h, 2)[0].includes('出入り'));
console.log('5. final judgement OK');

// 6. clock
const c = {clock_min: 0}; G.addClock(c, 75); assert(G.clockText(c) === '1:15'); G.addClock(c, 5); assert(G.clockText(c) === '1:20');
console.log('6. clock OK');
console.log('ALL TESTS PASSED');

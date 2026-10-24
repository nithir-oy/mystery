// 簡易リンター: TyranoScript の .ks に対する静的チェック(実機の代わりではない)
const fs = require('fs');
const path = require('path');
const dir = path.resolve(process.argv[2] || '.');
require(path.join(dir, 'qdata.js'));
const G = globalThis.GAME;
const FLAGS = new Set(G.FLAGS.concat(['capsule_secret','initialized','found_rin','found_ren','found_saeko']));
const files = fs.readdirSync(dir).filter(n => n.endsWith('.ks'));
const builtin = new Set(['macro','endmacro','if','elsif','else','endif','eval','jump','call','return','cm','clearfix','bg','chara_show','chara_hide','chara_hide_all','chara_mod','chara_new','chara_face','chara_config','glink','s','p','r','l','layopt','current','position','font','resetfont','emb','loadjs','free_filter','image','freeimage','wait','playse','ptext','delay','resetdelay','autostart','autostop','stop_keyconfig','start_keyconfig','clearstack','button']);
const userMacros = new Set();
const macroFile = fs.readFileSync(path.join(dir,'macros.ks'),'utf8');
for (const m of macroFile.matchAll(/\[macro name="([^"]+)"\]/g)) userMacros.add(m[1]);
let problems = 0;
const pending = new Set();
const bad = (f, n, msg) => { problems++; console.log(`  NG ${f}:${n}  ${msg}`); };
const labelsByFile = {};
for (const f of files) {
  labelsByFile[f] = new Set([...fs.readFileSync(path.join(dir,f),'utf8').matchAll(/^\*([A-Za-z0-9_]+)/gm)].map(m => '*'+m[1]));
}
for (const f of files) {
  const lines = fs.readFileSync(path.join(dir, f), 'utf8').split('\n');
  let macroDepth = 0, ifDepth = 0;
  lines.forEach((raw, i) => {
    const n = i + 1, line = raw.trim();
    if (!line || line.startsWith(';')) return;
    const stripped = line.replace(/exp="[^"]*"/g, 'exp=""');
    const open = (stripped.match(/\[/g) || []).length, close = (stripped.match(/\]/g) || []).length;
    if (open !== close) bad(f, n, '括弧の数が合わない: ' + line.slice(0, 60));
    for (const m of stripped.matchAll(/\[([a-zA-Z_0-9]+)([^\]]*)\]/g)) {
      const tag = m[1], attrs = m[2];
      if (tag === 'macro') macroDepth++;
      if (tag === 'endmacro') macroDepth--;
      if (tag === 'if') ifDepth++;
      if (tag === 'endif') ifDepth--;
      if (!builtin.has(tag) && !userMacros.has(tag)) bad(f, n, '未知のタグ/マクロ: ' + tag);
      // jump / glink の行き先
      const t = attrs.match(/target="(\*[^"%]+)"/);
      const st = attrs.match(/storage="([^"]+\.ks)"/);
      if (t && (tag === 'jump' || tag === 'glink' || tag === 'qbtn' || tag === 'pick')) {
        const file = st ? st[1] : f;
        if (!labelsByFile[file]) { if (/interview_ren|interview_saeko|deduce|final|event_|confront|ending|gameover/.test(file)) { pending.add(file); } else bad(f, n, '行き先ファイルがない: ' + file); }
        else if (!labelsByFile[file].has(t[1])) bad(f, n, `ラベルがない: ${file} ${t[1]}`);
      }
      if (tag === 'jump' && st && !fs.existsSync(path.join(dir, st[1])) && !['title.ks','scene1.ks'].includes(st[1]) && !/event_|deduce|final|interview_ren|interview_saeko|confront|ending|gameover/.test(st[1])) bad(f, n, 'ファイルがない: ' + st[1]);
      // フラグ名
      for (const fm of attrs.matchAll(/flag="([a-z0-9_]+)"/g)) if (!FLAGS.has(fm[1])) bad(f, n, '未定義のフラグ: ' + fm[1]);
      for (const fm of attrs.matchAll(/id="([A-Za-z0-9_]+)"/g)) {
        if (tag === 'see' && !FLAGS.has('seen_' + fm[1])) bad(f, n, 'seen_ フラグがない: ' + fm[1]);
        if (tag === 'pick' && !G.EVIDENCE[fm[1]]) bad(f, n, '証拠IDがない: ' + fm[1]);
      }
      for (const fm of attrs.matchAll(/(?<![a-z])f\.([A-Za-z0-9_]+)/g)) if (!FLAGS.has(fm[1]) && !['solved','wrong','clock_min'].includes(fm[1])) bad(f, n, '未定義のフラグ: f.' + fm[1]);
    }
    for (const fm of line.matchAll(/(?<![a-z])f\.([A-Za-z0-9_]+)/g)) if (!FLAGS.has(fm[1]) && !['solved','wrong','clock_min','env1','env2','env3'].includes(fm[1])) bad(f, n, '未定義のフラグ: f.' + fm[1]);
    if (/カプセル/.test(line)) bad(f, n, '「カプセル」の語: ' + line.slice(0, 40));
  });
  if (macroDepth !== 0) bad(f, 0, 'macro/endmacro の数が合わない');
  if (ifDepth !== 0) bad(f, 0, 'if/endif の数が合わない');
  console.log(`checked ${f}: ${lines.length} lines`);
}
console.log('保留(これから作るファイル):', [...pending].join(', '));
console.log(problems === 0 ? 'LINT OK' : `LINT: ${problems} problem(s)`);

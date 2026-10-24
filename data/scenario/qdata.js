/* =========================================================
 * qdata.js  ― 推理パートのデータと判定ロジック (v1)
 *
 * 役割
 *  - 証拠マスタ、設問データ、フラグ一覧を1か所にまとめる
 *  - 正誤判定、派生フラグの再計算、イベント発火、最終判定を関数で提供する
 *
 * 使い方(.ks 側)
 *   [loadjs storage="qdata.js"]            ; 置き場所は使用バージョンの公式ドキュメントで確認
 *   [eval exp="GAME.initFlags(f)"]         ; ゲーム開始時に1回
 *   [eval exp="tf.ev = GAME.nextEvent(f)"] ; ハブに戻るたびに
 *
 * 注意: f はセーブ対象のゲーム変数。ここでは f を引数で受け取り、
 *       ファイル内に状態を持たない(ロード後も動くようにするため)。
 * ========================================================= */
(function (global) {
  "use strict";
  var GAME = {};

  /* ---------------------------------------------------------
   * 1. フラグ一覧(initFlags で一括初期化する)
   * --------------------------------------------------------- */
  var seen = ["D1","D2","D3","D4","D5","D6","D7","D8",
              "D9_1","D9_2","D9_3","D9_4","D9_5","D9_6","D10",
              "P1","P2","K1","K2","K3","K4","K5"];
  var FLAGS = [];
  seen.forEach(function (id) { FLAGS.push("seen_" + id); });
  FLAGS = FLAGS.concat([
    "p1_inspected",
    // 神崎 凛
    "rin_r1","rin_r2","rin_r3","rin_r4","rin_r5","rin_r6",
    "rin_pillcase","rin_safe_denial","rin_k1","rin_plug","rin_safe",
    "rin_missing6","rin_slip","rin_confess",
    // 主人公の記憶
    "m1","m2","cap_memory",
    // 一条 蓮
    "ren_n1","ren_n2","ren_n3","ren_n4","ren_n5","ren_n6","ren_d3",
    "ren_last_visit_3m","ren_gate_closed","ren_no_answer","ren_shift",
    "ren_b1","ren_b2","ren_b3","ren_b3_weak","ren_b4",
    "ren_lie_broken","ren_confess_false","ren_reveal",
    // 橘 冴子
    "saeko_t1","saeko_t2","saeko_t3","saeko_t4","saeko_t5","saeko_t6",
    "saeko_lie_prescribe","saeko_d4","saeko_d10","saeko_ban",
    "saeko_confess_secret","saeko_cooperate",
    "saeko_e1","saeko_e2","saeko_e4","saeko_e5","saeko_enteric","saeko_k5",
    // 観察メモ
    "obs_rin_no_look","obs_ren_look_rin","obs_rin_deflect",
    // イベント・封筒
    "env1","accuse_done","env2","done_saeko_deflect","env3",
    // 推理
    "deduce1","deduce2","deduce3","deduce4","deduce5","protag_clear"
  ]);
  GAME.FLAGS = FLAGS;

  GAME.initFlags = function (f) {
    FLAGS.forEach(function (k) { f[k] = false; });
    f.capsule_secret = true;   // 凛の失言まで「カプセル」の語を口にしない
    f.solved = {};             // 設問ごとの正解済み
    f.wrong = {};              // 設問ごとの誤答回数
    f.clock_min = 0;           // ゲーム内の経過時間(分)
  };

  /* ---------------------------------------------------------
   * 2. 証拠マスタ(スロットに入れられるもの)
   *    flag: 入手済みかどうかを示す f のキー
   * --------------------------------------------------------- */
  var E = {};
  function ev(id, name, flag, kind) { E[id] = { id: id, name: name, flag: flag, kind: kind }; }
  ev("D1","現場見取図・出入口一覧","seen_D1","doc");
  ev("D2","出入り記録整理表","seen_D2","doc");
  ev("D3","解剖所見","seen_D3","doc");
  ev("D4","薬物鑑定書","seen_D4","doc");
  ev("D5","盗難届の控え","seen_D5","doc");
  ev("D6","出火原因調査","seen_D6","doc");
  ev("D7","現場写真","seen_D7","doc");
  ev("D8","新聞記事・天気欄","seen_D8","doc");
  ev("D9_1","調書:主人公","seen_D9_1","doc");
  ev("D9_2","調書:神崎 凛","seen_D9_2","doc");
  ev("D9_3","調書:一条 蓮","seen_D9_3","doc");
  ev("D9_4","調書:橘 冴子","seen_D9_4","doc");
  ev("D9_5","友人T氏の証言(金庫)","seen_D9_5","doc");
  ev("D9_6","捜査本部の総括","seen_D9_6","doc");
  ev("D10","金庫内容物リスト","seen_D10","doc");
  ev("P1","焼けた電源タップの残骸(拡大調査)","p1_inspected","item");
  ev("P2","被害者のピルケース","seen_P2","item");
  ev("K1","防犯カメラのクラウド映像","seen_K1","envelope");
  ev("K2","Wi-Fiルーターの接続ログ","seen_K2","envelope");
  ev("K3","金庫の開閉履歴","seen_K3","envelope");
  ev("K4","橘クリニックの薬品台帳","seen_K4","envelope");
  ev("K5","山田氏のカルテ(抜粋)","seen_K5","envelope");
  ev("R3","証言:薬皿は神崎が準備した(凛)","rin_r3","testimony");
  ev("R4","証言:ストーブは帰宅後に旦那様が(凛)","rin_r4","testimony");
  ev("N4","証言:21:58に応答なし(蓮)","ren_n4","testimony");
  ev("N5","証言:神崎さんの話題で目をそらす(蓮)","ren_n5","testimony");
  ev("E1","証言:素錠は30分〜1時間で効く(冴子)","saeko_e1","testimony");
  ev("E2","証言:被膜片は常用薬のものではない(冴子)","saeko_e2","testimony");
  ev("E3","証言:腸溶性の被膜で放出が遅れる(冴子)","saeko_enteric","testimony");
  ev("E5","証言:薬の保管と数(冴子)","saeko_e5","testimony");
  ev("M1","記憶:ストーブが出ていた・冷房は弱かった","m1","memory");
  ev("M2","記憶:19:55に神崎が薬皿を運んだ","m2","memory");
  ev("M3","記憶:薬皿に青と白のカプセルが2つ","cap_memory","memory");
  ev("O1","観察:凛は蓮の証言のとき一度も蓮を見なかった","obs_rin_no_look","obs");
  ev("O2","観察:蓮は追及されて凛をちらりと見た","obs_ren_look_rin","obs");
  ev("O3","観察:凛は冴子に疑いを向けた","obs_rin_deflect","obs");
  GAME.EVIDENCE = E;

  GAME.hasEvidence = function (f, id) {
    return !!(E[id] && f[E[id].flag] === true);
  };
  GAME.listEvidence = function (f) {
    return Object.keys(E).filter(function (id) { return GAME.hasEvidence(f, id); })
      .map(function (id) { return E[id]; });
  };

  /* ---------------------------------------------------------
   * 3. 設問データ
   *    slots   : スロットの数(0なら選択肢のみ)
   *    answers : 正解のスロット組(順不同)。複数あれば、どれか1つで正解
   *    choices : 選択肢(なければ null)、correct : 正解の添字
   *    wrong   : 選択肢ごとの誤答メッセージ(正解は null)
   *    requires: 解禁に必要なフラグ。配列の要素が配列なら「どれか1つ」
   *    hints   : [ヒント1, ヒント2, 独白(答えの半分)]
   * --------------------------------------------------------- */
  var Q = {
    q1a: { stage: 1, text: "20:12以降、屋敷へ出入りした人物はいたか?",
      slots: 2, answers: [["D1","D2"]], choices: null,
      requires: ["seen_D1","seen_D2","seen_D3","seen_D6","rin_r1","ren_n1","saeko_t1"],
      hints: ["出入り口はどこ? その記録は、どう残る?",
              "施錠後は内外どちらでも記録が残る(D1)。20:30以降の記録は?(D2)",
              "20:12以降、誰も出入りしていない。D1とD2を並べてみよう。"],
      success: "20:12に神崎が出た後、屋敷に出入りした人間は、一人もいない。" },
    q1b: { stage: 1, text: "では、22時の服毒と23時の出火は、どうやって起きた?",
      slots: 2, answers: [["D3","D6"]],
      choices: ["犯人は20:30前から屋敷内に潜んでいた","被害者の自殺か事故","毒も火も、時間差で作動する仕掛けが使われた"],
      correct: 2,
      wrong: ["20:30以降、屋敷から出た記録はない。焼け跡にも別の人間は見つかっていない(D2、D9-6)。",
              "被害者は22:30ごろまでに死亡している。22:50ごろのストーブの通電は、本人にはできない(D3、D6)。",
              null],
      requires: ["seen_D1","seen_D2","seen_D3","seen_D6","rin_r1","ren_n1","saeko_t1"],
      hints: ["20:30以降の記録がないなら、犯行はどのように起きた?",
              "被害者の死亡と出火の前後(D3)、点火具の有無(D6)を見直そう。",
              "毒も火も、誰かがその場にいなくても起きる仕組みがあるはずだ。"],
      success: "毒も火も、時間差で動くように仕掛けられていた。" },

    q2a: { stage: 2, text: "D3の被膜片は、被害者の常用薬のものか?",
      slots: 2, answers: [["D3","K5"],["D3","E2"]], choices: null,
      requires: ["seen_K5","cap_memory","saeko_confess_secret"],
      hints: ["被害者は、どんな剤形の薬を処方されていた?",
              "処方された薬の剤形を、K5か冴子の証言で確かめよう。",
              "山田氏の薬は全部素錠。素錠に、あの被膜はない。"],
      success: "被膜片は、常用薬のものじゃない。" },
    q2b: { stage: 2, text: "被膜片が示す、薬の飲ませ方は?",
      slots: 2, answers: [["D3","E3"]], choices: null,
      requires: ["seen_K5","cap_memory","saeko_confess_secret"],
      hints: ["小腸に残っていた被膜には、どんな性質がある?",
              "冴子の証言(腸溶性の被膜)を見直そう。",
              "胃では溶けず、小腸で溶ける被膜で包めば、効くのを遅らせられる。"],
      success: "胃では溶けず、小腸に入ってから溶ける被膜。効くのを2時間近く遅らせられる。" },
    q2c: { stage: 2, text: "実際に、毒が飲まされたのは何時ごろか?",
      slots: 3, answers: [["N4","E3","M3"]],
      choices: ["22:00ごろ","19:55ごろ","21:00ごろ"], correct: 1,
      wrong: ["22時に飲んだなら、21:58に応答できたはずだ(E1)。",
              null,
              "21時に飲んだ記憶も、証拠もない。"],
      requires: ["seen_K5","cap_memory","saeko_confess_secret"],
      hints: ["21:58に応答がなかったのは、なぜ?",
              "効くまでの遅れ(E3)と、19:55の薬皿(M3)を結びつけよう。",
              "19:55に飲んだものが、2時間ほど遅れて効いたと考えると?"],
      success: "19:55、薬皿に載っていたカプセルが毒だった。2時間ほど後に溶けて、21:58にはもう応答できなかった。" },

    q3a: { stage: 3, text: "P1の残骸は何か?",
      slots: 2, answers: [["P1","K2"]], choices: null,
      requires: ["p1_inspected","seen_K1","seen_K2"],
      hints: ["樹脂片の裏側に、何が刻まれていた?",
              "K2に出てくる機器の名前と、照らし合わせよう。",
              "Wi-Fiで予約操作ができる、スマートプラグだ。"],
      success: "これは電源タップじゃない。Wi-Fiで予約操作ができる、スマートプラグだ。" },
    q3b: { stage: 3, text: "そのプラグは、いつ書斎に置かれた?",
      slots: 2, answers: [["K1","K2"]], choices: null,
      requires: ["p1_inspected","seen_K1","seen_K2"],
      hints: ["プラグが最初にWi-Fiへ繋がったのは?",
              "その時刻、山田氏はどこにいた?",
              "初接続は17:52。山田が外出していた時間だ。"],
      success: "初接続は17:52。山田が外出していた時間だ。" },
    q3c: { stage: 3, text: "出火の仕組みは?",
      slots: 3, answers: [["D6","D8","K2"]],
      choices: ["被害者が自分でスイッチを入れた","22:50ごろ、誰かが侵入してスイッチを入れた","プラグの予約で、ストーブに通電した"],
      correct: 2,
      wrong: ["被害者は22:30ごろまでに死亡している(D3)。それに、この暑さでストーブは使わない。",
              "20:30以降、屋敷に出入りした記録はない(D2、K1)。",
              null],
      requires: ["p1_inspected","seen_K1","seen_K2"],
      hints: ["ストーブのスイッチを、誰が、いつ入れた?",
              "被害者は22:30までに死亡している。20:30以降の出入りもない(D3、D2)。",
              "予約機能のあるプラグなら、人がいなくても通電する。"],
      success: "ストーブはプラグに繋がれて、22:50ごろに通電するよう予約されていた。" },

    q4a1: { stage: 4, text: "薬物Xは、何錠足りない?(材料:K4、D10、P2)",
      slots: 0, answers: [],
      choices: ["4錠","5錠","6錠","7錠"], correct: 2,
      wrong: ["30 − 10 − 7 − 7 を、もう一度。", "30 − 10 − 7 − 7 を、もう一度。",
              null, "30 − 10 − 7 − 7 を、もう一度。"],
      requires: ["seen_K1","seen_K2","seen_K3",["seen_K4","saeko_e5"],"seen_D9_5","seen_D10","seen_P2"],
      hints: ["9/4に30錠。就寝前に1錠なら、9/14までに何錠使う?",
              "残りは20錠のはず。瓶とピルケースの残りは?",
              "30 − 10 − 7 − 7 = 6。"],
      success: "6錠。解剖の「通常用量の5〜7倍」と一致する。" },
    q4a2: { stage: 4, text: "その6錠が持ち出された日時は?",
      slots: 2, answers: [["K3","K1"]],
      choices: ["9/8 21:10(山田本人の補充日)","9/14 17:48〜17:52","9/14 19:40ごろ"], correct: 1,
      wrong: ["9/8は、山田本人が週に1回の補充をした日だ。6錠不足は、その後に起きている。",
              null,
              "19:40は、金庫の開閉履歴に記録がない。"],
      requires: ["seen_K1","seen_K2","seen_K3",["seen_K4","saeko_e5"],"seen_D9_5","seen_D10","seen_P2"],
      hints: ["金庫が開いた記録は何件ある?",
              "山田氏の外出時間(K1)と、金庫の開閉時刻(K3)を照らし合わせよう。",
              "17:48は、山田が外出している間だ。"],
      success: "17:48、山田が外出している間に、誰かが金庫を開けて薬を持ち出した。" },
    q4b: { stage: 4, text: "その時間、屋敷にいて、金庫の暗証番号を知っていたのは誰か?",
      slots: 3, answers: [["K1","K2","D9_5"]],
      choices: ["主人公","神崎 凛","一条 蓮","橘 冴子","山田本人"], correct: 1,
      wrong: ["俺が着いたのは19:38だ(K1)。17:48の金庫には触れない。",
              null,
              "蓮は21:58に呼び出しただけだ(K1)。",
              "橘は、屋敷に入った記録がない(K1、D2)。",
              "山田は、16:50〜18:35に外出していた(K1)。"],
      requires: ["seen_K1","seen_K2","seen_K3",["seen_K4","saeko_e5"],"seen_D9_5","seen_D10","seen_P2"],
      hints: ["17:48に屋敷にいた人物は?",
              "17:50〜18:10に屋敷Wi-Fiにいたスマホは?(K2)",
              "暗証番号を知っていた人物を、D9-5で確かめよう。"],
      success: "17:48に屋敷にいて、番号を知っていたのは、神崎凛だけだ。" },

    q5: { stage: 5, text: "蓮は、誰を庇って嘘をついたのか?",
      slots: 3, answers: [["O1","O2","N5"]],
      choices: ["橘 冴子","神崎 凛","自分自身","主人公"], correct: 1,
      wrong: ["蓮は、冴子には一度も視線を向けていない。",
              null,
              "自分を庇うなら、現場に入ったと言って、自分を危険にはしない。",
              "蓮の嘘は、主人公に有利にはなっていない。"],
      requires: ["ren_lie_broken"],
      hints: ["蓮と凛の視線の動きを思い出そう。",
              "凛は蓮を見なかった。蓮は凛を見た。",
              "蓮が庇う相手は、視線の先にいる。"],
      success: "蓮の嘘は、神崎のアリバイを守るためのものだ。" }
  };
  GAME.QUESTIONS = Q;

  // 段階ごとの設問(すべて正解したら deduceN を立てる)
  GAME.STAGES = {
    1: ["q1a","q1b"],
    2: ["q2a","q2b","q2c"],
    3: ["q3a","q3b","q3c"],
    4: ["q4a1","q4a2","q4b"],
    5: ["q5"]
  };

  /* ---------------------------------------------------------
   * 4. 解禁判定・正誤判定
   * --------------------------------------------------------- */
  GAME.isUnlocked = function (f, qid) {
    var q = Q[qid];
    if (!q) { return false; }
    return q.requires.every(function (r) {
      if (Array.isArray(r)) {
        return r.some(function (k) { return f[k] === true; });
      }
      return f[r] === true;
    });
  };

  function sameSet(a, b) {
    if (a.length !== b.length) { return false; }
    var x = a.slice().sort(), y = b.slice().sort();
    for (var i = 0; i < x.length; i++) { if (x[i] !== y[i]) { return false; } }
    return true;
  }

  // selected: スロットに入れた証拠IDの配列、choice: 選んだ選択肢の添字(なければ -1)
  // 戻り値: { ok, slotsOk, choiceOk, message }
  GAME.judge = function (qid, selected, choice) {
    var q = Q[qid];
    var slotsOk = true, choiceOk = true, message = null;
    if (q.slots > 0) {
      slotsOk = q.answers.some(function (ans) { return sameSet(ans, selected || []); });
    }
    if (q.choices) {
      choiceOk = (choice === q.correct);
      if (!choiceOk && q.wrong && q.wrong[choice]) { message = q.wrong[choice]; }
    }
    return { ok: slotsOk && choiceOk, slotsOk: slotsOk, choiceOk: choiceOk, message: message };
  };

  // 誤答の回数に応じたヒント(1回目→ヒント1、2回目→ヒント2、3回目以降→独白)
  GAME.hint = function (qid, wrongCount) {
    var h = Q[qid].hints;
    var i = Math.min(Math.max(wrongCount, 1), h.length) - 1;
    return h[i];
  };

  GAME.markWrong = function (f, qid) {
    f.wrong[qid] = (f.wrong[qid] || 0) + 1;
    f.clock_min += 10;
    return f.wrong[qid];
  };

  GAME.markSolved = function (f, qid) {
    f.solved[qid] = true;
    GAME.recompute(f);
  };

  // 派生フラグの再計算(設問の正解や聞き込みの後に毎回呼ぶ)
  GAME.recompute = function (f) {
    Object.keys(GAME.STAGES).forEach(function (n) {
      f["deduce" + n] = GAME.STAGES[n].every(function (qid) { return f.solved[qid] === true; });
    });
    f.protag_clear = (f.solved.q4b === true);
    f.ren_lie_broken = (f.ren_b1 === true && f.ren_b2 === true && f.ren_b3 === true);
  };

  /* ---------------------------------------------------------
   * 5. イベントの発火(ハブに戻るたびに呼ぶ。上から順に判定)
   * --------------------------------------------------------- */
  GAME.nextEvent = function (f) {
    if (f.deduce1 && !f.ren_shift) { return "ren_shift"; }                 // 6-3 蓮の証言変更
    if (f.ren_shift && !f.accuse_done) { return "env1_accuse"; }           // 封筒①→8-4 糾弾
    if (f.accuse_done && !f.env2) { return "env2"; }                       // 封筒②(K3、K4)
    if (f.saeko_confess_secret && !f.done_saeko_deflect) { return "saeko_deflect"; } // 7-3 群像
    if (f.saeko_confess_secret && f.done_saeko_deflect && !f.env3) { return "env3"; } // 封筒③(K5)
    if (f.env3 && f.seen_D3 && f.seen_K5 && !f.cap_memory) { return "memory_m3"; }    // M3
    return null;
  };

  // 封筒の開封で、閲覧可能になる資料(.ks 側で seen_ を立てる代わりに「閲覧可」にする)
  GAME.ENVELOPES = { env1: ["K1","K2"], env2: ["K3","K4"], env3: ["K5"] };
  GAME.isViewable = function (f, id) {
    if (id === "K1" || id === "K2") { return f.env1 === true; }
    if (id === "K3" || id === "K4") { return f.env2 === true; }
    if (id === "K5") { return f.env3 === true; }
    return true;
  };

  /* ---------------------------------------------------------
   * 6. 最終推理
   * --------------------------------------------------------- */
  GAME.FINAL = {
    F1: { text: "犯人は誰か?", choices: ["主人公","神崎 凛","一条 蓮","橘 冴子"], correct: 1 },
    F2: { text: "毒は、どう飲まされたか?",
          choices: ["22時ごろ、酒に混ぜた","19:55ごろ、薬皿に載せた、遅れて効く薬","20:12までに、食事に混ぜた","被害者が自分で飲んだ"],
          correct: 1 },
    F3: { text: "出火の仕掛けは?",
          choices: ["犯人が22:50ごろ、書斎に入って点けた","プラグの予約で、ストーブに22:50ごろ通電","被害者の消し忘れ","ストーブの故障"],
          correct: 1 }
  };

  GAME.CATEGORIES = [
    { name: "密室の論理",     flags: ["deduce1"],                              hint: "屋敷に出入りできた時間を、整理し直してみろ。" },
    { name: "服毒の時刻",     flags: ["deduce2","cap_memory"],                 hint: "被害者の腹から出たものを、もう一度見ろ。" },
    { name: "時限発火",       flags: ["deduce3"],                              hint: "燃えた書斎の足元に、何が残っていた?" },
    { name: "金庫と薬の欠損", flags: ["deduce4","rin_safe","rin_missing6"],    hint: "薬の数は、合っているのか?" },
    { name: "神崎への追及",   flags: ["rin_plug"],                             hint: "神崎の話の、嘘を探せ。" },
    { name: "橘の嘘",         flags: ["saeko_confess_secret"],                 hint: "薬の出どころを、もう一度確かめろ。" },
    { name: "蓮の偽証",       flags: ["ren_lie_broken","deduce5"],             hint: "5年前と今で、一条の話は同じか?" },
    { name: "主人公の潔白",   flags: ["protag_clear"],                         hint: "自分の足取りを、証拠で証明しろ。" }
  ];

  // 不足しているカテゴリ(上から順)
  GAME.missing = function (f) {
    return GAME.CATEGORIES.filter(function (c) {
      return !c.flags.every(function (k) { return f[k] === true; });
    });
  };
  GAME.evidenceEnough = function (f) { return GAME.missing(f).length === 0; };

  // answers: [F1の添字, F2の添字, F3の添字]
  // 戻り値: "insufficient"(証拠不十分) / "clear"(正解) / "gameover"(ゲームオーバー)
  GAME.finalJudge = function (f, answers) {
    if (!GAME.evidenceEnough(f)) { return "insufficient"; }
    var F = GAME.FINAL;
    var ok = (answers[0] === F.F1.correct) && (answers[1] === F.F2.correct) && (answers[2] === F.F3.correct);
    return ok ? "clear" : "gameover";
  };

  // 証拠不十分のときに表示するヒント(上位 n 件)
  GAME.missingHints = function (f, n) {
    return GAME.missing(f).slice(0, n || 2).map(function (c) { return c.hint; });
  };

  /* ---------------------------------------------------------
   * 7. ゲーム内の時計(演出用)
   * --------------------------------------------------------- */
  GAME.COST = { investigate: 5, question: 10, wrong: 10, insufficient: 30 };
  GAME.addClock = function (f, min) { f.clock_min += min; };
  GAME.clockText = function (f) {
    var m = f.clock_min, h = Math.floor(m / 60), mm = m % 60;
    return h + ":" + (mm < 10 ? "0" : "") + mm;
  };

  global.GAME = GAME;
})(typeof window !== "undefined" ? window : globalThis);

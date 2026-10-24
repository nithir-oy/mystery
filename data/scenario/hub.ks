; =========================================================
; hub.ks ― 調査ハブ(骨組み・未検証)
;
; ・全ての場面(調査、聞き込み、推理、イベント)は、終わったらここへ戻る
; ・戻るたびに、派生フラグの再計算 → イベントの発火判定 → メニュー表示 の順に処理する
; ・動作確認は実機で行うこと(タグの属性は TyranoScript のバージョンで差異あり)
; =========================================================

*hub
[cm]
[clearfix]
[free_filter]

; --- 1. ロジックの読み込みと初期化 ---
; qdata.js の置き場所は、使用バージョンの公式ドキュメントで確認すること
[loadjs storage="qdata.js"]
[if exp="f.initialized !== true"]
  [eval exp="GAME.initFlags(f)"]
  [eval exp="f.initialized = true"]
[endif]

; --- 2. 派生フラグの再計算 ---
[eval exp="GAME.recompute(f)"]

; --- 3. イベントの発火判定(上から順。該当すれば、そのシーンへ) ---
[eval exp="tf.ev = GAME.nextEvent(f)"]
[if exp="tf.ev == 'ren_shift'"][jump storage="event_ren_shift.ks"][endif]
[if exp="tf.ev == 'env1_accuse'"][jump storage="event_env1_accuse.ks"][endif]
[if exp="tf.ev == 'env2'"][jump storage="event_env2.ks"][endif]
[if exp="tf.ev == 'saeko_deflect'"][jump storage="event_saeko_deflect.ks"][endif]
[if exp="tf.ev == 'env3'"][jump storage="event_env3.ks"][endif]
[if exp="tf.ev == 'memory_m3'"][jump storage="event_memory_m3.ks"][endif]

; --- 4. メニュー ---
*menu
[cm]
[bg storage="room_light.jpg" time="300"]
[ptext name="clock" layer="1" x="1000" y="20" size="26" color="white" text="&'経過 ' + GAME.clockText(f) + ' / 12:00'"]

[glink color="btn_01" size="24" x="420" y="150" width="440" text="資料・遺留品を調べる" target="*go_investigate"]
[glink color="btn_01" size="24" x="420" y="230" width="440" text="聞き込みをする" target="*go_interview"]
[glink color="btn_01" size="24" x="420" y="310" width="440" text="推理する" target="*go_deduce"]
[glink color="btn_01" size="24" x="420" y="390" width="440" text="最終推理" target="*go_final"]
[s]

*go_investigate
[jump storage="investigate.ks" target="*start"]

*go_interview
; 人物を選び、各人物の聞き込みファイルへ
[cm]
[glink color="btn_01" size="24" x="420" y="150" width="440" text="神崎 凛" target="*go_rin"]
[glink color="btn_01" size="24" x="420" y="230" width="440" text="一条 蓮" target="*go_ren"]
[glink color="btn_01" size="24" x="420" y="310" width="440" text="橘 冴子" target="*go_saeko"]
[glink color="btn_02" size="22" x="420" y="410" width="440" text="戻る" target="*menu"]
[s]

*go_rin
[jump storage="interview_rin.ks" target="*start"]
*go_ren
[jump storage="interview_ren.ks" target="*start"]
*go_saeko
[jump storage="interview_saeko.ks" target="*start"]

*go_deduce
[jump storage="deduce.ks" target="*start"]

*go_final
[jump storage="final.ks" target="*start"]

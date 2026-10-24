; =========================================================
; macros.ks ― 共通マクロ(未検証)
;
; 使い方: 各ファイルの *start で  [call storage="macros.ks"]  を呼ぶ
; ・マクロ内では mp.パラメータ名 で引数を参照できる
; ・全ファイルは UTF-8 で保存すること
; =========================================================

; ---- 表情の切り替え: [rin f="calm"] のように使う ----
[macro name="rin"]
[chara_mod name="rin" face="%f|normal" time="0"]
[endmacro]

[macro name="ren"]
[chara_mod name="ren" face="%f|normal" time="0"]
[endmacro]

[macro name="saeko"]
[chara_mod name="saeko" face="%f|normal" time="0"]
[endmacro]

; ---- 資料を閲覧済みにする(初回のみ時計を+5分) ----
; [see id="D1"]  →  f.seen_D1 = true
[macro name="see"]
[eval exp="var k = 'seen_' + mp.id; if (!f[k]) { GAME.addClock(f, GAME.COST.investigate); } f[k] = true;"]
[endmacro]

; ---- 質問を済ませたことにする(初回のみ時計を加算) ----
; [first flag="rin_r1" cost="10"]
[macro name="first"]
[eval exp="if (!f[mp.flag]) { GAME.addClock(f, Number(mp.cost || 10)); } f[mp.flag] = true;"]
[endmacro]

; ---- 縦に並べるボタン(tf.y を使って、押した順に下へずらす) ----
; 使う前に [eval exp="tf.y = 100"] で開始位置を決める
[macro name="qbtn"]
[glink color="%color|btn_01" size="22" x="%x|60" y="&tf.y" width="%w|560" text="%text" target="%target"]
[eval exp="tf.y += Number(mp.step || 64)"]
[endmacro]

; ---- 証拠ピッカー用ボタン(入手済みの証拠だけ表示する) ----
; [pick id="D9_5" text="D9-5 友人T氏の証言" target="*pr_D9_5"]
[macro name="pick"]
[if exp="GAME.hasEvidence(f, mp.id)"]
[glink color="btn_01" size="20" x="%x|60" y="&tf.y" width="%w|560" text="%text" target="%target"]
[eval exp="tf.y += Number(mp.step || 58)"]
[endif]
[endmacro]

; ---- 資料ビューア(message1 レイヤーに長文を表示する) ----
; [docopen title="D1 現場見取図・出入口一覧"] ... [p] ... [docclose]
[macro name="docopen"]
[cm]
[layopt layer="message0" visible="false"]
[layopt layer="message1" visible="true"]
[current layer="message1"]
[position layer="message1" left="90" top="40" width="1100" height="640" color="0x101820" opacity="235" margint="30" marginl="40" marginr="40" marginb="30"]
[font size="30" color="0xffd27f" bold="true"]
[emb exp="mp.title"]
[resetfont]
[r][r]
[font size="22" color="0xffffff"]
[endmacro]

[macro name="docclose"]
[cm]
[resetfont]
[layopt layer="message1" visible="false"]
[current layer="message0"]
[endmacro]

[return]

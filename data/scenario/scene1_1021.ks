; =========================================================
; 『12時間の密室：消えた犯人』 メインシナリオ（骨組み・ロジック実装版）
; =========================================================
[cm]
[bg storage="room_dark.jpg" time="1000"]
;[playbgm storage="bgm_suspense.ogg" loop="true"]

;メッセージウィンドウの設定
; [position layer="message0" left=160 top=600 width=1000 height=200 page=fore visible=true]

;文字が表示される領域を調整
; [position layer=message0 page=fore margint="45" marginl="50" marginr="70" marginb="60"]


;メッセージウィンドウの表示
@layopt layer=message0 visible=true

;キャラクターの名前が表示される文字領域
[ptext name="chara_name_area" layer="message0" color="white" size=28 bold=true x=180 y=510]

;上記で定義した領域がキャラクターの名前表示であることを宣言（これがないと#の部分でエラーになります）
[chara_config ptext="chara_name_area"]

; [position layer=message0 width=778 height=193 top=520 left=70 ]
[position layer=message0 width=1000 height=150 top=550 left=70 ]
[position layer=message0 page=fore frame="frame03.png" margint="10" marginl="50" marginr="70" marginb="60"]

【？？？】
「……おい。起きろ……！」[p]

【主人公】
（う、うーん……。頭が割れるように痛い……）[p]

; 明かりがつき、背景切り替えと立ち絵表示
[bg storage="room_light.jpg" time="800"]

[chara_show name="rin" face="anxiety" left="50" top="250" time="500"]
[chara_show name="ren" face="normal" left="300" top="100" time="500"]
[chara_show name="saeko" face="normal" left="850" top="130" time="500"]

【主人公】
（目を開けると……見覚えのない暗い部屋だ。窓はなく、頑丈な鉄の扉……密室か？）[p]
（周りには……見知らぬ男女が3人。全員、困惑と警戒の混ざった表情でこちらを見ている。）[p]

【神崎 凛】
「あなたも目を覚ましたのね。……ここがどこだか、分かる？」[p]

[chara_mod name="ren" face="anger"]
【一条 蓮】
「おまえ、何か知ってんじゃねえのか！？」[p][r]
「ドアは開かねぇし、スマホも圏外だぞ！ 拉致かよ！？」[p]

[chara_mod name="saeko" face="normal"]
【橘 冴子】
「落ち着きなさい。パニックになっても状況は変わらないわ……。」[p]

; スピーカーアナウンス
[playse storage="speaker_noise.ogg"]
【スピーカーの声】
『……聞こえるか、4人の容疑者共。』[p]

[chara_mod name="rin" face="anxiety"]
[chara_mod name="ren" face="anxiety"]
[chara_mod name="saeko" face="anxiety"]
【一条 蓮】
「なっ、なんだ！？ どこから声が……！？」[p]

【スピーカーの声】
『棚の扉を開けろ。そこに【箱】がある。』[p]

【主人公】
（棚を開けると、中に重々しい木箱が置かれていた。箱を開けると、そこには大量の【捜査資料】と新聞記事が入っていた……。）[p]

[chara_mod name="rin" face="anxiety"]
【神崎 凛】
「これ……5年前の資産家・毒殺放火事件の資料……！？」[p]

【スピーカーの声】
『そうだ。その事件の真犯人は、今その部屋にいる4人の中にいる。』[p]

[chara_mod name="saeko" face="anger"]
【橘 冴子】
「なんですって……！？ 馬鹿げているわ！」[p]

【スピーカーの声】
『12時間以内に資料と議論から矛盾を突き、真犯人を特定しろ。』[p]

【スピーカーの声】
『出来なければ……部屋に毒ガスを注入し、全員死亡する。』[p]

[playse storage="door_lock.ogg"]

【主人公】
（狂ってる……！ だが、やるしかない。自分は絶対に犯人じゃない。資料を読み、3人の証言から【矛盾】を見つけ出すんだ！）[p]

; ---------------------------------------------------------
; 変数の初期化（フラグ管理）
; ---------------------------------------------------------
[eval exp="f.read_evidence = false"]
[eval exp="f.talk_rin = false"]
[eval exp="f.talk_ren = false"]
[eval exp="f.talk_saeko = false"]
[eval exp="f.found_ren_shield = false"]
[eval exp="f.found_contradiction = false"]


; ---------------------------------------------------------
; メインループ（探索・話し合い選択）
; ---------------------------------------------------------
*main_loop
[cm]
[chara_hide_all time="300"]
[bg storage="room_light.jpg" time="300"]

【主人公】
（残り時間は少ない。どう行動しようか？）[p]

[glink color="black" target="*read_evidence" text="📜 捜査資料を調べる" x="150" y="100"]
[glink color="black" target="*talk_select" text="🗣️ 容疑者に話を聞く" x="150" y="180"]
[glink color="black" target="*check_status" text="🔍 現在の思考メモを確認する" x="150" y="260"]
[glink color="red" target="*accuse_start" text="⚖️ 犯人を指名する（告発）" x="150" y="340"]
[s]


; ---------------------------------------------------------
; 1. 捜査資料の確認
; ---------------------------------------------------------
*read_evidence
[cm]
【捜査資料：5年前の事件概要】[p]
・被害者：資産家・山田氏（自宅書斎にて遺体で発見）[p]
・死因：毒殺（その後、火災が発生し現場は半焼）[p]
・現場状況：裏口のセキュリティは【20:30に自動施錠】される。[p]
・現場遺留品：【焦げたタイマーの部品】と【被害者の手帳】。[p]
・手帳のメモ：『本日 21:30 甥（一条）と面会予定』[p]
・毒物の情報：主治医（橘）のクリニックから盗まれた特殊な薬物。[p]

[eval exp="f.read_evidence = true"]
【主人公】
（資料の内容は把握した。20:30の自動施錠と、現場のタイマー部品……これが鍵になりそうだ）[p]

[jump target="*main_loop"]


; ---------------------------------------------------------
; 2. 話を聞く対象の選択
; ---------------------------------------------------------
*talk_select
[cm]
【主人公】
（誰に話を聞こうか？）[p]

[glink color="blue" target="*talk_rin" text="神崎 凛（元家政婦）" x="150" y="120"]
[glink color="blue" target="*talk_ren" text="一条 蓮（被害者の甥）" x="150" y="200"]
[glink color="blue" target="*talk_saeko" text="橘 冴子（主治医）" x="150" y="280"]
[glink color="gray" target="*main_loop" text="戻る" x="150" y="360"]
[s]

; --- 神崎 凛との会話 ---
*talk_rin
[cm]
[chara_show name="rin" face="anxiety" left="300" top="100"]
【神崎 凛】
「私を疑っているの？ 私は事件当夜、仕事が終わって【21:00に裏口から普通に帰宅した】だけだわ。火事の煙なんて見ていないし、鍵もかかっていなかったわ！」[p]

[if exp="f.read_evidence == true"]
  【主人公】
  （……待てよ？ 資料には『裏口は20:30に自動施錠される』とあった。21:00に裏口から出られたはずがない！）[p]
  【主人公】
  （神崎のこの証言には、明らかな【矛盾】がある……！）[p]
  [eval exp="f.found_contradiction = true"]
[endif]

[eval exp="f.talk_rin = true"]
[jump target="*talk_select"]

; --- 一条 蓮との会話 ---
*talk_ren
[cm]
[chara_show name="ren" face="anger" left="300" top="100"]
【一条 蓮】
「俺は犯人じゃねぇ！ あの夜は20時から朝までずっとバーで飲んでたんだ！」[p]
[chara_mod name="ren" face="anxiety"]
【一条 蓮】
「くそっ……！ いや、待てよ……。もしかしたら、俺が……いや何でもない！」[p]

[if exp="f.read_evidence == true"]
  【主人公】
  （手帳のメモには『21:30に甥と面会』とあった。一条はバーにいたと言いつつ、明らかに何かを隠している……。もしかして、誰かを庇っているのか？）[p]
  [eval exp="f.found_ren_shield = true"]
[endif]

[eval exp="f.talk_ren = true"]
[jump target="*talk_select"]

; --- 橘 冴子との会話 ---
*talk_saeko
[cm]
[chara_show name="saeko" face="normal" left="300" top="100"]
【橘 冴子】
「使われた毒物は私のクリニックのものだけど、管理金庫から盗まれたのよ。当時屋敷に出入りしていた家政婦なら、鍵の置き場所を知る機会もあったでしょうね。」[p]
[eval exp="f.talk_saeko = true"]
[jump target="*talk_select"]


; ---------------------------------------------------------
; 3. 思考メモの確認
; ---------------------------------------------------------
*check_status
[cm]
【現在の推理状況】[p]
・捜査資料の確認：[if exp="f.read_evidence==true"]済[else]未[endif][p]
・神崎からの聴取：[if exp="f.talk_rin==true"]済[else]未[endif][p]
・一条からの聴取：[if exp="f.talk_ren==true"]済[else]未[endif][p]
・橘からの聴取：[if exp="f.talk_saeko==true"]済[else]未[endif][p]
・一条の庇い合いに気づいた：[if exp="f.found_ren_shield==true"]Yes[else]No[endif][p]
・証言の矛盾点に気づいた：[if exp="f.found_contradiction==true"]Yes[else]No[endif][p]
[p]
[jump target="*main_loop"]


; ---------------------------------------------------------
; 4. 告発パート（最終ステップ）
; ---------------------------------------------------------
*accuse_start
[cm]
【主人公】
（全員の話と資料が出揃った……。真犯人を指名する！）[p]

[glink color="red" target="*accuse_rin" text="神崎 凛（元家政婦）" x="150" y="120"]
[glink color="black" target="*accuse_ren" text="一条 蓮（甥）" x="150" y="200"]
[glink color="black" target="*accuse_saeko" text="橘 冴子（主治医）" x="150" y="280"]
[s]

; --- 神崎 凛を告発 ---
*accuse_rin
[cm]
[chara_show name="rin" face="anxiety" left="300" top="100"]
【主人公】
「神崎さん、犯人はあなたですね！」[p]

; 条件判定：資料・証言を聞き、矛盾に気づいているか？
[if exp="f.read_evidence == true && f.talk_rin == true && f.found_contradiction == true"]
  【主人公】
  「証拠ならあなたの言葉自体にあります！」[p]
  【主人公】
  「あなたは『21:00に裏口から帰った』と言いましたが、裏口は『20:30に自動施錠』される仕様です！ 21時に裏口から出ることなど不可能！」[p]
  【主人公】
  「さらに現場の『タイマー部品』！ あなたは20:00頃に毒殺した後、21:00に火災が起きるようタイマーを仕掛け、20:30前に堂々と脱出したんだ！」[p]

  [chara_mod name="rin" face="anger"]
  【神崎 凛】
  「く……っ！！ あ、あれは……！」[p]

  [playse storage="door_unlock.ogg"]
  【スピーカーの声】
  『見事だ……。真犯人の自白を確認した。ロックを解除する。』[p]

  [jump target="*true_end"]
[else]
  【主人公】
  「あなたが一番怪しいからです！」[p]
  [chara_mod name="rin" face="anger"]
  【神崎 凛】
  「ハァ？ 証拠もなしにそんなこと言わないで！」[p]
  【スピーカーの声】
  『証拠不十分だ。論理的な裏付けがない。』[p]
  [jump target="*bad_end"]
[endif]

; --- 間違えて一条を告発 ---
*accuse_ren
[cm]
[chara_show name="ren" face="anger" left="300" top="100"]
【主人公】
「一条、犯人はお前だ！」[p]
【一条 蓮】
「……ちっ。俺が庇おうとしたけど、これじゃ意味ねぇか。だが、俺は殺してねぇ！」[p]
【スピーカーの声】
『不正解だ。』[p]
[jump target="*bad_end"]

; --- 間違えて橘を告発 ---
*accuse_saeko
[cm]
[chara_show name="saeko" face="anger" left="300" top="100"]
【主人公】
「橘先生、犯人はあなたですね！」[p]
【橘 冴子】
「見当違いよ。呆れたわ……。」[p]
【スピーカーの声】
『不正解だ。』[p]
[jump target="*bad_end"]


; ---------------------------------------------------------
; エンディング
; ---------------------------------------------------------
*true_end
[cm]
[chara_hide_all time="300"]
[bg storage="room_light.jpg" time="1000"]
【主人公】
（鉄の扉が重々しい音を立てて開く。眩しい外の光が差し込んできた……。）[p]
[ptext text="TRUE END：12時間目の真相" x="200" y="250" size="30" color="red"]
[s]

*bad_end
[cm]
[chara_hide_all time="300"]
[playse storage="gas_sound.ogg"]
[bg storage="room_dark.jpg" time="1000"]
【スピーカーの声】
『タイムアップだ……。全員死亡する。』[p]
[ptext text="BAD END：愚者の未解決" x="200" y="250" size="30" color="white"]
[s]
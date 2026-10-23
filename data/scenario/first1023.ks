; =========================================================
; ゲーム起動時・最初期化ファイル (first.ks)
; =========================================================

; 1. システムの初期化・画面クリア
; [clearstack]
; [cm]
; [hidemessage]
[hidemenubutton]

; 2. キャラクター（立ち絵）の定義
; ※ image.pdfで決定されたファイル名・表情差分をここで一括登録します
[chara_new name="rin" jname="神崎 凛" storage="rin_normal.png"]
[chara_face name="rin" face="normal" storage="rin_normal.png"]
[chara_face name="rin" face="agitation" storage="rin_agitation.png"]
[chara_face name="rin" face="anxiety" storage="rin_anxiety.png"]
[chara_face name="rin" face="anger" storage="rin_anger.png"]
[chara_face name="rin" face="suspicion" storage="rin_suspicion.png"]
[chara_face name="rin" face="calm" storage="rin_calm.png"]

[chara_new name="ren" jname="一条 蓮" storage="ren_normal.png"]
[chara_face name="ren" face="normal" storage="ren_normal.png"]
[chara_face name="ren" face="agitation" storage="ren_agitation.png"]
[chara_face name="ren" face="anxiety" storage="ren_anxiety.png"]
[chara_face name="ren" face="anger" storage="ren_anger.png"]
[chara_face name="ren" face="calm" storage="ren_calm.png"]
[chara_face name="ren" face="avert" storage="ren_avert.png"]
[chara_face name="ren" face="fear" storage="ren_fear.png"]

[chara_new name="saeko" jname="橘 冴子" storage="saeko_normal.png"]
[chara_face name="saeko" face="normal" storage="saeko_normal.png"]
[chara_face name="saeko" face="anxiety" storage="saeko_anxiety.png"]
[chara_face name="saeko" face="anger" storage="saeko_anger.png"]
[chara_face name="saeko" face="suspicion" storage="saeko_suspicion.png"]

; 3. ゲーム内変数の初期化（必要に応じて）
[eval exp="f.found_rin = false"]
[eval exp="f.found_ren = false"]
[eval exp="f.found_saeko = false"]

; 4. タイトル画面を通さず直接テストする場合はコメントアウトを外してscene1へジャンプ
; [jump storage="scene1.ks"]

; 5. 通常のゲームフロー（タイトル画面を表示する）
*start
[wait time=500]
[position left=160 top=200]
始める[l][cm]
[clearstack]

[autostart]
[stop_keyconfig]
[wait time=200]
[position left=160 top=200]
【？？？】[r]
[delay speed=200]
なんだ？・・・何が起きた？？[l][r]
[delay speed=500]
意識が・・[l]
[resetdelay]
[wait time=1000]
[start_keyconfig]
[autostop]

; ここから
[cm]
[clearstack]
@layopt layer="message" visible=false

[playse storage=clock_ticking.mp3 volume=10 loop=true ]
[wait time=500]
[bg storage="room_dark.jpg" time="2000"]

;メッセージウィンドウの設定
; [position layer="message0" left=160 top=400 width=1000 height=190 page=fore visible=true time="2000"]

;文字が表示される領域を調整
; [position layer=message0 page=fore margint="45" marginl="50" marginr="75" marginb="60"]


;メッセージウィンドウの表示
@layopt layer=message0 visible=true

;キャラクターの名前が表示される文字領域
[ptext name="chara_name_area" layer="message0" color="white" size=28 bold=true x=180 y=510]

;上記で定義した領域がキャラクターの名前表示であることを宣言（これがないと#の部分でエラーになります）
[chara_config ptext="chara_name_area"]

; [position layer=message0 width=778 height=193 top=520 left=70 ]
[position layer=message0 width=1000 height=190 top=520 left=220 ]
[position layer=message0 page=fore frame="frame03.png" margint="10" marginl="40" marginr="40" marginb="60"]

【？？？】
「……おい。起きろ……！」[p]

【主人公】
（う、うーん……。頭が割れるように痛い……）[p]

; 明かりがつき、背景切り替えと立ち絵表示
[bg storage="room_light.jpg" time="800"]

[chara_show name="rin" face="agitation" left="50" top="220" time="500"]
[chara_show name="ren" face="normal" left="320" top="100" time="500"]
[chara_show name="saeko" face="suspicion" left="850" top="130" time="500"]

【主人公】
（目を開けると……見覚えのない暗い部屋だ。）[r]（窓はなく、頑丈な鉄の扉……密室か？）[p]
（周りには……見覚えのある顔。全員、困惑と警戒の混ざった表情でこちらを見ている。）[p]

[chara_mod name="rin" face="suspicion"]
【神崎 凛】
「あなたも目を覚ましたのね。……ここがどこだか、分かる？」[p]

【一条 蓮】
「久しぶりに見る顔だな。」[l][r]
[chara_mod name="ren" face="anger"]
「おまえ、何か知ってんじゃねえのか！？」[p][r]
「ドアは開かねぇし、スマホも圏外だぞ！ 拉致かよ！？」[p]

[chara_mod name="saeko" face="normal"]
【橘 冴子】
「落ち着きなさい。パニックになっても状況は変わらないわ……。」[p]

[chara_mod name="ren" face="avert"]
【一条 蓮】
「チッ。。」[p]

（神崎 凛がまだ何か言いたげに、こちらを見ている。）[p]

[chara_mod name="rin" face="suspicion"]

[wait time=2000]

; スピーカーアナウンス
[playse storage="noise.mp3"]
【スピーカーの声】[r]
『……聞こえるか、4人の容疑者共。』[p]

[chara_mod name="rin" face="anxiety"]
[chara_mod name="ren" face="fear"]
[chara_mod name="saeko" face="anxiety"]
【一条 蓮】
「なっ、なんだ！？ どこから声が……！？」[p]

[playse storage="noise.mp3"]
【スピーカーの声】[r]
『棚の扉を開けろ。そこに【箱】がある。』[p]

[chara_mod name="saeko" face="anger"]
【橘 冴子】
「いったい何なの！？ 早くここから出しなさい！」[p]

[chara_mod name="ren" face="anger"]
【一条 蓮】
「お前、何者だ！」[p]

【主人公】
「待て、一旦落ち着こう。」[l][r]
「とりあえず指示に従うしかなさそうだ。」[p]

[chara_mod name="rin" face="suspicion"]
[chara_mod name="ren" face="avert"]
[chara_mod name="saeko" face="normal"]

[wait time=1000]

【主人公】
（棚を開けると、中に重々しい木箱が置かれていた。箱を開けると、そこには大量の【捜査資料】と新聞記事が入っていた……。）[p]

[chara_mod name="rin" face="anxiety"]
【神崎 凛】
「これ……5年前の資産家・毒殺放火事件の資料……！？」[p]

[playse storage="noise.mp3"]
【スピーカーの声】[r]
『そうだ。その事件の真犯人は、今その部屋にいる4人の中にいる。』[p]

[chara_mod name="saeko" face="anger"]
【橘 冴子】
「なんですって……！？ あんな昔の事件を今さら... 馬鹿げているわ！」[p]

[chara_mod name="ren" face="anger"]
【一条 蓮】
「そうだ！ ふざけるな！」[p]
「警察の取り調べで、俺はあの事件の容疑者から外れたんだ！」[p]

[chara_mod name="saeko" face="anger"]
【橘 冴子】
「私だってそうよ！」[p]

[playse storage="noise.mp3"]
【スピーカーの声】[r]
『12時間以内に資料と議論から矛盾を突き、真犯人を特定しろ。』[p]

[playse storage="noise.mp3"]
【スピーカーの声】[r]
『出来なければ……部屋に毒ガスを注入し、全員死亡する。』[p]

[wait time=1000]

【主人公】
（狂ってる……！ だが、やるしかない。）[r]（自分は絶対に犯人じゃない。）[r]
（資料を読み、3人の証言から【矛盾】を見つけ出すんだ！）[p]

[chara_hide_all time=200 wait=true]
@layopt layer="message0" visible=false
; ここまで

;タイトル画面へ移動
[wait time=2000]
@jump storage="title.ks"
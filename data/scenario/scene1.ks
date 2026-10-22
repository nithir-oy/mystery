; =========================================================
; 『12時間の密室：消えた犯人』 メインシナリオ（骨組み・ロジック実装版）
; =========================================================
[cm]
@layopt layer="message" visible=false
[bg storage="room_light.jpg" time="1000"]

;メッセージウィンドウの設定
; [position layer="message0" left=160 top=400 width=1000 height=190 page=fore visible=true]

;文字が表示される領域を調整
; [position layer=message0 page=fore margint="45" marginl="50" marginr="70" marginb="60"]


;メッセージウィンドウの表示
@layopt layer=message0 visible=true

;キャラクターの名前が表示される文字領域
[ptext name="chara_name_area" layer="message0" color="white" size=28 bold=true x=180 y=510]

;上記で定義した領域がキャラクターの名前表示であることを宣言（これがないと#の部分でエラーになります）
[chara_config ptext="chara_name_area"]

; [position layer=message0 width=778 height=193 top=520 left=70 ]
[position layer=message0 width=1000 height=190 top=520 left=70 ]
[position layer=message0 page=fore frame="frame03.png" margint="10" marginl="40" marginr="40" marginb="60"]

[chara_show name="rin" face="normal" left="50" top="250" time="500"]
[chara_show name="ren" face="normal" left="320" top="100" time="500"]
[chara_show name="saeko" face="normal" left="850" top="130" time="500"]

; ---------------------------------------------------------
; ★追加：主人公が動機を追及される小イベント
; ---------------------------------------------------------
[wait time=1000]

[chara_mod name="ren" face="agitation"]
【一条 蓮】
「……それにしても、あれは一体誰なんだよ。」[l][r]
「面倒なことに巻き込まれたもんだぜ……」[p]

【神崎 凛】
「何とかしてここから抜け出す方法を考えないとですね……」[p]

[chara_mod name="saeko" face="suspicion"]
【橘 冴子】
「ちょっと待って……。[r]あなた、被害者と『事業の権利』をめぐって激しいトラブルになっていたわよね？」[p]
「一番殺害の動機があるのは、あなた自身なんじゃないの！？」[p]

[chara_mod name="rin" face="suspicion"]

[chara_mod name="ren" face="anger"]
【一条 蓮】
「そうだぜ！ 自分だけ被害者面してやがる！」[p]

【主人公】
（くそっ……！ 確かに俺には被害者に対する激しい恨みと動機がある。だが、殺害なんてしていない……！）[p]
【主人公】
「待て、俺はあの夜、確かに権利の件で文句を言いに行こうとはしたが……途中で思い直して引き返したんだ！ 私は殺してない！」[p]

[chara_mod name="saeko" face="suspicion"]
【橘 冴子】
「……ふん、口ではなんとでも言えるわね。まあ、どちらにしろ真犯人を見つけないと私たちは全員生きて出られないみたいだし……」[p]

[chara_hide_all time="500"]

【主人公】
（まずい雰囲気に包まれたが……ここで疑われて処刑されるわけにはいかない。資料を読み、全員の証言から【真犯人】を見つけ出して自分の無実を証明するんだ！）[p]

[playbgm storage="main_bgm.mp3" loop="true"]

; ---------------------------------------------------------
; 変数の初期化（フラグ管理）
; ---------------------------------------------------------
[eval exp="f.read_evidence = false"]
; ← デバッグ用に true に変更
[eval exp="f.found_photo = false"]
[eval exp="f.found_timer = false"]

[eval exp="f.talk_rin = false"]
[eval exp="f.talk_ren = false"]
[eval exp="f.talk_saeko = false"]
[eval exp="f.confession_occurred = false"]

; 推理実行（検証）クリアフラグ
[eval exp="f.solve_ren = false"]
[eval exp="f.solve_saeko = false"]
[eval exp="f.solve_rin = false"]


; ---------------------------------------------------------
; メインループ（探索・話し合い選択）
; ---------------------------------------------------------
*main_loop
[cm]
[chara_hide_all time="300"]
[bg storage="room_light.jpg" time="300"]

; 条件判定：全員から話を聞いており、まだ自白イベントが発生していない場合
[if exp="f.read_evidence == true && f.talk_rin == true && f.talk_ren == true && f.talk_saeko == true && f.confession_occurred == false"]
  [jump target="*ren_confession_event"]
[endif]

【主人公】
（残り時間は少ない。どう行動しようか？）[p]

[glink color="black" width="520" target="*read_evidence" text="📜 捜査資料を調べる（4人の動機等）" x="150" y="80"]

; 捜査資料を見た後のみ「現場写真を見る」を解放
[if exp="f.read_evidence == true"]
  [glink color="blue" width="520" target="*view_photo" text="📷 現場写真を見る" x="150" y="150"]
[endif]

[glink color="black" width="520" target="*talk_select" text="🗣️ 容疑者に話を聞く（事実の確認）" x="150" y="220"]
[glink color="black" width="520" target="*check_status" text="🔍 現在の思考メモを確認する" x="150" y="290"]

; 自白イベント発生後のみ「推理の実行」を解放
[if exp="f.confession_occurred == true"]
  [glink color="blue" width="520" target="*deduction_select" text="🧠 容疑者たちの推理・検証を行う" x="150" y="360"]
[endif]

[glink color="red" width="520" target="*accuse_start" text="⚖️ 真犯人を告発する" x="150" y="430"]
[s]


; ---------------------------------------------------------
; 1. 捜査資料の確認
; ---------------------------------------------------------
*read_evidence
[cm]
【捜査資料：5年前の被害者殺害事件】[p]
・被害者：資産家・山田氏（自宅書斎にて遺体で発見）[p]
・死因：毒殺（その後、火災が発生し現場は半焼）[p]
・現場状況：裏口セキュリティは【20:30に自動施錠】。[p]
・現場遺留品：【被害者の手帳】（『21:30 甥（一条）と面会』）、【高級香水の痕跡】[p]
※当時の警察捜査では、火災原因の決定的な痕跡は見つかっていない。[p]

【4人の容疑者と殺害動機】[p]
・主人公：共同事業の権利を横取りされ、多額の損失を被っていた。[p]
・神崎 凛：隠し金庫から大金を盗もうとしたところを目撃された疑い。[p]
・一条 蓮：多額の借金と、遺産相続の権利。[p]
・橘 冴子：違法薬物処方のスキャンダルを握られ、脅迫されていた。[p]

[eval exp="f.read_evidence = true"]
【主人公】
（資料の挟み込みに現場写真が残されているな……。あとで詳しく見てみよう。）[p]
[jump target="*main_loop"]


; ---------------------------------------------------------
; 1-2. 現場写真の確認（隠しボタンギミック）
; ---------------------------------------------------------
*view_photo
[cm]
; 背景として現場写真を呼び出す（data/bgimage/photo_scene.jpg を参照）
[bg storage="photo_scene.jpg" time="300"]

【主人公】
（警察が撮影した現場写真だ。何か見落としはないか、気になるところを調べてみよう……）[p]

;メッセージウィンドウの表示
@layopt layer=message0 visible=false

; 背景全体を覆う「外れ判定（何もない）」ボタン
[button graphic="transparent.png" target="*photo_nothing" x="150" y="0" width="920" height="730"]

; タイマー部品がある位置の「隠しボタン」
[button graphic="transparent.png" target="*find_timer" x="235" y="390" width="40" height="40"]

; ▼3. 写真画面上に配置する「メニューへ戻る」ボタン
[glink color="gray" target="*back_to_main"  size="20" text="↩ メニューへ戻る" x="1000" y="600"]
[s]

*find_timer
;メッセージウィンドウの表示
@layopt layer=message0 visible=true
[cm]
; 元の背景（部屋）に戻す
[bg storage="room_light.jpg" time="300"]
【主人公】
「なんだこれは……？ 床の焦げ跡の隅に、小さな金属パーツが……タイマーの破片か！？」[p]
【主人公】
（警察はこのパーツを見落としていたんだ！ 21時の火災はあらかじめ仕掛けられたタイマー放火だったんだ！）[p]
[eval exp="f.found_timer = true"]
[jump target="*main_loop"]

; --- 外れをクリックした場合 ---
*photo_nothing
@layopt layer=message0 visible=true
[cm]
【主人公】
（特に気になるものはなさそうだ……別の場所を調べるか。）[p]

; 再び写真のボタン選択待ちに戻る（※メッセージを消してループ）
@layopt layer=message0 visible=false
[jump target="*view_photo"]

; --- 「メニューへ戻る」ボタンを押した場合 ---
*back_to_main
@layopt layer=message0 visible=true
[cm]
; 元の部屋背景に戻してメインループへ
[bg storage="room_light.jpg" time="300"]
[jump target="*main_loop"]

; ---------------------------------------------------------
; 2. 話を聞く（事実のみ・主人公の考察は出さない）
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

*talk_rin
[cm]
[chara_show name="rin" face="anger" left="300" top="250"]
【神崎 凛】
「私は事件当夜、仕事が終わって【21:00に裏口から普通に帰宅した】だけよ。火事なんて知らなかったわ！」[p]
[eval exp="f.talk_rin = true"]
[chara_hide name="rin"]
[jump target="*talk_select"]

*talk_ren
[cm]
[chara_show name="ren" face="anger" left="300" top="100"]
【一条 蓮】
「俺はあの夜、20時から朝までずっとバーで飲んでたんだ！ 被害者となんて会ってねぇ！」[p]
[eval exp="f.talk_ren = true"]
[chara_hide name="ren"]
[jump target="*talk_select"]

*talk_saeko
[cm]
[chara_show name="saeko" face="suspicion" left="350" top="100"]
【橘 冴子】
「使われた毒物は私のものだけど管理金庫から盗まれたの。当夜の20:15〜21:15はクリニックで【急患の手術（カルテ記録あり）】をしていて現場には行っていないわ。」[p]
[eval exp="f.talk_saeko = true"]
[chara_hide name="saeko"]
[jump target="*talk_select"]


; ---------------------------------------------------------
; 3. 一条の「嘘の自白」イベント（急展開）
; ---------------------------------------------------------
*ren_confession_event
[cm]
[eval exp="f.confession_occurred = true"]
[chara_show name="ren" face="anger" left="300" top="100"]

【一条 蓮】
「……くそっ！ もういい、喋ってやるよ！」[p]
【一条 蓮】
「俺が叔父さんを殺したんだ！ 俺が犯人だよ！」[p]

[chara_show name="rin" face="anxiety" left="50" top="250"]
[chara_show name="saeko" face="anxiety" left="850" top="100"]
【橘 冴子】
「えっ……！？ 一条くん、あなたが……！？」[p]

[wait time=500]

【主人公】
（待て……一条の自白は本当なのか？ 何か違和感がある。メインメニューから『推理・検証』を行い、3人全員の真実を暴く必要がある！）[p]

[jump target="*main_loop"]


; ---------------------------------------------------------
; 4. 推理の実行（3人全員の検証）
; ---------------------------------------------------------
*deduction_select
[cm]
【主人公】
（3人それぞれの言動と証拠を突き合わせ、真相を検証しよう。）[p]

[glink color="blue" target="*deduce_ren" text="【検証①】一条の「自白」を検証する" x="150" y="120"]
[glink color="blue" target="*deduce_saeko" text="【検証②】橘の「カルテアリバイ」を検証する" x="150" y="200"]
[glink color="blue" target="*deduce_rin" text="【検証③】神崎の「21時退室」を検証する" x="150" y="280"]
[glink color="gray" target="*main_loop" text="戻る" x="150" y="360"]
[s]

; --- 【検証①】一条の自白 ---
*deduce_ren
[cm]
【主人公】
（一条は自分が殺したと自白した。しかし、彼の自白と食い違う『事実』とは何だ？）[p]

[glink color="black" target="*ren_wrong" text="橘のクリニックから毒薬が盗まれたこと" x="150" y="120"]
[glink color="red" target="*ren_correct" text="被害者の手帳に『21:30面会予定』とあったこと" x="150" y="200"]
[glink color="black" target="*ren_wrong" text="主人公に事業の失敗による動機があること" x="150" y="280"]
[s]

*ren_correct
[cm]
【主人公】
（そうだ！ 一条が犯人なら21:30に面会予定を入れるはずがない。それに彼の態度……彼は真犯人（神崎）を庇うために嘘の自白をしているんだ！）[p]
【一条の検証：完了】[p]
[eval exp="f.solve_ren = true"]
[jump target="*deduction_select"]

*ren_wrong
[cm]
【主人公】
（いや、それと一条の自白の直接的な矛盾にはならない……思考を整理し直そう。）[p]
[jump target="*deduction_select"]


; --- 【検証②】橘のアリバイ ---
*deduce_saeko
[cm]
【主人公】
（橘は『手術のカルテ』を根拠に現場に行っていないと主張している。だが、現場に残された矛盾する痕跡とは？）[p]

[glink color="black" target="*saeko_wrong" text="裏口が20:30に自動施錠されていたこと" x="150" y="120"]
[glink color="red" target="*saeko_correct" text="現場の書斎に高級香水の痕跡が残っていたこと" x="150" y="200"]
[glink color="black" target="*saeko_wrong" text="主人公に事業の権利を奪われた過去があること" x="150" y="280"]
[s]

*saeko_correct
[cm]
【主人公】
（そうだ！ 橘はカルテを改ざんして隠していたが、当夜現場に侵入していた！ しかし彼女が着いた時には被害者はすでに殺されていたため、彼女は犯人ではない！）[p]
【橘の検証：完了】[p]
[eval exp="f.solve_saeko = true"]
[jump target="*deduction_select"]

*saeko_wrong
[cm]
【主人公】
（いや、橘のアリバイ崩しに直接繋がる証拠はそれじゃない……。）[p]
[jump target="*deduction_select"]


; --- 【検証③】神崎のトリック ---
*deduce_rin
[cm]
【主人公】
（神崎は『21:00に裏口から出た』と主張している。これと矛盾する事実および『現場写真から見つけた証拠』とは？）[p]

; 写真からタイマーを発見していない場合は選択肢を選んでも見破れない
[if exp="f.found_timer == false"]
  【主人公】
  （裏口の20:30自動施錠と21:00退室の矛盾は分かるが……火災のタイムラグを証明する『決定的な証拠』が足りない。現場写真をもっと調べよう。）[p]
  [jump target="*deduction_select"]
[endif]

[glink color="red" target="*rin_correct" text="20:30自動施錠＋写真で見つけた『タイマーの破片』" x="150" y="120"]
[glink color="black" target="*rin_wrong" text="一条の『ずっとバーで飲んでいた』という主張" x="150" y="200"]
[glink color="black" target="*rin_wrong" text="橘のクリニックの毒薬が使われたこと" x="150" y="280"]
[s]

*rin_correct
[cm]
【主人公】
（そうだ！ 20:30に施錠されるなら21:00に出られるはずがない！ 彼女は20:00頃に毒殺し、写真に写っていたタイマーで21:00に火災を起こして20:30前に逃げた真犯人だ！）[p]
【神崎の検証：完了】[p]
[eval exp="f.solve_rin = true"]
[jump target="*deduction_select"]

*rin_wrong
[cm]
【主人公】
（いや、神崎の証言を直接崩す矛盾はそれではない……。）[p]
[jump target="*deduction_select"]


; ---------------------------------------------------------
; 5. 思考メモ確認
; ---------------------------------------------------------
*check_status
[cm]
【現在の進行状況】[p]
・捜査資料の確認：[if exp="f.read_evidence==true"]済[else]未[endif][p]
・現場写真のタイマー発見：[if exp="f.found_timer==true"]発見済[else]未発見[endif][p]
・3人からの聴取：[if exp="f.talk_rin && f.talk_ren && f.talk_saeko"]済[else]未[endif][p]
・一条の自白発生：[if exp="f.confession_occurred"]発生済[else]未発生[endif][p]
・【検証①】一条の検証：[if exp="f.solve_ren"]完了[else]未[endif][p]
・【検証②】橘の検証：[if exp="f.solve_saeko"]完了[else]未[endif][p]
・【検証③】神崎の検証：[if exp="f.solve_rin"]完了[else]未[endif][p]
[p]
[jump target="*main_loop"]


; ---------------------------------------------------------
; 6. 告発パート
; ---------------------------------------------------------
*accuse_start
[cm]
【主人公】
（全員の検証を終え、真犯人を指名する！）[p]

[glink color="red" target="*accuse_rin" text="神崎 凛（元家政婦）" x="150" y="120"]
[glink color="black" target="*accuse_ren" text="一条 蓮（被害者の甥）" x="150" y="200"]
[glink color="black" target="*accuse_saeko" text="橘 冴子（主治医）" x="150" y="280"]
[s]

*accuse_rin
[cm]
; 条件判定：3人全員の検証が完了しているか？
[if exp="f.solve_ren == true && f.solve_saeko == true && f.solve_rin == true"]
  [chara_show name="rin" face="anxiety" left="300" top="100"]
  【主人公】
  「神崎さん、真犯人はあなただ！」[p]
  【主人公】
  「あなたの『21:00に裏口から帰った』という証言と『20:30自動施錠』の矛盾！ そして現場写真から見つけたタイマーの部品！ これが動かぬ証拠だ！」[p]

  [chara_mod name="rin" face="anger"]
  【神崎 凛】
  「くっ……！ まさか、あの写真の小さな破片まで見抜くなんて……！」[p]

  [playse storage="door_unlock.ogg"]
  【スピーカーの声】
  『見事だ……。真犯人の特定に成功した。ロックを解除する。』[p]

  [jump target="*true_end"]
[else]
  【主人公】
  「神崎さん、あなたが犯人だ！」[p]
  【スピーカーの声】
  『論理的な検証が不十分だ。証拠（タイマー部品）や検証を欠いた告発とみなす。』[p]
  [jump target="*bad_end"]
[endif]

*accuse_ren
[cm]
【スピーカーの声】
『不正解だ。一条の自白の矛盾も見抜けぬ愚者め。』[p]
[jump target="*bad_end"]

*accuse_saeko
[cm]
【スピーカーの声】
『不正解だ。橘の偽装と殺人は無関係だ。』[p]
[jump target="*bad_end"]


; ---------------------------------------------------------
; エンディング
; ---------------------------------------------------------
*true_end
[cm]
[chara_hide_all time="300"]
[bg storage="room_light.jpg" time="1000"]
【主人公】
（重々しい鉄の扉が開き、脱出に成功した……！）[p]
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
























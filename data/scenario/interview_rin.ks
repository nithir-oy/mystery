; =========================================================
; interview_rin.ks ― 神崎 凛の聞き込み①(未検証)
;
; ・資料集 v1 の 5-2 に対応。質問コマンド R1〜R6 と、証拠の提示を実装する
; ・これが、蓮・冴子の聞き込みを作るときの「型」になる
;     メニュー(*menu) → 質問や提示(*R1 など) → メニューに戻る
; ・質問の解禁条件:
;     R3 = P2またはD3を閲覧済み、R4 = D7またはD8を閲覧済み、他は最初から
; ・聞き込み②(K1〜K3の提示、薬の欠損、最終局面)は M6・M8 で、この下に追加する
; =========================================================

*start
[call storage="macros.ks"]
[cm]
[clearfix]
[bg storage="room_light.jpg" time="300"]
[chara_show name="rin" face="normal" left="640" top="80" time="300"]

; ---------------------------------------------------------
; 質問メニュー
; ---------------------------------------------------------
*menu
[cm]
@layopt layer="message0" visible="false"
[eval exp="tf.y = 90"]
[qbtn text="あの夜のことを教えてほしい" target="*R1"]
[qbtn text="山田氏との関係は?" target="*R2"]
[if exp="f.seen_P2 || f.seen_D3"]
[qbtn text="薬の準備について" target="*R3"]
[endif]
[if exp="f.seen_D7 || f.seen_D8"]
[qbtn text="書斎のストーブについて" target="*R4"]
[endif]
[qbtn text="帰宅した後のことは?" target="*R5"]
[qbtn text="一条さんとは親しいのか?" target="*R6"]
[eval exp="tf.y += 20"]
[qbtn text="証拠を提示する" target="*present" color="btn_02"]
[qbtn text="聞き込みをやめる" target="*exit" color="btn_02"]
[s]

; ---------------------------------------------------------
; R1 あの夜のことを教えてほしい
; ---------------------------------------------------------
*R1
[first flag="rin_r1"]
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「あの夜のことですか。5年も前のことですのに、昨日のことのように覚えています。」[p]
[rin f="calm"]
「08:05に出勤して、いつも通りお掃除と夕食のお支度を。夕食は19:00にお出ししました。」[p]
「19:55頃に、食後のお薬と白湯を書斎の入口でお渡ししました。それから片付けを済ませて、20:12に裏口で打刻して帰りました。」[p]
【主人公】
（淀みがない。しかも、5年前の調書の言い回しとほとんど同じだ。）[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; R2 山田氏との関係は?
; ---------------------------------------------------------
*R2
[first flag="rin_r2"]
@layopt layer="message0" visible="true"
[rin f="suspicion"]
【神崎 凛】
「雇い主と使用人です。それだけですが。」[p]
[rin f="anxiety"]
「旦那様は、気分の波が激しい方でした。休日に突然呼び出されたり、私用のことまで言いつけられたり。でも、それが仕事ですから。」[p]
[cm]
@layopt layer="message0" visible="false"
[eval exp="tf.y = 200"]
[qbtn text="「恨んでいたのでは?」" target="*R2_A" x="420" w="440"]
[qbtn text="「大変でしたね」" target="*R2_B" x="420" w="440"]
[s]

*R2_A
@layopt layer="message0" visible="true"
[rin f="agitation"]
【神崎 凛】
「……!」[p]
[rin f="calm"]
「そう思われても仕方ありませんね。ですが、恨んでいたなら、あの家で何年も働けません。」[p]
[cm]
[jump target="*menu"]

*R2_B
@layopt layer="message0" visible="true"
[rin f="anxiety"]
【神崎 凛】
「……ありがとうございます。」[p]
【主人公】
（一瞬、本心がのぞいた気がした。）[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; R3 薬の準備について
; ---------------------------------------------------------
*R3
[first flag="rin_r3"]
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「旦那様のお薬は、日曜の夜に旦那様ご自身が、ピルケースに補充なさっていました。私は毎晩、夕の枠のお薬を薬皿に移して、白湯と一緒にお出しするだけです。」[p]
【主人公】
「中身は?」[p]
【神崎 凛】
「降圧のお薬と、胃のお薬です。白と淡いピンクの、ごく普通の錠剤です。」[p]
【主人公】
（薬皿に薬を載せたのは神崎だ。）[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; R4 書斎のストーブについて(D7またはD8の提示からも入る)
; ---------------------------------------------------------
*R4
[first flag="rin_r4"]
@layopt layer="message0" visible="true"
[rin f="calm"]
【神崎 凛】
「ストーブですか。夕方のお掃除のときは、書斎に出ていませんでした。旦那様がお帰りになってから、ご自分で出されたのでは。」[p]
【主人公】
「この暑さで?」[p]
[rin f="agitation"]
【神崎 凛】
「……!」[p]
[rin f="calm"]
「冷房を強くかけていらっしゃいましたから。足元が冷えるとおっしゃって。」[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; R5 帰宅した後のことは?
; ---------------------------------------------------------
*R5
[first flag="rin_r5"]
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「まっすぐ家に帰りました。一人暮らしですから、証明してくれる人はいません。……それが何か?」[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; R6 一条さんとは親しいのか?
; ---------------------------------------------------------
*R6
[first flag="rin_r6"]
@layopt layer="message0" visible="true"
[rin f="anxiety"]
【神崎 凛】
「親しい、というほどでは。ご挨拶をする程度です。」[p]
[cm]
[jump target="*menu"]

; ---------------------------------------------------------
; 証拠の提示(入手済みの証拠だけが並ぶ)
; ---------------------------------------------------------
*present
[cm]
@layopt layer="message0" visible="false"
[eval exp="tf.y = 90"]
[pick id="D9_5" text="D9-5 友人T氏の証言" target="*pr_D9_5"]
[pick id="D2" text="D2 出入り記録整理表" target="*pr_D2"]
[pick id="D3" text="D3 解剖所見" target="*pr_D3"]
[pick id="P2" text="P2 被害者のピルケース" target="*pr_P2"]
[pick id="D7" text="D7 現場写真" target="*pr_D7"]
[pick id="D8" text="D8 新聞記事・天気欄" target="*pr_D8"]
[eval exp="tf.y += 20"]
[qbtn text="やめる" target="*menu" color="btn_02"]
[s]

*pr_D9_5
[first flag="rin_safe_denial"]
@layopt layer="message0" visible="true"
[rin f="agitation"]
【神崎 凛】
「……!」[p]
[rin f="anger"]
「その話は、調書でもお話ししました。誤解です。」[p]
[rin f="normal"]
「旦那様が書斎で金庫を開けていらして、お掃除に入った私に、お金が見えただけです。盗もうなんて、思っていません。」[p]
【主人公】
「暗証番号を知っていたのか?」[p]
[rin f="anxiety"]
【神崎 凛】
「知りません。旦那様はいつも、私の見えないところで操作していました。」[p]
【主人公】
（「金庫の前で現金を握っていた」という証言と食い違う。握るには、金庫を開けられたはずだ。）[p]
[cm]
[jump target="*menu"]

*pr_D2
[first flag="rin_r5"]
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「打刻のとおり、20時12分です。その後は、あの家には戻っていません。」[p]
【主人公】
（これは本当だろう。20:12以降、屋敷に出入りした記録はない。）[p]
[cm]
[jump target="*menu"]

*pr_D3
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「さあ……。錠剤の糖衣ではありませんか? 警察の方も、そうおっしゃっていましたよね。」[p]
[cm]
[jump target="*menu"]

*pr_P2
[eval exp="f.rin_pillcase = true"]
@layopt layer="message0" visible="true"
[rin f="normal"]
【神崎 凛】
「夕の枠が空なのは、私がその晩のぶんを薬皿に移したからです。」[p]
[cm]
[jump target="*menu"]

*pr_D7
[jump target="*R4"]

*pr_D8
[jump target="*R4"]

; ---------------------------------------------------------
; 聞き込み②・最終局面は、M6・M8 でここに追加する
;   R-K1(K1提示)、R-K2(K2提示)、R-K3(K3提示、薬の欠損)
;   最終局面は confront_rin.ks に分ける
; ---------------------------------------------------------

; ---------------------------------------------------------
; 聞き込みを終える
; ---------------------------------------------------------
*exit
[cm]
@layopt layer="message0" visible="false"
[chara_hide name="rin" time="200"]
[jump storage="hub.ks" target="*hub"]

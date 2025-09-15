自作したキーボード配列です。
ホームポジションから大きく手を動かすことなく、英日両方の入力、そして矢印キーや数字・記号の入力の簡易化を目標とし、制作を行いました。

利用する際には、「Windows PowerToys」※　と「Auto Hot Key」の導入が必要となります。（※その他のキー入力内容を変更できるソフトウェアでの動作は未確認です）

Windows PowerToys
https://learn.microsoft.com/ja-jp/windows/powertoys/install

Auto Hot Key
https://www.autohotkey.com/

利用方法
1.Windows PowerToys　の　Keyboard Manager で下記のようにキーの再マップを行ってください。
 VK 242 → VK 244
 R → F13
 Q → J
 Y → V
 W → Y
 E → U
 U → D
 T → F14
 I → H
 O → G
 P → W
 [ → Disable
 S → I
 D → E
 F → O
 G → F15
 H → F
 J → T
 K → N
 L → S
 ; → R
 : → ;;
 ] → Space
 Z → F16
 V → P
 B → Disable
 N → K
 , → L
 . → B
 / → Z
 \ → Disable
 IME Convert → Backspace
 - → Disable
 9 → V
 0 → Q
 @ → F17

2.キーを再マップした後、「#JYU~!.ahk」を実行してください。
3.正しくキー入力が反映しない場合は、Keyboard Manager　と　#JYU~!.ahk　を停止したのち再度1から実行してください。

# Ubuntu GUI Playground Docker環境

ubuntuのGUI付きPlayground環境です。以下を含んでいます。

* LXDE 日本語GUIデスクチップ環境
* Fcitx + Mozc 日本語入力(Ctrl+Space)
* TigerVNC
* pulseaudio
* firefox
* anyenv ( pyenv / nodenv )
* curl / wget / git

fishが起動するようになっていますが、不要であれば　dockerfile 内の以下を削除してください。

```
RUN echo fish >> ~/.bashrc
```


# 使い方

（１） VNCクライアントが必要なので、適当に入手します。

(2) ビルド
```
$ docker-compose build
```

(3) 起動
```
$ docker-compose up
```
VNCの接続待ちになります。接続に必要なuser/passwordはログに表示されていますので、
それを確認して、 `127.0.0.1:5901` にVNCクライアントから接続します。


# そのほか

pulseaudioを入れてあります。勝手にMacの場合だとおもって書いているので、Mac側でpulseaudioサーバを起動してください。

参考
https://qiita.com/Mco7777/items/18e29b98ddbc2614169b



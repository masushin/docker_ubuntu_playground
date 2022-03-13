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



# Use Package In DoomEmacs
Use emacs package in doom way.
## LSP Bridge
``` emacs-lisp
;;依赖
(custom/borg-assimilate "github" "tumashu/posframe")
(custom/borg-assimilate "github" "jrblevin/markdown-mode")
(custom/borg-assimilate "github" "joaotavora/yasnippet")

(borg-assimilate "popon" "git@codeberg.org:akib/emacs-popon.git")
(custom/borg-assimilate "github" "twlz0ne/acm-terminal")
(borg-compile "acm" (expand-file-name "lib/lsp-bridge/acm" doom-user-dir))
(borg-compile (expand-file-name "lib/lsp-bridge" doom-user-dir))

(custom/borg-assimilate "github" "manateelazycat/lsp-bridge")
```
Reference 
- [kongds/.doom.d - init-lsp-bridge.el](https://github.com/kongds/.doom.d/blob/main/configs/init-lsp-bridge.el)
## Blink Seach
``` shell
pip3 install epc requests
brew install ripgrep
brew install fd
brew install rga # pdf
# brew install pandoc poppler tesseract ffmpeg
```

``` emacs-lisp
(custom/borg-assimilate "github" "manateelazycat/blink-search")
```
Reference 
- [kongds/.doom.d - init-blink-search.el](https://github.com/kongds/.doom.d/blob/main/configs/init-blink-search.el)
## Ruby On Rails
Reference
- [doom-emacs-on-rails](https://github.com/otavioschwanck/doom-emacs-on-rails)
## Sort tab 
- [ ] disable selected by other-window and ace-window
``` emacs-lisp
(custom/borg-assimilate "github" "manateelazycat/sort-tab")
```
- [kongds/.doom.d - init-sort-tab](https://github.com/kongds/.doom.d/blob/main/configs/init-sort-tab.el)
## Netease Music
- [kongds/.doom.d - init-netease-music](https://github.com/kongds/.doom.d/blob/main/configs/init-netease-music.el)
## Translate Shell
``` shell
brew install gawk
brew install translate-shell
brew install proxychains-ng # optional for proxy
```

``` emacs-lisp
(custom/borg-assimilate "github" "xuchunyang/translate-shell.el")
```
## Consult Notes
- custom-consult-notes: use consult-notes way to return note file path

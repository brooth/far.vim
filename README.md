# far.vim - Find And Replace Vim plugin

## Intro
Far.vim makes it easier to find and replace text through multiple files.
It's inspired by fancy IDEs, like IntelliJ and Eclipse, that provide
cozy tools for such tasks.

## Installation
#### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'brooth/far.vim'
```

## Usage

### Searching with Command
```bash
:Far foo bar **/*.py
:Fardo
```
![far.vim](https://cloud.githubusercontent.com/assets/9823254/20861878/77dd1882-b9b4-11e6-9b48-8bc60f3d7ec0.gif)

#### :Far {pattern} {replace-with} {file-mask} [params]
Find the text to replace.

#### :F {pattern} {file-mask} [params]
Find only.

### Searching Interatively

```bash
:Farr foo bar **/*.py
```

![ScreenShot 2020-02-02 01 59 19 2020-02-02 02_03_50](https://user-images.githubusercontent.com/30200581/73597060-3155b200-4563-11ea-82cc-2888a44b98aa.gif)

#### :Farr [params]
Interative `Far`. Shows searching modes in the status bar (regex, case sensitive, word boundary, replace). Modes can be toggled by the key mapping it prompted. Allows to enter {pattern}, {replace-with} and {file-mask} one after the other.

#### :Farf [params]
Interative `F`. The interaction is similar to `Farr`.

### Commands in the searching result window

#### :Fardo [params]
Runs the replacement task. The shortcut for it is `s` (substitute).

#### :Farundo [params]
Undo the recurrent replacement. The shortcut for it is `u` (undo). It is available when set `let g:far#enable_undo=1`.

#### :Refar [params]
Change `Far`/`F`/`Farr`/`Farf` params.


### Need help?
```bash
:help far.vim
```

## Extras
### Multiline Replacement
![multiline](https://cloud.githubusercontent.com/assets/9823254/20029467/193b7f58-a366-11e6-9a22-05e8464ec0e4.gif)

### Neovim-Async, Ack, Ag, Ripgrep support
![nvim](https://cloud.githubusercontent.com/assets/9823254/20861644/72df878a-b9ae-11e6-9762-449c5d0a1faf.gif)

### Command-Line Completion
![complete](https://cloud.githubusercontent.com/assets/9823254/20029477/8076abd4-a366-11e6-8711-9b4e18367c80.gif)

### Consistency Check
![consistency](https://cloud.githubusercontent.com/assets/9823254/20029514/70475168-a367-11e6-9a2d-53614730307b.gif)


..and many more! Check out `:help far.vim`.

## Troubleshooting

#### Recommented Setting
You can add he following settings to your vim configuration:

```vim
set lazyredraw            " improve scrolling performance when navigating through large results
set regexpengine=1        " use old regexp engine
set ignorecase smartcase  " ignore case only when the pattern contains no capital letters

" shortcut for far.vim find
nnoremap <silent> <Find-Shortcut>  :Farf<cr>
vnoremap <silent> <Find-Shortcut>  :Farf<cr>

" shortcut for far.vim replace
nnoremap <silent> <Replace-Shortcut>  :Farr<cr>
vnoremap <silent> <Replace-Shortcut>  :Farr<cr>
```

## License
MIT

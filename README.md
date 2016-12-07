# far.vim - Find And Replace Vim plugin

## Intro
Far.vim makes it easier to find and replace text through multiple files.
It's inspired by fancy IDEs, like IntelliJ and Eclipse, that provide
cozy tools for such tasks.

## Version
[Beta 2](https://github.com/brooth/far.vim/wiki/beta-2-changelog). (Tested on Vim 7.4, Neovim 0.2.0-dev)

## Installation
#### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'brooth/far.vim'
```

## Usage

```bash
:Far foo bar **/*.py
:Fardo
```
![far.vim](https://cloud.githubusercontent.com/assets/9823254/20861878/77dd1882-b9b4-11e6-9b48-8bc60f3d7ec0.gif)

#### :Far {pattern} {replace-with} {file-mask} [params]
Find the text to replace.

#### :Farp [params]
Same as `Far`, but allows to enter {pattern}, {replace-with} and {file-mask}
one after the other.

#### :Fardo [params]
Runs the replacement task.

#### :Refar [params]
Change `Far`/`Farp` params.

### :Farundo [params]
Undo last (or all) replacement(s).

### :F {pattern} {file-mask} [params]
Find only.

#### Need help?
```bash
:help far.vim
```

## Extras
### Multiline Replacement
![multiline](https://cloud.githubusercontent.com/assets/9823254/20029467/193b7f58-a366-11e6-9a22-05e8464ec0e4.gif)

### Neovim async, Ack, Ag support
![nvim](https://cloud.githubusercontent.com/assets/9823254/20861644/72df878a-b9ae-11e6-9762-449c5d0a1faf.gif)

### Command-Line Completion
![complete](https://cloud.githubusercontent.com/assets/9823254/20029477/8076abd4-a366-11e6-8711-9b4e18367c80.gif)

### Consistency Check
![consistancy](https://cloud.githubusercontent.com/assets/9823254/20029514/70475168-a367-11e6-9a2d-53614730307b.gif)


..and many more! Check out `:help far.vim`.

## License
MIT

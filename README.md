# far.vim - Find And Replace Vim plugin

## Intro
Far.vim makes it easier to find and replace text through multiple files.
It's inspired by fancy IDEs, like IntelliJ and Eclipse, that provide
cozy tools for such tasks.

## Usage

```bash
:Far foo bar **/*.py
:Fardo
```

Need help?
```bash
:help far.vim
```

### :Far {pattern} {replace-with} {file-mask} [params]
Find the text to replace.
![Far](https://cloud.githubusercontent.com/assets/9823254/20029339/aeb02132-a362-11e6-9396-088243bc6ff8.gif)

### :Farp [params]
Same as `Far`, but allows to enter {pattern}, {replace-with} and {file-mask}
one after the other.
![farp](https://cloud.githubusercontent.com/assets/9823254/20029357/4289e474-a363-11e6-88b4-b5f22dbf1fb0.gif)

### :Fardo [params]
Runs the replacement task.
![fardo](https://cloud.githubusercontent.com/assets/9823254/20029384/bb557f1c-a363-11e6-8538-9648f66c1bcf.gif)

### :Refar
Reruns `Far` or `Farp` command with the same arguments.
![refar2](https://cloud.githubusercontent.com/assets/9823254/20029440/0e55432c-a365-11e6-918d-688295c5b14c.gif)

## Features
### Multiline Replacement
![multiline](https://cloud.githubusercontent.com/assets/9823254/20029467/193b7f58-a366-11e6-9a22-05e8464ec0e4.gif)

### Command-Line Completion
![complete](https://cloud.githubusercontent.com/assets/9823254/20029477/8076abd4-a366-11e6-8711-9b4e18367c80.gif)

### Preview & Jump Window
![preview and jump](https://cloud.githubusercontent.com/assets/9823254/20029558/6bedca1a-a368-11e6-8ba9-1f9f6673bc1e.gif)

### Consistency Check
![consistancy](https://cloud.githubusercontent.com/assets/9823254/20029514/70475168-a367-11e6-9a2d-53614730307b.gif)

## Install
#### VimPlug
```vim
Plug 'brooth/far.vim'
```
#### NeoBundle:
```vim
NeoBundle 'brooth/far.vim'
```
#### Vundle:
```vim
Plugin 'brooth/far.vim'
```

## License
MIT

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
![far.vim](https://cloud.githubusercontent.com/assets/9823254/20070492/fe6037de-a539-11e6-9ee8-4b9a02c11c22.gif)

Need help?
```bash
:help far.vim
```

#### :Far {pattern} {replace-with} {file-mask} [params]
Find the text to replace.

#### :Farp [params]
Same as `Far`, but allows to enter {pattern}, {replace-with} and {file-mask}
one after the other.

#### :Fardo [params]
Runs the replacement task.

#### :Refar
Reruns `Far` or `Farp` command with the same arguments.

## Extras
### Multiline Replacement
![multiline](https://cloud.githubusercontent.com/assets/9823254/20029467/193b7f58-a366-11e6-9a22-05e8464ec0e4.gif)

### Command-Line Completion
![complete](https://cloud.githubusercontent.com/assets/9823254/20029477/8076abd4-a366-11e6-8711-9b4e18367c80.gif)

### Consistency Check
![consistancy](https://cloud.githubusercontent.com/assets/9823254/20029514/70475168-a367-11e6-9a2d-53614730307b.gif)

## Installation
#### VimPlug
```vim
Plug 'brooth/far.vim'
```

## License
MIT

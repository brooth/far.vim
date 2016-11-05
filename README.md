# far.vim - FindAndReplace Vim plugin

## Intro
Far.vim makes it easier to find and replace text over the project.
It's inspired by fancy IDEs, like IntellyJ and Eclipse, that provide
cozy tools for such tasks.

## Usage

```bash
:Far foo bar **/*.py
:Fardo
```

### :Far {pattern} {replace-with} {file-mark} [params]
Find the text to replace.


### :Farp [params]
Same as `Far`, but allows to enter {pattern}, {replace-with} and {file-mask}
one after the other.


### :Fardo [params]
Runs the replacement task.


### :Refar
Reruns `Far` or `Farp` command with the same arguments.


## Features
### Multiline Replacement
### Command-Line Completion
### Preview & Jump Window 
### Consistency Check

## License
MIT

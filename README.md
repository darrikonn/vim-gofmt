<h1 align="center">vim-gofmt</h1>

<h3 align="center">NOTE</h3>
<p align="center">The contents of this repo are pure copy-paste from the awesome <a href="https://github.com/fatih/vim-go">vim-go</a> repo.</p>
<p align="center">The only differences is that <b>vim-gofmt</b> strips most of the functionality, leaving only <i>go-fmt</i> and <i>go-imports</i> (along with the binary setup commands) to format your code</p>
<p align="center">The reason is simply that I personally don't like having my vim editor act like a fully fledged IDE with all of its features.</p>
<p align="center">So if you want more features, please check out <a href="https://github.com/fatih/vim-go">vim-go</a></p>

<p align="center">
  <img style="float: right;" src="https://github.com/fatih/vim-go/blob/master/assets/vim-go.png" alt="Vim-go logo"/>
</p>

## Features

This plugin adds Go language support for Vim, with the following main features:

* `gofmt`
* `goimports`

## Install

vim-gofmt requires at least Vim 8.0.1453 or Neovim 0.3.1.

vim-gofmt follows the standard runtime path structure. Below are some helper lines
for popular package managers:

* [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  * `git clone https://github.com/darrikonn/vim-gofmt.git ~/.vim/pack/plugins/start/vim-gofmt`
* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/darrikonn/vim-gofmt.git ~/.vim/bundle/vim-gofmt`
* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'darrikonn/vim-gofmt', { 'do': ':GoUpdateBinaries' }`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'darrikonn/vim-gofmt'`

You will also need to install all the necessary binaries. vim-gofmt makes it easy
to install all of them by providing a command, `:GoInstallBinaries`, which will
`go install` all the required binaries.

## Usage

vim-gofmt exposes four commands:
1. `:GoFmt` - to format your code
2. `:GoImports` - to format/clean your imports
2. `:GoInstallBinaries` - to install the required binaries
2. `:GoUpdateBinaries` - to update the required binaries

## License

The BSD 3-Clause License - see [`LICENSE`](LICENSE) for more details

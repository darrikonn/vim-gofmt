# vim-go [![Build Status](http://img.shields.io/travis/fatih/vim-go.svg?style=flat-square)](https://travis-ci.org/fatih/vim-go)

<p align="center">
  <img style="float: right;" src="assets/vim-go.png" alt="Vim-go logo"/>
</p>

## Features

This plugin adds Go language support for Vim, with the following main features:

* `gofmt` or `goimports` on save keeps the cursor position and undo history.
* Call `gometalinter` with `:GoMetaLinter` to invoke all possible linters
  (`golint`, `vet`, `errcheck`, `deadcode`, etc.) and put the result in the
  quickfix or location list.
* Lint your code with `:GoLint`, run your code through `:GoVet` to catch static

## Install

vim-go requires at least Vim 8.0.1453 or Neovim 0.3.1.

The [**latest stable release**](https://github.com/fatih/vim-go/releases/latest) is the
recommended version to use. If you choose to use the master branch instead,
please do so with caution; it is a _development_ branch.


vim-go follows the standard runtime path structure. Below are some helper lines
for popular package managers:

* [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  * `git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go`
* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go`
* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'fatih/vim-go'`

You will also need to install all the necessary binaries. vim-go makes it easy
to install all of them by providing a command, `:GoInstallBinaries`, which will
`go get` all the required binaries.

Check out the Install section in [the documentation](doc/vim-go.txt) for more
detailed instructions (`:help go-install`).

## Usage

The full documentation can be found at [doc/vim-go.txt](doc/vim-go.txt). You can
display it from within Vim with `:help vim-go`.

Depending on your installation method, you may have to generate the plugin's
[`help tags`](http://vimhelp.appspot.com/helphelp.txt.html#%3Ahelptags)
manually (e.g. `:helptags ALL`).

We also have an [official vim-go tutorial](https://github.com/fatih/vim-go/wiki).

## License

The BSD 3-Clause License - see [`LICENSE`](LICENSE) for more details

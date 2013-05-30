## microbe

Microbe relies on [pathogen](https://github.com/tpope/vim-pathogen) and [Git](http://git-scm.com) to 
provide a simple management tool for Github-hosted [Vim](http://www.vim.org) plugins.

Requires Bash, Vim and Git.

## Installation

TODO

## Usage

```
microbe <command> <parameters>
```

__Commands__

- `help`: show usage information
- `update-pathogen`: update pathogen to the most recent version
- `install <user> <repository>`: clone the given repository and add its contents to `~/.vim/bundle/<repository>`
- `update`: update all plugins

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the same terms as Vim itself. See `:help license`.

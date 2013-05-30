## microbe

Microbe relies on [pathogen](https://github.com/tpope/vim-pathogen) and [Git](http://git-scm.com) to 
provide a simple management tool for Github-hosted [Vim](http://www.vim.org) plugins.

Requires Bash, Vim and Git.

## Installation



## Usage

```
microbe <command> <parameters>
```

__Commands__

- `help`: show usage information
- `version`: show version
- `update-pathogen`: update pathogen to the most recent version
- `install [<GitHub User>] <plugin>`: clone the given plugin and add its contents to pathogen's include path
- `remove [<GitHub User>] <plugin>`: remove the given plugin from pathogen's include path
- `purge [<GitHub User>] <plugin>`: remove the given plugin from the machine
- `update [<GitHub User>] [<plugin>]`: update all plugins or the given one
- `list`: list all repositories maintained by microbe and whether they are used by the current user

If no GitHub user is given, `vim-scripts` will be used. Also, for a given `<plugin>` both repositories 
`<user>/<plugin>` and `<user>/<plugin>.vim` will be checked. 

__NOTE__ : It is necessary to match the repository name's case, since `git clone` seems to be case-sensitive, at
least when cloning from GitHub.

## Examples

```
$ microbe install paredit
* Resolving Package paredit ... OK.
* Loading vim-scripts/paredit.vim ...
* Cloning from https://github.com/vim-scripts/paredit.vim ...

Cloning into '/mnt/data/home/yannick/.microbe/vim-scripts/paredit.vim'...
remote: Counting objects: 37, done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 37 (delta 9), reused 33 (delta 5)
Unpacking objects: 100% (37/37), done.

* Adding to Pathogen Bundles ... OK.
```

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the same terms as Vim itself. See `:help license`.

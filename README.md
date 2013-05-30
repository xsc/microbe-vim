## microbe

Microbe relies on [pathogen](https://github.com/tpope/vim-pathogen) and [Git](http://git-scm.com) to 
provide a simple management tool for Github-hosted [Vim](http://www.vim.org) plugins.

Requires Bash, Vim and Git.

__NOTE__: If you are looking for a command line tool that is able to handle more than just GitHub-hosted
Plugins, you might want to have a look at [vim-pandemic](https://github.com/jwcxz/vim-pandemic). It is,
due to its capabilities, obviously a little more verbose than microbe (oh, how the names fit!) but looks 
rather usable.

__Another NOTE__: This only works with GitHub repositories that have the directories/files to load in their
top-level directory. A prominent example that does _not_ work is [powerline](https://github.com/Lokaltok/powerline).

## Installation

__User Installation__

```
mkdir ~/.bin
curl -fkLo "~/.bin/microbe" "https://raw.github.com/xsc/microbe-vim/stable/src/microbe.sh" 
chmod +x ~/.bin/microbe
```

Make sure to add `~/.bin` to your `$PATH`, e.g. using `export PATH="$PATH:~/.bin"` in your
`~/.bashrc`.

__System-wide Installation__

```
sudo curl -fkLo "/usr/bin/microbe" "https://raw.github.com/xsc/microbe-vim/stable/src/microbe.sh" 
sudo chmod +x /usr/bin/microbe
```

## Usage

```
microbe <command> [<parameters>]
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

## Settings

You can create a file `~/.microbe.conf` that contains key/value pairs:

```
REPO=~/.microbe      # Directory for Git Clones
VERBOSE=yes          # If set to "no", most output will be suppressed
DEBUG=no             # If set to "yes", additional information will be printed
COLORS=yes           # If set to "no", output will not be colorized
```

The same key/value pairs can be given before calling microbe, e.g.:

```
$ COLORS=no microbe list
```

The `REPO` option is very useful if you have a central directory accessible by all
Vim users, either on the same machine or via some network file system, preventing
multiple downloads or updates of the same data. 

## Examples

__Installing from `vim-scripts`__

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

__Installing from specific GitHub User__

```
$ microbe install altercation vim-colors-solarized
* Resolving Package vim-colors-solarized ... OK.
* Loading altercation/vim-colors-solarized ...
* Cloning from https://github.com/altercation/vim-colors-solarized ...

Cloning into '/mnt/data/home/yannick/.microbe/altercation/vim-colors-solarized'...
remote: Counting objects: 16, done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 16 (delta 2), reused 11 (delta 0)
Unpacking objects: 100% (16/16), done.

* Adding to Pathogen Bundles ... OK.
```

__Listing Plugins__

```
$ microbe list
altercation/vim-colors-solarized (installed)
vim-scripts/VimClojure (not installed)
vim-scripts/paredit.vim (installed)
```

__Hitting the Cache__

```
$ microbe install altercation vim-colors-solarized
* Using altercation/vim-colors-solarized from Cache.
```

__Removing a Plugin from Pathogen__

```
$ microbe remove altercation vim-colors-solarized
* Removing altercation/vim-colors-solarized ... OK.
* Removed vim-colors-solarized.

$ microbe list
altercation/vim-colors-solarized (not installed)
vim-scripts/VimClojure (not installed)
vim-scripts/paredit.vim (installed)
```

__Updating all (or some) Plugins__

```
$ microbe update
* Updating altercation/vim-colors-solarized ... OK.
* Updating vim-scripts/VimClojure ... OK.
* Updating vim-scripts/paredit.vim ... OK.

$ microbe update paredit
* Updating vim-scripts/paredit.vim ... OK.
```

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the same terms as Vim itself. See `:help license`.

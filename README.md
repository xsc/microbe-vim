## microbe

__microbe__ relies on [pathogen](https://github.com/tpope/vim-pathogen) and [cURL](http://curl.haxx.se/) 
to provide a simple management tool especially for Github-hosted [Vim](http://www.vim.org) plugins.

Requires `bash`, `curl` and `unzip`. If Git-support is desired, [Git](http://git-scm.com) is required.

__NOTE__: If you are looking for a command line tool that is able to handle more than just Github-hosted
Plugins, you might want to have a look at [vim-pandemic](https://github.com/jwcxz/vim-pandemic). It is,
due to its capabilities, obviously a little more verbose than microbe (oh, how the names fit!) but looks 
rather usable. Not a command line tool but very powerful in the same domain is 
[neobundle](https://github.com/Shougo/neobundle.vim).

## Premise

__microbe__  is all about minimalism. It is a single standalone script (built using 
[bashing](https://github.com/xsc/bashing)) relying only on tools available out-of-the-box on most UNIX systems:
`bash`, `curl`, `unzip`, `column`, ... Only if Git resources shall be accessed is additional work necessary.

The command line interface resembles that of `apt-get`, hopefully making usage intuitive and concise.

## Installation

Current stable Version: __0.2.4__

__User Installation__

```
mkdir ~/.bin
curl -fkLo ~/.bin/microbe "https://raw.github.com/xsc/microbe-vim/stable/bin/microbe.sh" 
chmod +x ~/.bin/microbe
```

Make sure to add `~/.bin` to your `$PATH`, e.g. using `export PATH="$PATH:~/.bin"` in your
`~/.bashrc`.

__System-wide Installation__

```
sudo curl -fkLo "/usr/bin/microbe" "https://raw.github.com/xsc/microbe-vim/stable/bin/microbe.sh" 
sudo chmod +x /usr/bin/microbe
```

## Usage

```
microbe <command> [<parameters>]
```

__Commands__

- `update-pathogen`: update pathogen to the most recent version
- `install [<GitHub User>/]<plugin>`: clone the given plugin and add its contents to pathogen's include path
- `remove [<GitHub User>/]<plugin>`: remove the given plugin from pathogen's include path
- `purge [<GitHub User>/]<plugin>`: remove the given plugin from the machine
- `update [[<GitHub User>/]<plugin>]`: update all plugins or the given one
- `list`: list all repositories maintained by microbe and whether they are used by the current user

Multiple plugins can be given as parameters. If no GitHub user is found, `vim-scripts` will be used. 
Also, for a given `<plugin>` both repositories `<user>/<plugin>` and `<user>/<plugin>.vim` will be checked. 

Alternatively, the location of a Git repository can be given instead of a user/repository pair. Obviously, this
requires [Git](http://git-scm.com).

## Examples

__Installing from `vim-scripts` or specific GitHub User__

```
$ microbe install paredit jrk/vim-ocaml
Installing vim-scripts/paredit.vim ...
- Getting ZIP from https://github.com/vim-scripts/paredit.vim/archive/master.zip ... OK.
- Extracting Archive to /home/yannick/.microbe/vim-scripts/paredit.vim ... OK.
- Activating Plugin: vim-scripts/paredit.vim ... OK.
Installing jrk/vim-ocaml ...
- Getting ZIP from https://github.com/jrk/vim-ocaml/archive/master.zip ... OK.
- Extracting Archive to /home/yannick/.microbe/jrk/vim-ocaml ... OK.
- Activating Plugin: jrk/vim-ocaml ... OK.
```

__Installing from Git Repository__

```
$ microbe install https://github.com/jrk/vim-ocaml
Installing external-git/vim-ocaml ...
- Cloning from https://github.com/jrk/vim-ocaml ...

Cloning into '/home/yannick/.microbe/external-git/vim-ocaml'...
remote: Counting objects: 12, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 12 (delta 1), reused 12 (delta 1)
Unpacking objects: 100% (12/12), done.

- Activating Plugin: external-git/vim-ocaml ... OK.
```

__Updating Plugins__

```
$ microbe update
Updating external-git/vim-ocaml ...

Already up-to-date.

Updating jrk/vim-ocaml ... OK.
Updating vim-scripts/paredit.vim ... OK.
```

Note that since microbe uses the ZIP archives of GitHub hosted repositories, a new version
will always be downloaded, even if no changes occured.

__Listing Plugins__

```
$ microbe list
external-git/vim-ocaml   (installed)  312KB  /home/yannick/.microbe/external-git/vim-ocaml
jrk/vim-ocaml            (installed)  72KB   /home/yannick/.microbe/jrk/vim-ocaml
vim-scripts/paredit.vim  (installed)  108KB  /home/yannick/.microbe/vim-scripts/paredit.vim
```

Note the size difference between `external-git/vim-ocaml` (Git clone) and `jrk/vim-ocaml`.

__Hitting the Cache__

```
$ microbe install paredit
Installing vim-scripts/paredit.vim ...
- Using Cached Plugin.
- Activating Plugin: vim-scripts/paredit.vim ... OK.
```

__Removing a Plugin from Pathogen__

```
$ microbe remove paredit
Removing vim-scripts/paredit.vim ... OK.

$ microbe list
external-git/vim-ocaml   (installed)      312KB  /home/yannick/.microbe/external-git/vim-ocaml
jrk/vim-ocaml            (installed)      72KB   /home/yannick/.microbe/jrk/vim-ocaml
vim-scripts/paredit.vim  (not installed)  108KB  /home/yannick/.microbe/vim-scripts/paredit.vim
```

__Removing a Plugin from Disk__

```
$ microbe purge external-git/vim-ocaml
Removing external-git/vim-ocaml ... OK.
Purging external-git/vim-ocaml ... OK.

$ microbe list
jrk/vim-ocaml            (installed)      72KB   /home/yannick/.microbe/jrk/vim-ocaml
vim-scripts/paredit.vim  (not installed)  108KB  /home/yannick/.microbe/vim-scripts/paredit.vim
```

## Export, Import and Configuration via `.vimrc`

You can use microbe to write the installed plugins to a file:

```
$ microbe export > microbe.plugins
$ cat microbe.plugins
"bundle jrk/vim-ocaml
"bundle paredit
```

The format of the plugin list is suitable for use in `.vimrc`, since `"` indicates a comment
and will thus not influence your actual configuration.

You can import packages using:

```
microbe import [<file>]
```

where `<file>` defaults to your `.vimrc`.

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the MIT license.

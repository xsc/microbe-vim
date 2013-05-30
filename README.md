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

__microbe__  is all about minimalism. It reduces the size of plugins by only retaining necessary 
data (or rather discarding obviously unnecessary one) and offers ways for multiple users to
fetch plugins from a single central directory. The command line interface resembles that of `apt-get`,
hopefully making usage intuitive and concise.

## Installation

Current stable Version: __0.2.1__

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
- `install [<GitHub User>/]<plugin>`: clone the given plugin and add its contents to pathogen's include path
- `remove [<GitHub User>/]<plugin>`: remove the given plugin from pathogen's include path
- `purge [<GitHub User>/]<plugin>`: remove the given plugin from the machine
- `update [[<GitHub User>/]<plugin>]`: update all plugins or the given one
- `list`: list all repositories maintained by microbe and whether they are used by the current user

Multiple plugins can be given as parameters. If no GitHub user is found, `vim-scripts` will be used. 
Also, for a given `<plugin>` both repositories `<user>/<plugin>` and `<user>/<plugin>.vim` will be checked. 

Alternatively, the location of a Git repository can be given instead of a user/repository pair. Obviously, this
requires [Git](http://git-scm.com).

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
$ microbe install paredit jrk/vim-ocaml
* Installing vim-scripts/paredit ...
  - Resolving Package paredit ... OK.
  - Getting ZIP from https://github.com/vim-scripts/paredit.vim/archive/master.zip ... OK.
  - Extracting Archive to /mnt/data/home/yannick/.microbe/vim-scripts/paredit.vim ... OK.
  - Adding to Pathogen Bundles ... OK.
* Installing jrk/vim-ocaml ...
  - Resolving Package vim-ocaml ... OK.
  - Getting ZIP from https://github.com/jrk/vim-ocaml/archive/master.zip ... OK.
  - Extracting Archive to /mnt/data/home/yannick/.microbe/jrk/vim-ocaml ... OK.
  - Adding to Pathogen Bundles ... OK.
```

__Installing from specific GitHub User__

```
$ microbe install altercation vim-colors-solarized
* Installing altercation/vim-colors-solarized ...
  - Resolving Package vim-colors-solarized ... OK.
  - Getting ZIP from https://github.com/altercation/vim-colors-solarized/archive/master.zip ... OK.
  - Extracting Archive to /mnt/data/home/yannick/.microbe/altercation/vim-colors-solarized ... OK.
  - Adding to Pathogen Bundles ... OK.
```

__Installing from Git Repository__

```
$ microbe install https://github.com/jrk/vim-ocaml
* Installing external/vim-ocaml ...
  - Cloning from https://github.com/jrk/vim-ocaml ...

Cloning into '/mnt/data/home/yannick/.microbe/external/vim-ocaml'...
remote: Counting objects: 12, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 12 (delta 1), reused 12 (delta 1)
Unpacking objects: 100% (12/12), done.

  - Adding to Pathogen Bundles ... OK.
```

__Listing Plugins__

```
$ microbe list
altercation/vim-colors-solarized         (installed)       92KB    ../.microbe/altercation/vim-colors-solarized
              external/vim-ocaml         (installed)      308KB    /mnt/data/home/yannick/.microbe/external/vim-ocaml
                   jrk/vim-ocaml         (installed)       68KB    ../.microbe/jrk/vim-ocaml
             vim-scripts/awk.vim         (installed)       24KB    ../.microbe/vim-scripts/awk.vim
         vim-scripts/paredit.vim         (installed)       36KB    ../.microbe/vim-scripts/paredit.vim
         vim-scripts/taglist.vim         (installed)      232KB    ../.microbe/vim-scripts/taglist.vim
          vim-scripts/VimClojure         (installed)      216KB    ../.microbe/vim-scripts/VimClojure
```

Note the size difference between `external/vim-ocaml` (Git clone) and `jrk/vim-ocaml`.

__Hitting the Cache__

```
$ microbe install altercation vim-colors-solarized
* Using altercation/vim-colors-solarized from Cache.
```

__Removing a Plugin from Pathogen__

```
$ microbe remove altercation vim-colors-solarized
* Removing altercation/vim-colors-solarized ... OK.

$ microbe list
altercation/vim-colors-solarized     (not installed)       92KB    ../.microbe/altercation/vim-colors-solarized
                   jrk/vim-ocaml         (installed)       68KB    ../.microbe/jrk/vim-ocaml
             vim-scripts/awk.vim         (installed)       24KB    ../.microbe/vim-scripts/awk.vim
         vim-scripts/paredit.vim         (installed)       36KB    ../.microbe/vim-scripts/paredit.vim
         vim-scripts/taglist.vim         (installed)      232KB    ../.microbe/vim-scripts/taglist.vim
          vim-scripts/VimClojure         (installed)      216KB    ../.microbe/vim-scripts/VimClojure
```

__Updating all (or some) Plugins__

```
$ microbe update
* Updating altercation/vim-colors-solarized ... OK.
* Updating jrk/vim-ocaml ... OK.
* Updating vim-scripts/awk.vim ... OK.
* Updating vim-scripts/paredit.vim ... OK.
* Updating vim-scripts/taglist.vim ... OK.
* Updating vim-scripts/VimClojure ... OK.

$ microbe update paredit
* Updating vim-scripts/paredit.vim ... OK.
* Updating vim-scripts/paredit.vim ... OK.
```

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the same terms as Vim itself. See `:help license`.

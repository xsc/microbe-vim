#!/bin/bash
export __BASHING_VERSION='0.1.0'
export __VERSION='0.2.3'
export __ARTIFACT_ID='microbe'
export __GROUP_ID='microbe'
if [ ! -d "$HOME" ]; then
    echo "Home Directory does not exist. \$HOME = $HOME" 1>&2;
    exit 1;
fi
VIMDIR="$HOME/.vim"
AUTOLOAD="$VIMDIR/autoload"
BUNDLE="$VIMDIR/bundle"
PATHOGEN_VIM="$AUTOLOAD/pathogen.vim"
if [ -z "$MICROBE" ]; then MICROBE="$HOME/.microbe"; fi
if [ -z "$COLORS" ]; then COLORS="yes"; fi
PATHOGEN_REMOTE="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
GITHUB_HTTPS="https://github.com"
DEFAULT_GROUP="vim-scripts"
SELF=$(cd $(dirname "$0") && pwd)
VERBOSE="$VERBOSE"
DEBUG="$DEBUG"
if [[ "$DEBUG" == "yes" ]]; then VERBOSE="yes"; fi
RED="`tput setaf 1`"
GREEN="`tput setaf 2`"
YELLOW="`tput setaf 3`"
BLUE="`tput setaf 4`"
MAGENTA="`tput setaf 5`"
CYAN="`tput setaf 6`"
WHITE="`tput setaf 7`"
RESET="`tput sgr0`"
function colorize() {
    if [[ "$USE_COLORS" != "no" ]]; then
        c="$1"
        shift
        echo -n ${c}${@}${RESET};
    else
        shift
        echo -n "$@";
    fi
}
function green() { colorize "${GREEN}" "${@}"; }
function red() { colorize "${RED}" "${@}"; }
function yellow() { colorize "${YELLOW}" "${@}"; }
function blue() { colorize "${BLUE}" "${@}"; }
function magenta() { colorize "${MAGENTA}" "${@}"; }
function cyan() { colorize "${CYAN}" "${@}"; }
function white() { colorize "${WHITE}" "${@}"; }
function checkUrl() {
    which curl >& /dev/null || error "Dependency missing: curl";
    local url="$1"
    debug "Checking: $url"
    curl -o /dev/null --head --silent --fail "$url"
    local st="$?"
    debug "curl returned status $st."
    if [[ "$st" != "0" ]]; then return 1; fi
    return 0;
}
function parseSpec() {
    local spec="$1"
    local group=""
    local plugin=""
    local url=""
    local path=""
    local dispatch="zip"
    local resolve="yes"
    case "$spec" in
        git://*|https://*|*@*)
            local url="$spec"
            local resolve="no"
            local dispatch="git"
            local group="external-git"
            local plugin=$(basename "$spec" ".git")
            ;;
        */*)
            IFS="/" read -r group plugin <<< "$1"
            local url="$GITHUB_HTTPS/$group/$plugin"
            local path="/archive/master.zip"
            ;;
        *)
            local group="$DEFAULT_GROUP"
            local plugin="$spec"
            local url="$GITHUB_HTTPS/$group/$plugin"
            local path="/archive/master.zip"
            ;;
    esac
    if [ "$resolve" == "yes" ]; then
        local found="no"
        for ext in "" ".vim"; do
            if checkUrl "$url$ext"; then
                local url="$url$ext"
                local plugin="$plugin$ext"
                local found="yes"
                break;
            fi
        done
        if [ "$found" != "yes" ]; then
            fatal "Could not find Plugin: $group/$plugin"
        fi
    fi
    echo "$group $plugin $dispatch $url$path"
}
function pluginPath() {
    local group="$1"
    local plugin="$2"
    echo "$MICROBE/$group/$plugin"
}
function bundlePath() {
    local group="$1"
    local plugin="$2"
    echo "$BUNDLE/${group}_${plugin}"
}
function findPlugin() {
    local spec="$1"
    local group=""
    local plugin=""
    IFS="/" read -r group plugin <<< "$spec"
    if [ -z "$group" ]; then return 1; fi
    if [ -z "$plugin" ]; then plugin="$group"; fi
    for ext in "" ".vim"; do
        local path=$(pluginPath "$group" "$plugin$ext");
        if [ -e "$path/.microbe_spec" ]; then echo "$group $plugin$ext"; fi
    done
    local candidate=$(find "$MICROBE" -maxdepth 2 -mindepth 2 -type d -name "$plugin" -or -name "$plugin.vim" | head -1)
    if [ -z "$candidate" ]; then return 1; fi
    if [ ! -e "$candidate/.microbe_spec" ]; then return 1; fi
    echo "$(basename $(dirname "$candidate")) $(basename "$candidate")"
    return 0
}
function activatePlugin() {
    local group="$1"
    local plugin="$2"
    local path=$(pluginPath "$group" "$plugin")
    local dst=$(bundlePath "$group" "$plugin")
    if [ ! -d "$path" ]; then fatal "No such Plugin: $group/$plugin"; fi
    if ! ln -sf "$path" "$dst" 2> /dev/null; then
        fatal "Could not create symbolic Link at: $dst"
    fi
}
function deactivatePlugin() {
    local group="$1"
    local plugin="$2"
    local dst=$(bundlePath "$group" "$plugin")
    if [ -L "$dst" ]; then rm -f "$dst"; fi
}
function listRepository() {
    set -e
    for dir in `find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort`; do
        local repoDir=$(dirname "$dir")
        local repo=$(basename "$repoDir")
        local userDir=$(dirname "$repoDir")
        local user=$(basename "$userDir")
        local s=$(du -sk "$repoDir")
        local kb=""
        local r=""
        read kb r <<< "$s"
        local installed=$(red "(not installed)")
        if [ -L "$BUNDLE/${user}_${repo}" ]; then local installed=$(green "(installed)"); fi
        verbose "$user/$(yellow "$repo")|$installed|${kb}KB|$repoDir"
    done
    set +e
}
function error() {
    echo -n "$(red "(ERROR)") " 1>&2
    echo "$@" 1>&2
}
function fatal() {
    error "$@";
    exit 1;
}
function success() {
    echo "$(green "$@")"
}
function verbose() {
    if [[ "$VERBOSE" != "no" ]] || [ -z "$VERBOSE" ]; then
        echo "$@" 
    fi
}
function debug() {
    if [[ "$DEBUG" == "yes" ]]; then
        echo -n "$(yellow "(DEBUG) ")" 1>&2;
        echo "$@" 1>&2
    fi
}
which curl >& /dev/null || error "Dependency missing: curl"; 
debug "curl:                 `which curl`"
debug "git:                  `which git`"
debug "microbe repository:   $MICROBE"
debug "home path:            $HOME"
debug "vim autoload path:    $AUTOLOAD"
debug "pathogen bundle path: $AUTOLOAD"
debug "pathogen path:        $PATHOGEN_VIM"
function cli_purge() {
  while [ $# -gt 0 ]; do
      pluginSpec="$1"
      spec=$(findPlugin "$pluginSpec");
      if [ -z "$spec" ]; then shift; continue; fi
      read -r group plugin <<< "$spec"
      __run "remove" "$group/$plugin"
      path=$(pluginPath "$group" "$plugin")
      if [ -d "$path" ]; then
          verbose -n "Purging $(yellow "$group/$plugin") ... "
          rm -rf "$path"
          success "OK."
      fi
      shift
  done
}
function cli_update() {
  set -e
  if [ "$#" == "0" ]; then
      plugins=$(\
          for f in $(find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort); do\
              p=$(dirname "$f");\
              echo "$(basename $(dirname "$p"))/$(basename "$p")";\
          done\
      );
      __run "update" $plugins
  else
      while [ $# -gt 0 ]; do
          pluginSpec="$1"
          spec=$(findPlugin "$pluginSpec");
          if [ -z "$spec" ]; then shift; continue; fi
          read -r group plugin <<< "$spec"
          path=$(pluginPath "$group" "$plugin")
          if [ ! -d "$path" ]; then shift; continue; fi
          if [ ! -d "$path/.git" ]; then
              verbose -n "Updating $(yellow "$group/$plugin") ... "
              mv "$path" "$path@bak"
              if __run "install" "$(cat "$path@bak/.microbe_spec")" 1> /dev/null; then
                  rm -rf "$path@bak"
                  success "OK."
              else
                  mv "$path@bak" "$path"
                  verbose ""
                  fatal "Failed."
              fi
          else
              verbose "Updating $(yellow "$group/$plugin") ..."
              cd "$path"
              verbose ""
              git pull
              verbose ""
              cd "$CWD"
          fi
          shift
      done
  fi
  set +e
}
function cli_install() {
  __run "init"
  while [ $# -gt 0 ]; do
      pluginSpec="$1"
      spec=$(findPlugin "$pluginSpec")
      if [ -z "$spec" ]; then
          if [ -z "$pluginSpec" ]; then shift; continue; fi
          spec=$(parseSpec "$pluginSpec")
          if [ -z "$spec" ]; then exit 1; fi
          read -r group plugin dispatch url <<< "$spec"
          verbose "Installing $(yellow "$group/$plugin") ..."
          path=$(pluginPath "$group" "$plugin")
          if [ ! -d "$path" ]; then
              mkdir -p "$(dirname "$path")"
              __run "fetch.$dispatch" "$group" "$plugin" "$url"
              if [[ "$?" != "0" ]]; then exit 1; fi
              echo "$pluginSpec" > "$path/.microbe_spec"
          fi
      else
          read -r group plugin <<< "$spec"
          verbose "Using cached plugin $(yellow "$group/$plugin")."
      fi
      __run "plugin.activate" "$group" "$plugin"
      if [[ "$?" != "0" ]]; then exit 1; fi
      shift
  done
}
function cli_init() {
  set -e
  for dir in "$AUTOLOAD" "$BUNDLE" "$MICROBE"; do
      if [ ! -d "$dir" ]; then
          verbose -n "* Initializing '`basename "$dir"`' ... "
          mkdir -p "$dir"
          success "OK."
      fi
  done
  if [ ! -s "$PATHOGEN_VIM" ]; then
      verbose -n "* Loading Pathogen ... "
      curl -Sso "$PATHOGEN_VIM" "$PATHOGEN_REMOTE" 
      success "OK."
  fi
  if [ ! -s "$HOME/.vimrc" ]; then
      verbose -n "* Creating '$HOME/.vimrc' ... "
      echo "set nocompatible" > "$HOME/.vimrc"
      echo "call pathogen#infect()" >> "$HOME/.vimrc"
      success "OK."
  else
      set +e
      grep -qx "call pathogen#infect()" "$HOME/.vimrc" >& /dev/null
      if [[ "$?" != "0" ]]; then
          set -e
          verbose -n "* Adding Pathogen to '$HOME/.vimrc' ... "
          mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
          echo "call pathogen#infect()" >> "$HOME/.vimrc"
          cat "$HOME/.vimrc.bak" >> "$HOME/.vimrc"
          success "OK."
      fi
  fi
  set +e
}
function cli_remove() {
  while [ $# -gt 0 ]; do
      pluginSpec="$1"
      spec=$(findPlugin "$pluginSpec");
      if [ -z "$spec" ]; then shift; continue; fi
      read -r group plugin <<< "$spec"
      path=$(bundlePath "$group" "$plugin")
      if [ -e "$path" -a ! -L "$path" ]; then fatal "Not a symbolic Link: $path"; 
      else
          verbose -n "Removing $(yellow "$group/$plugin") ... "
          rm -f "$path"
          success "OK."
      fi
      shift
  done
}
function cli_list() {
  listRepository | column -s "|" -t
}
function cli_version() {
  echo "microbe $(yellow "$__VERSION") (bash $BASH_VERSION)"
}
function cli_update-pathogen() {
  if [ ! -s "$PATHOGEN_VIM" ]; then
      __run "init"
  else
      verbose -n "* Updating Pathogen ... "
      mv "$PATHOGEN_VIM" "$PATHOGEN_VIM.bak"
      curl -Sso "$PATHOGEN_VIM" "$PATHOGEN_REMOTE" 
      if [[ "$?" != "0" ]]; then
          error "Could not download Pathogen."
          mv "$PATHOGEN_VIM.bak" "$PATHOGEN_VIM"
      else 
          rm "$PATHOGEN_VIM.bak"
          success "OK."
      fi
  fi
}
function cli_plugin_activate() {
  group="$1"
  plugin="$2"
  if [ -z "$group" -o -z "$plugin" ]; then
      fatal "Usage: plugin.activate <group id> <plugin id>"
  fi
  if [ ! -L "$(bundlePath "$group" "$plugin")" ]; then
      verbose -n "- Activating Plugin: $group/$plugin ... "
      activatePlugin "$group" "$plugin"
      success "OK."
  fi
}
function cli_plugin_deactivate() {
  group="$1"
  plugin="$2"
  if [ -z "$group" -o -z "$plugin" ]; then
      fatal "Usage: plugin.deactivate <group id> <plugin id>"
  fi
  if [ -L "$(bundlePath "$group" "$plugin")" ]; then
      verbose -n "- Deactivating Plugin: $group/$plugin ... "
      deactivatePlugin "$group" "$plugin"
      success "OK."
  fi
}
function cli_fetch_zip() {
  which curl >& /dev/null || fatal "Dependency missing: curl"
  which unzip >& /dev/null || fatal "Dependency missing: unzip"
  group="$1"
  plugin="$2"
  url="$3"
  if [ -z "$group" -o -z "$plugin" -o -z "$url" ]; then
      fatal "Usage: fetch.zip <group id> <plugin id> <zip url>"
  fi
  dst=$(pluginPath "$group" "$plugin")
  if [ -d "$dst" ]; then fatal "Directory $dst does already exist."; fi
  tmp=$(mktemp -d)
  trap 'rm -r "$tmp";' 0
  verbose -n "- Getting ZIP from $url ... "
  if ! curl -Sso "$tmp/archive.zip" -L --fail "$url" >& /dev/null; then fatal "Download failed."; fi
  success "OK."
  verbose -n "- Extracting Archive to $dst ... "
  unzip "$tmp/archive.zip" -d "$tmp" >& /dev/null
  if [[ "$?" != "0" ]]; then fatal "Extracting failed."; fi
  find "$tmp" -maxdepth 1 -mindepth 1 -type d -name "*-master" -exec "mv" \{\} "$dst" \;
  success "OK."
  exit 0
}
function cli_fetch_git() {
  which git >& /dev/null || fatal "Dependency missing: git";
  group="$1"
  plugin="$2"
  url="$3"
  if [ -z "$group" -o -z "$plugin" -o -z "$url" ]; then
      fatal "Usage: fetch.git <group id> <plugin id> <git repository>"
  fi
  dst=$(pluginPath "$group" "$plugin")
  if [ -d "$dst" ]; then fatal "Directory $dst does already exist."; fi
  verbose "- Cloning from $url ..."
  if [[ "$VERBOSE" != "no" ]]; then
      verbose ""
      git clone --depth=1 "$url" "$dst"
      verbose ""
  else
      set +e
      tmp="`mktemp`"
      trap 'rm -f "$tmp";' 0
      git clone --depth=1 "$url" "$dst" >& "$tmp";
      if [[ "$?" != "0" ]]; then
          cat "$tmp" 1>&2;
          exit 1;
      fi
      set -e
  fi
  set +e
}
function __run() {
  local pid=""
  local status=255
  local cmd="$1"
  shift
  case "$cmd" in
    "") __run "help"; return $?;;
    "purge") cli_purge "$@" & local pid="$!";;
    "update") cli_update "$@" & local pid="$!";;
    "install") cli_install "$@" & local pid="$!";;
    "init") cli_init "$@" & local pid="$!";;
    "remove") cli_remove "$@" & local pid="$!";;
    "list") cli_list "$@" & local pid="$!";;
    "version") cli_version "$@" & local pid="$!";;
    "update-pathogen") cli_update-pathogen "$@" & local pid="$!";;
    "plugin.activate") cli_plugin_activate "$@" & local pid="$!";;
    "plugin.deactivate") cli_plugin_deactivate "$@" & local pid="$!";;
    "fetch.zip") cli_fetch_zip "$@" & local pid="$!";;
    "fetch.git") cli_fetch_git "$@" & local pid="$!";;
    "help")
      echo "Usage: $0 <command> [<parameters> ...]" 1>&2
      cat 1>&2 <<HELP

    help             :  display this help message
    init             :  (no help available)
    install          :  (no help available)
    list             :  (no help available)
    purge            :  (no help available)
    remove           :  (no help available)
    update           :  (no help available)
    update-pathogen  :  (no help available)
    version          :  (no help available)

HELP
      status=0
      ;;
    "version")
      echo "microbe 0.2.3 (bash $BASH_VERSION)"
      status=0
      ;;
    *) echo "Unknown Command: $cmd" 1>&2;;
  esac
  if [ ! -z "$pid" ]; then
      wait "$pid"
      local status=$?
  fi
  return $status
}
__run "$@"
export __STATUS="$?"
exit $__STATUS

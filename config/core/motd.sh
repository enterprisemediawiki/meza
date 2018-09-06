#!/bin/sh
#
# MOTD banner, shown when user connects via 'vagrant ssh'.
# This file is managed by Puppet.
#

rainbow_pipe () {
  local i=0 c
  while IFS= read data; do
    c=$(( 31 + ($i % 7) ))
    IFS=";" printf "\033[%sm" $c 1
    printf "%s\033[0m\n" "${data}"
    i=$((i+1))
  done
}
rainbow_pipe <<'EOM'

     .-''-.          __  ______________   ___
    /  (o) \\        /  |/  / ____/__  /  /   |
 .-'`       ;      / /|_/ / __/    / /  / /| |
'-==.       |     / /  / / /___   / /__/ ___ |
     `._...-;-.  /_/  /_/_____/  /____/_/  |_|
      )--"""   `-.    MediaWiki EZ Admin
     /   .        `-.
    /   /      `.    `-.
    |   \\    ;   \\      `-._________
    |    \    `.`.;          -------`.
     \\    `-.   \\\\\\\\          `---...|
      `.     `-. ```\\.--'._   `---...|
        `-.....7`-.))\\     `-._`-.. /
          `._\\ /   `-`         `-.,'
            / /
           /=(_   Woo-woo-wooooooo... WIKI!!!
        -./--' `
      ,^-(_
      ,--' `
EOM
echo

printf " * To deploy: \033[33;1msudo meza deploy vagrant\033[0m\n"
printf " * Just want to make MediaWiki changes? \033[33;1msudo meza deploy vagrant --tags mediawiki\033[0m\n"
printf " * Don't want to upgrade software? \033[33;1msudo meza deploy vagrant --skip-tags latest\033[0m\n"
printf " * Don't want to run update.php? \033[33;1msudo meza deploy vagrant --skip-tags update.php\033[0m\n"
printf " * Put all the examples together: \033[33;1msudo meza deploy vagrant --tags mediawiki --skip-tags latest,update.php\033[0m\n"
printf " * Other common tags: \033[33;1mverify-wiki, parsoid, smw-data, search-index\033[0m\n"
printf " * For help, visit \033[34;4mhttps://www.mediawiki.org/wiki/Meza\033[0m \n\n"

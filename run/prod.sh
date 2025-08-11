set -e -x

# https://hexdocs.pm/phoenix/deployment.html
# git pull

appname=slink
mixenv=${1:-prod}
export MIX_ENV=${mixenv}

echo "#### Run in Prod mode with mix-env=$mixenv ####"

[ -f .env ] && source .env
[ -f .env.prod ] && source .env.prod

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
  echo "Running in SSH session"
  if [ -d ~/.asdf ]; then 
    source ~/.asdf/asdf.sh
  fi
fi

command asdf &> /dev/null || {
  echo Not found asdf command
  exit 1
}
mixcmd="command asdf exec mix"
# mixcmd=$(command asdf where elixir)/bin/mix
$mixcmd --version

$mixcmd deps.get --only prod
MIX_ENV=$mixenv $mixcmd compile

# db already created by devops!!! not run: MIX_ENV=$mixenv mix setup
MIX_ENV=$mixenv $mixcmd ecto.migrate
# Manual run bellow when init setup
# MIX_ENV=$mixenv $mixcmd run apps/$appname/priv/repo/seeds.exs

## Direct Deploy
# MIX_ENV=$mixenv $mixcmd phx.server
# MIX_ENV=$mixenv elixir --erl "-detached" -S mix phx.server
# MIX_ENV=$mixenv iex -S $mixcmd phx.server

## Deploy with mix-release 
# https://hexdocs.pm/phoenix/releases.html
# https://hexdocs.pm/mix/Mix.Tasks.Release.html

MIX_ENV=$mixenv mix assets.deploy
# mix phx.gen.release
MIX_ENV=$mixenv $mixcmd release --overwrite

relbin=_build/$mixenv/rel/$appname/bin/$appname
echo "$appname old daemon pid=$($relbin pid)" || true
$relbin stop || true

$relbin daemon_iex
sleep 3
echo "$appname new daemon pid=$($relbin pid)"

# # start by tmux
# t_sess=xxx
# tmux kill-session -t $t_sess || true
# tmux new-session -s $t_sess $relbin start_iex
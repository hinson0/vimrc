# 在 ~/.zshrc 中加载：source /path/to/vimrc/zsh/portwho.zsh
# 查看监听指定 TCP 端口的进程 PID 和工作目录。
portwho() {
  emulate -L zsh
  local port="${1-}" pids pid cwd

  if (( $# != 1 )) || [[ "$port" != <-> ]] || (( port < 1 || port > 65535 )); then
    print '用法：portwho <端口号>'
    return 2
  fi

  if ! command -v lsof >/dev/null 2>&1; then
    print '未找到 lsof'
    return 127
  fi

  pids=$(lsof -nP -t -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | sort -un)
  if [[ -z "$pids" ]]; then
    print "端口 $port 没有监听进程"
    return 1
  fi

  for pid in ${(f)pids}; do
    cwd=$(lsof -nP -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')
    printf '端口=%s  PID=%s\n目录=%s\n\n' "$port" "$pid" "${cwd:-无法读取}"
  done
}

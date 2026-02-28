#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  spec-create-branch.sh --short-name <kebab-case> --source-file <path> [--title <text>]

行为:
  - 计算下一个三位编号（来源：远程分支 / 本地分支 / .aisdlc/specs 目录）
  - 创建并切换到 {num}-{short-name} 分支
  - 创建 .aisdlc/specs/{num}-{short-name}/{requirements,design,implementation,verification,release}
  - 写入 requirements/raw.md（UTF-8 with BOM）
  - 删除 --source-file 指向的源文件
  - 输出 JSON（stdout）
EOF
}

die() {
  echo "错误: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "缺少依赖命令: $1"
}

is_valid_short_name() {
  local s="$1"
  [[ "$s" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

resolve_repo_root() {
  local script_dir="$1"
  local repo_root=""
  if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "$repo_root"
    return 0
  fi

  local cur="$script_dir"
  while [[ -n "$cur" && "$cur" != "/" ]]; do
    if [[ -d "$cur/.git" ]]; then
      echo "$cur"
      return 0
    fi
    cur="$(cd "$cur/.." && pwd)"
  done

  die "无法定位仓库根目录（git rev-parse 失败，且未在父目录找到 .git）"
}

find_max_number() {
  local repo_root="$1"
  local max=0

  # 1) 远程分支
  if git fetch --all --prune >/dev/null 2>&1; then
    while IFS= read -r line; do
      # e.g. "  origin/012-foo"
      line="${line#"${line%%origin/*}"}" 2>/dev/null || true
      if [[ "$line" =~ origin/([0-9]{1,3})- ]]; then
        local n="${BASH_REMATCH[1]}"
        # 10# 避免前导 0 触发八进制
        local val=$((10#$n))
        if (( val > max )); then max="$val"; fi
      fi
    done < <(git branch -r 2>/dev/null || true)
  fi

  # 2) 本地分支
  while IFS= read -r line; do
    # e.g. "* 012-foo" or "  012-foo"
    line="${line#\* }"
    line="${line#"${line%%[![:space:]]*}"}"
    if [[ "$line" =~ ^([0-9]{1,3})- ]]; then
      local n="${BASH_REMATCH[1]}"
      local val=$((10#$n))
      if (( val > max )); then max="$val"; fi
    fi
  done < <(git branch 2>/dev/null || true)

  # 3) specs 目录
  local specs_dir="$repo_root/.aisdlc/specs"
  if [[ -d "$specs_dir" ]]; then
    local d
    for d in "$specs_dir"/*; do
      [[ -d "$d" ]] || continue
      local name
      name="$(basename "$d")"
      if [[ "$name" =~ ^([0-9]{1,3})- ]]; then
        local n="${BASH_REMATCH[1]}"
        local val=$((10#$n))
        if (( val > max )); then max="$val"; fi
      fi
    done
  fi

  echo "$max"
}

ensure_branch_not_exists() {
  local branch="$1"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    die "分支已存在（本地）: $branch"
  fi
  if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    die "分支已存在（远程）: origin/$branch"
  fi
}

write_raw_requirement_utf8_bom() {
  local source_file="$1"
  local target_file="$2"

  [[ -f "$source_file" ]] || die "需求文件不存在: $source_file"

  mkdir -p "$(dirname "$target_file")"

  local tmp_content
  tmp_content="$(mktemp)"

  local first3=""
  first3="$(head -c 3 "$source_file" 2>/dev/null || true)"
  if [[ "$first3" == $'\xEF\xBB\xBF' ]]; then
    # 跳过 BOM
    tail -c +4 "$source_file" >"$tmp_content"
  else
    cat "$source_file" >"$tmp_content"
  fi

  # 写入 BOM + 内容
  : >"$target_file"
  printf '\xEF\xBB\xBF' >"$target_file"
  cat "$tmp_content" >>"$target_file"

  rm -f "$tmp_content"
}

json_escape() {
  # 极简 JSON string escape（覆盖 \ " 与控制字符的常见情况）
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  echo "$s"
}

short_name=""
source_file=""
title=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --short-name)
      short_name="${2:-}"; shift 2;;
    --source-file|--source-file-path)
      source_file="${2:-}"; shift 2;;
    --title)
      title="${2:-}"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      die "未知参数: $1（可用 --help 查看用法）";;
  esac
done

[[ -n "$short_name" ]] || die "--short-name 必填"
[[ -n "$source_file" ]] || die "--source-file 必填"

is_valid_short_name "$short_name" || die "short-name 不合法（需 kebab-case，小写字母/数字/连字符）: $short_name"

require_cmd git
require_cmd head
require_cmd tail
require_cmd mktemp

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(resolve_repo_root "$script_dir")"

max_number="$(find_max_number "$repo_root")"
next_number=$((max_number + 1))
formatted_number="$(printf "%03d" "$next_number")"

branch_name="${formatted_number}-${short_name}"

ensure_branch_not_exists "$branch_name"

git checkout -b "$branch_name" >/dev/null

spec_dir="$repo_root/.aisdlc/specs/$branch_name"
[[ -e "$spec_dir" ]] && die "目录已存在: $spec_dir"

mkdir -p "$spec_dir"
mkdir -p "$spec_dir/requirements" "$spec_dir/design" "$spec_dir/implementation" "$spec_dir/verification" "$spec_dir/release"

raw_file="$spec_dir/requirements/raw.md"
write_raw_requirement_utf8_bom "$source_file" "$raw_file"

rm -f "$source_file"

esc_title="$(json_escape "$title")"
printf '{'
printf '"number":"%s",' "$(json_escape "$formatted_number")"
printf '"shortName":"%s",' "$(json_escape "$short_name")"
printf '"branchName":"%s",' "$(json_escape "$branch_name")"
printf '"specDir":"%s",' "$(json_escape "$spec_dir")"
printf '"title":"%s"' "$esc_title"
printf '}\n'


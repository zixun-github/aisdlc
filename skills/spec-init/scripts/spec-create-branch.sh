#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  spec-create-branch.sh --short-name <kebab-case> --source-file <path> [--title <text>]
  （--source-file 与 --source-file-path 等价）

行为:
  - 计算下一个三位编号（来源：远程分支 / 本地分支 / .aisdlc/specs 目录）
  - 创建并切换到 {num}-{short-name} 分支
  - 创建 .aisdlc/specs/{num}-{short-name}/{requirements,design,implementation,verification,release}
  - 写入 requirements/raw.md（UTF-8 with BOM）
  - 删除 --source-file 指向的源文件
  - 输出 REPO_ROOT/CURRENT_BRANCH/FEATURE_DIR/SPEC_NUMBER/SHORT_NAME（stdout）
  - 输出 JSON（stdout）
EOF
}

die() {
  echo "错误: $*" >&2
  exit 1
}

log() {
  echo "$*" >&2
}

log_cyan() {
  printf '\033[36m%s\033[0m\n' "$*" >&2
}

log_yellow() {
  printf '\033[33m%s\033[0m\n' "$*" >&2
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

  find_spec_repo_root() {
    local start_path="$1"
    local cur
    cur="$(cd "$start_path" 2>/dev/null && pwd)" || return 1
    while [[ -n "$cur" && "$cur" != "/" ]]; do
      if [[ -e "$cur/.git" && -d "$cur/.aisdlc" ]]; then
        echo "$cur"
        return 0
      fi
      cur="$(cd "$cur/.." && pwd)"
    done
    return 1
  }

  if repo_root="$(find_spec_repo_root "$(pwd)" 2>/dev/null)"; then
    log_cyan "仓库根目录: $repo_root"
    echo "$repo_root"
    return 0
  fi

  local current_repo_root=""
  local spec_repo_root=""
  if current_repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    if spec_repo_root="$(find_spec_repo_root "$current_repo_root" 2>/dev/null)"; then
      log_cyan "仓库根目录: $spec_repo_root"
      echo "$spec_repo_root"
      return 0
    fi
    log_cyan "仓库根目录: $current_repo_root"
    echo "$current_repo_root"
    return 0
  fi

  log_yellow "警告: 无法使用 git 获取仓库根目录，使用路径解析"
  if repo_root="$(find_spec_repo_root "$script_dir" 2>/dev/null)"; then
    log_cyan "仓库根目录: $repo_root"
    echo "$repo_root"
    return 0
  fi

  # 最后备用方案：从脚本路径向上两级（兼容旧逻辑）
  local fallback
  fallback="$(cd "$script_dir/../.." && pwd)"
  log_yellow "仓库根目录（使用路径解析）: $fallback"
  echo "$fallback"
}

find_max_number() {
  local repo_root="$1"
  local max=0

  # 1) 远程分支
  log "正在获取远程分支..."
  git -C "$repo_root" fetch --all --prune 2>/dev/null || log "  警告: 无法获取远程分支"
  while IFS= read -r line; do
    # e.g. "  origin/012-foo" or "  origin/012-foo -> origin/HEAD"
    local match_line="${line#*origin/}"
    match_line="${match_line%% *}"
    match_line="${match_line%% *}"
    if [[ "$match_line" =~ ^([0-9]{1,3})-([^[:space:]]*)$ ]]; then
      local n="${BASH_REMATCH[1]}"
      local val=$((10#$n))
      if (( val > max )); then max="$val"; fi
      log "  找到远程分支编号: $n (分支: origin/$match_line)"
    fi
  done < <(git -C "$repo_root" branch -r 2>/dev/null || true)

  # 2) 本地分支
  log "正在获取本地分支..."
  while IFS= read -r line; do
    line="${line#\* }"
    line="${line#"${line%%[![:space:]]*}"}"
    if [[ "$line" =~ ^([0-9]{1,3})-([^[:space:]]*)$ ]]; then
      local n="${BASH_REMATCH[1]}"
      local val=$((10#$n))
      if (( val > max )); then max="$val"; fi
      log "  找到本地分支编号: $n (分支: $line)"
    fi
  done < <(git -C "$repo_root" branch 2>/dev/null || true)

  # 3) specs 目录
  log "正在检查 specs 目录..."
  local specs_dir="$repo_root/.aisdlc/specs"
  if [[ -d "$specs_dir" ]]; then
    local d
    for d in "$specs_dir"/*; do
      [[ -d "$d" ]] || continue
      local name
      name="$(basename "$d")"
      if [[ "$name" =~ ^([0-9]{1,3})-(.+)$ ]]; then
        local n="${BASH_REMATCH[1]}"
        local val=$((10#$n))
        if (( val > max )); then max="$val"; fi
        log "  找到 specs 目录编号: $n (目录: $name)"
      fi
    done
  fi

  if (( max > 0 )); then
    log "最大编号: $max"
  else
    log "未找到现有编号，从 0 开始"
  fi
  echo "$max"
}

ensure_branch_not_exists() {
  local repo_root="$1"
  local branch="$2"
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch" || \
     git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    die "分支 '$branch' 已存在"
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
[[ -f "$source_file" ]] || die "需求文件不存在: $source_file"

is_valid_short_name "$short_name" || die "short-name 不合法（需 kebab-case，小写字母/数字/连字符）: $short_name"

require_cmd git
require_cmd head
require_cmd tail
require_cmd mktemp

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(resolve_repo_root "$script_dir")"

log ""
log "=========================================="
log "创建 Spec 工作分支和目录"
log "=========================================="
log "短名称: $short_name"
log "仓库根目录: $repo_root"
log_cyan "当前工作目录: $(pwd)"
log_cyan "脚本根目录: $script_dir"
log_yellow "说明: spec-init 只初始化根项目 Spec Pack；若后续需求涉及子仓，子仓分支应在 I1 -> I2 之间按计划创建并校验。"
log ""

log "步骤 1: 查找最大编号"
log "------------------------------------------"
max_number="$(find_max_number "$repo_root")"
next_number=$((max_number + 1))
formatted_number="$(printf "%03d" "$next_number")"
log "下一个编号: $formatted_number"
log ""

log "步骤 2: 创建分支"
log "------------------------------------------"
branch_name="${formatted_number}-${short_name}"
ensure_branch_not_exists "$repo_root" "$branch_name"
log "正在创建分支: $branch_name"
git -C "$repo_root" checkout -b "$branch_name" 2>/dev/null || die "创建分支失败: git checkout -b $branch_name"
log "分支创建成功: $branch_name"
log ""

log "步骤 3: 创建目录结构"
log "------------------------------------------"
spec_dir="$repo_root/.aisdlc/specs/$branch_name"
[[ -e "$spec_dir" ]] && die "目录已存在: $spec_dir"
log "正在创建目录结构: $spec_dir"
mkdir -p "$spec_dir"
mkdir -p "$spec_dir/requirements" "$spec_dir/design" "$spec_dir/implementation" "$spec_dir/verification" "$spec_dir/release"
log "目录结构创建成功"
log ""

log "步骤 4: 写入原始需求"
log "------------------------------------------"
raw_file="$spec_dir/requirements/raw.md"
log "正在写入原始需求到: $raw_file"
write_raw_requirement_utf8_bom "$source_file" "$raw_file"
log "原始需求已写入"
log ""

log "步骤 5: 删除原始文件"
log "------------------------------------------"
log "正在删除原始文件: $source_file"
rm -f "$source_file"
log "原始文件已删除"
log ""

log "=========================================="
log "完成！"
log "=========================================="

# 输出环境变量（供其他脚本解析）
echo "REPO_ROOT=$repo_root"
echo "CURRENT_BRANCH=$branch_name"
echo "FEATURE_DIR=$spec_dir"
echo "SPEC_NUMBER=$formatted_number"
echo "SHORT_NAME=$short_name"
echo ""

# 输出 JSON（供结构化解析）
esc_title="$(json_escape "$title")"
printf '{'
printf '"number":"%s",' "$(json_escape "$formatted_number")"
printf '"shortName":"%s",' "$(json_escape "$short_name")"
printf '"branchName":"%s",' "$(json_escape "$branch_name")"
printf '"specDir":"%s",' "$(json_escape "$spec_dir")"
printf '"title":"%s"' "$esc_title"
printf '}\n'


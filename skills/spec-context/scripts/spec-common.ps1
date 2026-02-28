#Requires -Version 7.0
# PowerShell 脚本：Spec 级命令的通用上下文信息获取
# 功能：获取和验证 REPO_ROOT、CURRENT_BRANCH、FEATURE_DIR 等上下文信息
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 设置输出编码为 UTF-8 with BOM
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

<#
.SYNOPSIS
获取 Git 仓库根目录

.DESCRIPTION
通过 Git 命令获取当前工作目录所在的 Git 仓库根目录。
如果不在 Git 仓库中，返回 $null。

.OUTPUTS
[string] Git 仓库根目录路径，如果不在 Git 仓库中则返回 $null
#>
function Get-RepoRoot {
    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return $result.Trim()
        }
    } catch {
        # Git 命令失败
    }
    
    return $null
}

<#
.SYNOPSIS
获取当前 Git 分支名称

.DESCRIPTION
通过 git branch --show-current 获取当前分支名称。

.OUTPUTS
[string] 当前分支名称，如果获取失败则返回 $null
#>
function Get-CurrentBranch {
    try {
        $result = git branch --show-current 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return $result.Trim()
        }
    } catch {
        # Git 命令失败
    }
    
    return $null
}

<#
.SYNOPSIS
验证分支名称是否符合 spec 分支命名规范

.DESCRIPTION
验证分支名称是否符合格式：{num}-{short-name}
- num: 1-3 位数字
- short-name: kebab-case（小写字母、数字、连字符）

.PARAMETER Branch
要验证的分支名称

.OUTPUTS
[bool] 如果符合规范返回 $true，否则返回 $false
#>
function Test-SpecBranch {
    param(
        [Parameter(Mandatory)]
        [string]$Branch
    )
    
    # 验证格式：{num}-{short-name}
    # num: 1-3 位数字
    # short-name: kebab-case（小写字母、数字、连字符，至少一个字符）
    if ($Branch -match '^(\d{1,3})-([a-z0-9-]+)$') {
        $shortName = $matches[2]
        # 验证短名称不能以连字符开头或结尾，不能有连续的连字符
        if ($shortName -match '^-|-$|--') {
            return $false
        }
        return $true
    }
    
    return $false
}

<#
.SYNOPSIS
验证 Git 仓库根目录

.DESCRIPTION
验证指定的目录是否为有效的 Git 仓库根目录。
检查是否存在 .git 目录和 .aisdlc/specs 目录。

.PARAMETER RepoRoot
要验证的仓库根目录路径

.OUTPUTS
[bool] 如果是有效的 Git 仓库根目录返回 $true，否则返回 $false
#>
function Test-SpecRepoRoot {
    param(
        [Parameter(Mandatory)]
        [string]$RepoRoot
    )
    
    if (-not $RepoRoot) {
        return $false
    }
    
    # 检查目录是否存在
    if (-not (Test-Path -Path $RepoRoot -PathType Container)) {
        return $false
    }
    
    # 检查是否存在 .git 目录
    $gitDir = Join-Path $RepoRoot '.git'
    if (-not (Test-Path -Path $gitDir -PathType Container)) {
        return $false
    }
    
    # 检查是否存在 .aisdlc/specs 目录（如果不存在，可能需要初始化，但不强制要求）
    # 这里只检查 .aisdlc 目录是否存在
    $aisdlcDir = Join-Path $RepoRoot '.aisdlc'
    if (-not (Test-Path -Path $aisdlcDir -PathType Container)) {
        # .aisdlc 目录不存在，返回 false（需要先初始化）
        return $false
    }
    
    return $true
}

<#
.SYNOPSIS
验证 Spec 目录是否存在且结构完整

.DESCRIPTION
验证指定的 Spec 目录是否存在，并检查是否包含必需的子目录：
- requirements/
- design/
- implementation/
- verification/
- release/

.PARAMETER FeatureDir
要验证的 Spec 目录路径

.OUTPUTS
[bool] 如果目录存在且结构完整返回 $true，否则返回 $false
#>
function Test-SpecFeatureDir {
    param(
        [Parameter(Mandatory)]
        [string]$FeatureDir
    )
    
    if (-not $FeatureDir) {
        return $false
    }
    
    # 检查目录是否存在
    if (-not (Test-Path -Path $FeatureDir -PathType Container)) {
        return $false
    }
    
    # 检查必需的子目录
    $requiredSubDirs = @('requirements', 'design', 'implementation', 'verification', 'release')
    
    foreach ($subDir in $requiredSubDirs) {
        $subDirPath = Join-Path $FeatureDir $subDir
        if (-not (Test-Path -Path $subDirPath -PathType Container)) {
            return $false
        }
    }
    
    return $true
}

<#
.SYNOPSIS
获取 Spec 上下文信息

.DESCRIPTION
获取当前 spec 相关的上下文信息，包括：
- REPO_ROOT: Git 仓库根目录
- CURRENT_BRANCH: 当前分支名称
- FEATURE_DIR: Spec 目录路径

该函数会执行完整的验证流程，如果任何验证失败，会抛出错误。

.OUTPUTS
[PSCustomObject] 包含以下属性的对象：
- REPO_ROOT: Git 仓库根目录路径
- CURRENT_BRANCH: 当前分支名称
- FEATURE_DIR: Spec 目录路径
- SPEC_NUMBER: 分支编号部分（从分支名称提取）
- SHORT_NAME: 分支短名称部分（从分支名称提取）

.EXAMPLE
$context = Get-SpecContext
Write-Host "仓库根目录: $($context.REPO_ROOT)"
Write-Host "当前分支: $($context.CURRENT_BRANCH)"
Write-Host "Spec 目录: $($context.FEATURE_DIR)"
#>
function Get-SpecContext {
    # 1. 获取 REPO_ROOT
    $repoRoot = Get-RepoRoot
    if (-not $repoRoot) {
        Write-Error "错误：当前不在 Git 仓库中。请切换到正确的仓库目录。" -ErrorAction Stop
    }
    
    # 验证 REPO_ROOT
    if (-not (Test-SpecRepoRoot -RepoRoot $repoRoot)) {
        Write-Error "错误：当前目录不是有效的 Git 仓库根目录，或缺少 .aisdlc 目录。请确保在正确的仓库目录中执行命令。" -ErrorAction Stop
    }
    
    # 2. 获取 CURRENT_BRANCH
    $currentBranch = Get-CurrentBranch
    if (-not $currentBranch) {
        Write-Error "错误：无法获取当前 Git 分支。请确保在 Git 仓库中执行命令。" -ErrorAction Stop
    }
    
    # 验证分支名称格式
    if (-not (Test-SpecBranch -Branch $currentBranch)) {
        Write-Error "错误：当前分支名称不符合 spec 分支命名规范。当前分支: $currentBranch`n分支名称格式应为: {num}-{short-name}（如 001-user-auth）`n请切换到正确的 spec 分支或先执行 spec-init 命令创建 spec 分支。" -ErrorAction Stop
    }
    
    # 解析分支名称，提取编号和短名称
    if ($currentBranch -match '^(\d{1,3})-([a-z0-9-]+)$') {
        $specNumber = $matches[1]
        $shortName = $matches[2]
    } else {
        # 理论上不会到达这里，因为已经验证过格式
        Write-Error "错误：无法解析分支名称: $currentBranch" -ErrorAction Stop
    }
    
    # 3. 构建 FEATURE_DIR
    $specsDir = Join-Path $repoRoot ".aisdlc"
    $specsDir = Join-Path $specsDir "specs"
    $featureDir = Join-Path $specsDir $currentBranch
    
    # 验证 FEATURE_DIR
    if (-not (Test-SpecFeatureDir -FeatureDir $featureDir)) {
        Write-Error "错误：Spec 目录不存在或结构不完整。`n目录路径: $featureDir`n请先执行 spec-init 命令创建 spec 分支和目录结构。" -ErrorAction Stop
    }
    
    # 返回上下文信息对象
    return [PSCustomObject]@{
        REPO_ROOT      = $repoRoot
        CURRENT_BRANCH = $currentBranch
        FEATURE_DIR    = $featureDir
        SPEC_NUMBER    = $specNumber
        SHORT_NAME     = $shortName
    }
}

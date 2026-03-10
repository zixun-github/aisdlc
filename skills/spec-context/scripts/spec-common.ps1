#Requires -Version 5.0
# PowerShell 脚本：Spec 级命令的通用上下文信息获取
# 功能：获取和验证 REPO_ROOT、CURRENT_BRANCH、FEATURE_DIR 等上下文信息
# 兼容 PowerShell 5.0（Windows PowerShell）
# 支持两种调用方式：
#   1. 点号引入（dot-source）：. script.ps1  → 导入函数供调用方使用
#   2. 直接调用：& script.ps1 -SkillName "xxx" → 输出 key=value 文本行
param(
    [string]$SkillName
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# 设置输出编码为 UTF-8 with BOM
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 脚本版本号（上报埋点时包含）
$SCRIPT_VERSION = '1.0.1'

# Spec 分支命名正则
$SPEC_BRANCH_PATTERN = '^(\d{1,3})-([a-z0-9-]+)$'

<#
.SYNOPSIS
采集并上报 SDLC 埋点

.DESCRIPTION
采集字段：git 账号（user.email）、git 地址（remote.origin.url）、分支、当前指令（调用 Get-SpecContext 的命令行）、脚本版本号（version）。
通过 POST https://markdown.fzzixun.com/api/v1/tracking 上报，上报失败时静默忽略。
#>

function Get-GitUserEmail {
    try {
        $result = git config user.email 2>$null
        if ($? -and $result) {
            return $result.Trim()
        }
    } catch {
        # ignore
    }
    return $null
}

function Get-GitRemoteOriginUrl {
    try {
        $result = git remote get-url origin 2>$null
        if ($? -and $result) {
            return $result.Trim()
        }
    } catch {
        # ignore
    }
    return $null
}

function New-SdlcTelemetryPayload {
    param(
        [Parameter(Mandatory)]
        [string]$RepoRoot,

        [Parameter(Mandatory)]
        [string]$CurrentBranch,

        [Parameter(Mandatory)]
        [string]$SkillName
    )

    $email = Get-GitUserEmail
    $origin = Get-GitRemoteOriginUrl

    return [PSCustomObject]@{
        gitAccount = $email
        gitUrl     = $origin
        branch     = $CurrentBranch
        command    = $SkillName
        repoRoot   = $RepoRoot
        timestamp  = (Get-Date).ToString("o")
        version    = $SCRIPT_VERSION
    }
}

function Publish-SdlcTelemetry {
    param(
        [Parameter(Mandatory)]
        [string]$RepoRoot,

        [Parameter(Mandatory)]
        [string]$CurrentBranch,

        [Parameter(Mandatory)]
        [string]$SkillName
    )

    try {
        $payload = New-SdlcTelemetryPayload -RepoRoot $RepoRoot -CurrentBranch $CurrentBranch -SkillName $SkillName
        $global:SDLC_LAST_TELEMETRY = $payload

        $apiBody = @{
            gitAccount = $payload.gitAccount
            gitUrl     = $payload.gitUrl
            branch     = $payload.branch
            command    = $payload.command
            repoRoot   = $payload.repoRoot
            version    = $payload.version
        } | ConvertTo-Json -Compress

        try {
            Invoke-RestMethod -Uri 'https://markdown.fzzixun.com/api/v1/tracking' -Method Post -ContentType 'application/json' -Body $apiBody -TimeoutSec 5 | Out-Null
        } catch {
            Write-Warning "埋点上报失败（已忽略）：$($_.Exception.Message)"
        }
    } catch {
        Write-Warning "埋点上报失败（已忽略）：$($_.Exception.Message)"
    }
}

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
        if ($? -and $result) {
            return $result.Trim()
        }
    } catch {
        # Git 命令失败
    }
    
    return $null
}

function Test-GitDirectoryMarker {
    param(
        [Parameter(Mandatory)]
        [string]$RepoRoot
    )

    $gitPath = Join-Path $RepoRoot '.git'
    return (Test-Path -Path $gitPath)
}

function Resolve-SpecRepoRoot {
    param(
        [Parameter(Mandatory)]
        [string]$StartPath
    )

    $currentPath = Resolve-Path $StartPath
    while ($currentPath) {
        $candidate = $currentPath.Path
        $aisdlcDir = Join-Path $candidate '.aisdlc'
        if ((Test-Path -Path $aisdlcDir -PathType Container) -and (Test-GitDirectoryMarker -RepoRoot $candidate)) {
            return $candidate
        }

        $parent = Split-Path $candidate -Parent
        if (-not $parent -or $parent -eq $candidate) {
            break
        }
        $currentPath = Resolve-Path $parent
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
    param(
        [string]$RepoRoot
    )

    try {
        if ($RepoRoot) {
            $result = git -C $RepoRoot branch --show-current 2>$null
        } else {
            $result = git branch --show-current 2>$null
        }
        if ($? -and $result) {
            return $result.Trim()
        }
    } catch {
        # Git 命令失败
    }
    
    return $null
}

function Get-SubmoduleState {
    param(
        [Parameter(Mandatory)]
        [string]$RepoRoot
    )

    $gitmodulesPath = $null
    $pathOutput = @()
    $urlOutput = @()
    $urlMap = @{}
    $submodules = @()
    $line = $null
    $name = $null
    $path = $null
    $fullPath = $null
    $exists = $false
    $branch = ''
    $head = ''
    $status = $null
    $isDirty = $false
    $isDetached = $false
    $remote = ''

    $gitmodulesPath = Join-Path $RepoRoot '.gitmodules'
    if (-not (Test-Path -Path $gitmodulesPath -PathType Leaf)) {
        return @()
    }

    $pathOutput = git -C $RepoRoot config -f $gitmodulesPath --get-regexp '^submodule\..*\.path$' 2>$null
    if (-not $?) {
        return @()
    }

    $urlOutput = git -C $RepoRoot config -f $gitmodulesPath --get-regexp '^submodule\..*\.url$' 2>$null
    $urlMap = @{}
    foreach ($line in $urlOutput) {
        if ([regex]::IsMatch($line, '^submodule\.(.+)\.url\s+(.+)$')) {
            $urlMap[([regex]::Match($line, '^submodule\.(.+)\.url\s+(.+)$')).Groups[1].Value] = ([regex]::Match($line, '^submodule\.(.+)\.url\s+(.+)$')).Groups[2].Value
        }
    }

    $submodules = @()
    foreach ($line in $pathOutput) {
        if (-not [regex]::IsMatch($line, '^submodule\.(.+)\.path\s+(.+)$')) {
            continue
        }

        $name = ([regex]::Match($line, '^submodule\.(.+)\.path\s+(.+)$')).Groups[1].Value
        $path = ([regex]::Match($line, '^submodule\.(.+)\.path\s+(.+)$')).Groups[2].Value
        $fullPath = Join-Path $RepoRoot $path
        $exists = Test-Path -Path $fullPath -PathType Container
        $branch = ''
        $head = ''
        $isDirty = $false
        $isDetached = $false

        if ($exists -and (Test-GitDirectoryMarker -RepoRoot $fullPath)) {
            try {
                $branch = git -C $fullPath branch --show-current 2>$null
                if ($branch) {
                    $branch = $branch.Trim()
                }
            } catch {
                $branch = ''
            }

            try {
                $head = git -C $fullPath rev-parse HEAD 2>$null
                if ($head) {
                    $head = $head.Trim()
                }
            } catch {
                $head = ''
            }

            try {
                $status = git -C $fullPath status --porcelain 2>$null
                $isDirty = [bool]$status
            } catch {
                $isDirty = $false
            }

            $isDetached = [string]::IsNullOrWhiteSpace($branch)
        }

        $remote = if ($urlMap.ContainsKey($name)) { $urlMap[$name] } else { '' }

        $submodules += [PSCustomObject]@{
            name        = $name
            path        = $path
            root        = $fullPath
            remote      = $remote
            branch      = $branch
            head        = $head
            is_dirty    = $isDirty
            is_detached = $isDetached
            exists      = $exists
        }
    }

    return ,@($submodules)
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
    
    $shortName = $null

    # 验证格式：{num}-{short-name}
    # num: 1-3 位数字
    # short-name: kebab-case（小写字母、数字、连字符，至少一个字符）
    if ([regex]::IsMatch($Branch, $SPEC_BRANCH_PATTERN)) {
        $shortName = ([regex]::Match($Branch, $SPEC_BRANCH_PATTERN)).Groups[2].Value
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
    
    # 检查是否存在 .git 目录或文件（兼容 worktree/submodule）
    if (-not (Test-GitDirectoryMarker -RepoRoot $RepoRoot)) {
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
- SUBMODULE_SET_JSON: submodule 状态快照（若存在 `.gitmodules`）

该函数会执行完整的验证流程，如果任何验证失败，会抛出错误。

.OUTPUTS
[PSCustomObject] 包含以下属性的对象：
- REPO_ROOT: Git 仓库根目录路径
- CURRENT_BRANCH: 当前分支名称
- FEATURE_DIR: Spec 目录路径
- SPEC_NUMBER: 分支编号部分（从分支名称提取）
- SHORT_NAME: 分支短名称部分（从分支名称提取）
- SUBMODULE_SET_JSON: submodule 状态快照 JSON（若存在 `.gitmodules`）

.EXAMPLE
$context = Get-SpecContext
Write-Host "仓库根目录: $($context.REPO_ROOT)"
Write-Host "当前分支: $($context.CURRENT_BRANCH)"
Write-Host "Spec 目录: $($context.FEATURE_DIR)"
#>
function Get-SpecContext {
    param(
        [string]$SkillName
    )

    if ([string]::IsNullOrWhiteSpace($SkillName)) {
        $SkillName = 'unknown'
    }

    # 1. 获取 REPO_ROOT
    $currentBranch = $null
    $specNumber = $null
    $shortName = $null
    $repoRoot = $null
    $branchForTelemetry = $null
    $specsDir = $null
    $featureDir = $null
    $submodules = @()
    $repoRoot = Resolve-SpecRepoRoot -StartPath (Get-Location)
    if (-not $repoRoot) {
        $repoRoot = Get-RepoRoot
    }
    if (-not $repoRoot) {
        Write-Error "错误：当前不在 Git 仓库中。请切换到正确的仓库目录。" -ErrorAction Stop
    }

    # 埋点采集：尽量早打印（即使后续校验失败）
    $currentBranch = Get-CurrentBranch -RepoRoot $repoRoot
    $branchForTelemetry = if ($currentBranch) { $currentBranch } else { '' }
    Publish-SdlcTelemetry -RepoRoot $repoRoot -CurrentBranch $branchForTelemetry -SkillName $SkillName
    
    # 验证 REPO_ROOT
    if (-not (Test-SpecRepoRoot -RepoRoot $repoRoot)) {
        Write-Error "错误：当前目录不是有效的 aisdlc 仓库根目录，或缺少 .aisdlc 目录。请确保在正确的仓库目录中执行命令。" -ErrorAction Stop
    }
    
    # 2. 获取 CURRENT_BRANCH（上面已尝试获取；这里保证非空）
    if (-not $currentBranch) {
        Write-Error "错误：无法获取当前 Git 分支。请确保在 Git 仓库中执行命令。" -ErrorAction Stop
    }
    
    # 验证分支名称格式
    if (-not (Test-SpecBranch -Branch $currentBranch)) {
        Write-Error ("错误：当前分支名称不符合 spec 分支命名规范。当前分支: " + $currentBranch + [Environment]::NewLine + "分支名称格式应为: {num}-{short-name}（如 001-user-auth）" + [Environment]::NewLine + "请切换到合适的 spec 分支或先执行 spec-init 命令创建 spec 分支。") -ErrorAction Stop
    }
    
    # 解析分支名称，提取编号和短名称
    if ([regex]::IsMatch($currentBranch, $SPEC_BRANCH_PATTERN)) {
        $specNumber = ([regex]::Match($currentBranch, $SPEC_BRANCH_PATTERN)).Groups[1].Value
        $shortName = ([regex]::Match($currentBranch, $SPEC_BRANCH_PATTERN)).Groups[2].Value
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
    $submodules = Get-SubmoduleState -RepoRoot $repoRoot

    return [PSCustomObject]@{
        REPO_ROOT         = $repoRoot
        CURRENT_BRANCH    = $currentBranch
        FEATURE_DIR       = $featureDir
        SPEC_NUMBER       = $specNumber
        SHORT_NAME        = $shortName
        SUBMODULE_SET_JSON = $(if ((@($submodules)).Count -eq 0) { '[]' } else { ConvertTo-Json -InputObject @($submodules) -Compress -Depth 4 })
    }
}

# ── 直接调用入口 ──
# 当通过 & script.ps1 -SkillName "xxx" 方式调用时，
# 执行 Get-SpecContext 并以 key=value 文本行输出结果，
# 便于调用方用字符串匹配解析，无需点号属性访问。
if ($SkillName) {
    $ctx = Get-SpecContext -SkillName $SkillName
    Write-Output "SUBMODULE_SET_JSON=$($ctx.SUBMODULE_SET_JSON)"
    Write-Output "SPEC_NUMBER=$($ctx.SPEC_NUMBER)"
    Write-Output "SHORT_NAME=$($ctx.SHORT_NAME)"
    Write-Output "REPO_ROOT=$($ctx.REPO_ROOT)"
    Write-Output "CURRENT_BRANCH=$($ctx.CURRENT_BRANCH)"
    Write-Output "FEATURE_DIR=$($ctx.FEATURE_DIR)"

}

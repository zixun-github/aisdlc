#Requires -Version 5.0
# PowerShell 脚本：创建 spec 工作分支和目录
# 功能：查找最大编号、创建分支、创建目录结构、初始化文件
# 兼容 PowerShell 5.0（Windows PowerShell）
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# 设置输出编码为 UTF-8 with BOM
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Resolve-RepoRoot {
  param(
    [Parameter(Mandatory)]
    [string]$ScriptRoot
  )

  function Test-GitMarker {
    param([string]$Path)
    return (Test-Path -LiteralPath (Join-Path $Path '.git'))
  }

  function Find-SpecRepoRoot {
    param([string]$StartPath)

    $currentPath = Resolve-Path $StartPath
    while ($currentPath -and $currentPath.Path -ne (Split-Path $currentPath.Path -Parent)) {
      $candidate = $currentPath.Path
      if ((Test-Path -LiteralPath (Join-Path $candidate '.aisdlc')) -and (Test-GitMarker -Path $candidate)) {
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

  $repoRoot = Find-SpecRepoRoot -StartPath (Get-Location)
  if ($repoRoot) {
    Write-Host "仓库根目录: $repoRoot" -ForegroundColor Cyan
    return $repoRoot
  }

  # 使用 git 命令获取当前工作目录所属仓库根目录；若在子仓内，会继续向上找 .aisdlc 根项目
  try {
    $repoRoot = git rev-parse --show-toplevel 2>&1
    if ($? -and $repoRoot) {
      $repoRoot = (Resolve-Path $repoRoot).Path
      $specRepoRoot = Find-SpecRepoRoot -StartPath $repoRoot
      if ($specRepoRoot) {
        Write-Host "仓库根目录: $specRepoRoot" -ForegroundColor Cyan
        return $specRepoRoot
      }
      Write-Host "仓库根目录: $repoRoot" -ForegroundColor Cyan
      return $repoRoot
    }
  } catch {
    Write-Host "警告: 无法使用 git 获取仓库根目录，使用路径解析: $_" -ForegroundColor Yellow
  }

  $repoRoot = Find-SpecRepoRoot -StartPath $ScriptRoot
  if ($repoRoot) {
    Write-Host "仓库根目录（使用路径解析）: $repoRoot" -ForegroundColor Yellow
    return $repoRoot
  }

  # 最后备用方案：从脚本路径向上两级（兼容旧逻辑）
  $repoRoot = (Resolve-Path (Join-Path $ScriptRoot '..\..')).Path
  Write-Host "仓库根目录（使用路径解析）: $repoRoot" -ForegroundColor Yellow
  return $repoRoot
}

function Find-MaxNumber {
  param(
    [Parameter(Mandatory)]
    [string]$RepoRoot
  )
  
  $numbers = @()
  
  # 1. 获取远程分支编号（匹配 {num}-{short-name} 格式，short-name 可以是任何字符）
  try {
    Write-Host "正在获取远程分支..."
    $null = git -C $RepoRoot fetch --all --prune 2>&1
    
    $remoteBranches = git -C $RepoRoot branch -r 2>&1 | Where-Object { $_ -match "^\s+origin/(\d{1,3})-.+$" }
    foreach ($branch in $remoteBranches) {
      if ($branch -match "(\d{1,3})-.+") {
        $num = [int]$matches[1]
        $numbers += $num
        Write-Host "  找到远程分支编号: $num (分支: $($matches[0]))"
      }
    }
  } catch {
    Write-Host "  警告: 无法获取远程分支: $_"
  }
  
  # 2. 获取本地分支编号（匹配 {num}-{short-name} 格式，short-name 可以是任何字符）
  try {
    Write-Host "正在获取本地分支..."
    $localBranches = git -C $RepoRoot branch 2>&1 | Where-Object { $_ -match "^\s*\*?\s*(\d{1,3})-.+$" }
    foreach ($branch in $localBranches) {
      if ($branch -match "(\d{1,3})-.+") {
        $num = [int]$matches[1]
        $numbers += $num
        Write-Host "  找到本地分支编号: $num (分支: $($matches[0]))"
      }
    }
  } catch {
    Write-Host "  警告: 无法获取本地分支: $_"
  }
  
  # 3. 获取 specs 目录中的编号（匹配 {num}-{short-name} 格式，short-name 可以是任何字符）
  try {
    Write-Host "正在检查 specs 目录..."
    $aisdlcDir = Join-Path $RepoRoot '.aisdlc'
    $specsDir = Join-Path $aisdlcDir 'specs'
    if (Test-Path -LiteralPath $specsDir) {
      $specDirs = Get-ChildItem -LiteralPath $specsDir -Directory -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -match "^(\d{1,3})-.+$" }
      foreach ($dir in $specDirs) {
        if ($dir.Name -match "^(\d{1,3})-.+$") {
          $num = [int]$matches[1]
          $numbers += $num
          Write-Host "  找到 specs 目录编号: $num (目录: $($dir.Name))"
        }
      }
    }
  } catch {
    Write-Host "  警告: 无法检查 specs 目录: $_"
  }
  
  # 返回最大编号，如果没有找到则返回 0
  if ($numbers.Count -gt 0) {
    $maxNumber = ($numbers | Measure-Object -Maximum).Maximum
    Write-Host "最大编号: $maxNumber"
    return $maxNumber
  } else {
    Write-Host "未找到现有编号，从 0 开始"
    return 0
  }
}

function Create-SpecBranch {
  param(
    [Parameter(Mandatory)]
    [string]$Number,
    [Parameter(Mandatory)]
    [string]$ShortName,
    [Parameter(Mandatory)]
    [string]$RepoRoot
  )
  
  $branchName = "$Number-$ShortName"
  
  # 检查分支是否已存在
  $existingBranches = git -C $RepoRoot branch -a 2>&1 | Where-Object { $_ -match "^\s*\*?\s*$([regex]::Escape($branchName))$|origin/$([regex]::Escape($branchName))$" }
  if ($existingBranches) {
    throw "分支 '$branchName' 已存在"
  }
  
  # 创建分支（git 将 "Switched to a new branch" 输出到 stderr，PowerShell 会误判为错误，需临时抑制）
  Write-Host "正在创建分支: $branchName"
  $prevEAP = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  git -C $RepoRoot checkout -b $branchName 2>&1 | Out-Null
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $prevEAP
  if ($exitCode -ne 0) {
    throw "创建分支失败: git checkout -b $branchName"
  }
  
  Write-Host "分支创建成功: $branchName"
  return $branchName
}

function Create-SpecDirectory {
  param(
    [Parameter(Mandatory)]
    [string]$Number,
    [Parameter(Mandatory)]
    [string]$ShortName,
    [Parameter(Mandatory)]
    [string]$RepoRoot
  )
  
  $aisdlcDir = Join-Path $RepoRoot '.aisdlc'
  $specsDir = Join-Path $aisdlcDir 'specs'
  $specDir = Join-Path $specsDir "$Number-$ShortName"
  
  # 检查目录是否已存在
  if (Test-Path -LiteralPath $specDir) {
    throw "目录已存在: $specDir"
  }
  
  Write-Host "正在创建目录结构: $specDir"
  
  # 创建主目录
  New-Item -ItemType Directory -Force -Path $specDir | Out-Null
  
  # 创建子目录
  $subDirs = @('requirements', 'design', 'implementation', 'verification', 'release')
  foreach ($subDir in $subDirs) {
    $subDirPath = Join-Path $specDir $subDir
    New-Item -ItemType Directory -Force -Path $subDirPath | Out-Null
  }
  
  Write-Host "目录结构创建成功"
  return $specDir
}

function Write-RawRequirement {
  param(
    [Parameter(Mandatory)]
    [string]$SpecDir,
    [Parameter(Mandatory)]
    [string]$SourceFilePath
  )
  
  $reqDir = Join-Path $SpecDir 'requirements'
  $rawFile = Join-Path $reqDir 'raw.md'
  Write-Host "正在写入原始需求到: $rawFile"
  
  # 从文件读取内容（使用 UTF-8 with BOM 编码）
  $utf8WithBom = New-Object System.Text.UTF8Encoding $true
  $content = [System.IO.File]::ReadAllText($SourceFilePath, $utf8WithBom)
  
  # 使用 UTF-8 with BOM 编码写入文件
  [System.IO.File]::WriteAllText($rawFile, $content, $utf8WithBom)
  
  Write-Host "原始需求已写入"
}

function Remove-SourceFile {
  param(
    [Parameter(Mandatory)]
    [string]$FilePath
  )
  
  if (Test-Path -LiteralPath $FilePath) {
    Write-Host "正在删除原始文件: $FilePath"
    Remove-Item -LiteralPath $FilePath -Force
    Write-Host "原始文件已删除"
  }
}

# 主函数
function Main {
  param(
    [Parameter(Mandatory)]
    [string]$ShortName,
    [Parameter(Mandatory)]
    [string]$SourceFilePath,
    [string]$Title = ''
  )
  
  # 验证需求文件路径是否存在
  if (-not (Test-Path -LiteralPath $SourceFilePath)) {
    throw "需求文件不存在: $SourceFilePath"
  }
  
  $repoRoot = Resolve-RepoRoot -ScriptRoot $PSScriptRoot
  
  Write-Host "=========================================="
  Write-Host "创建 Spec 工作分支和目录"
  Write-Host "=========================================="
  Write-Host "短名称: $ShortName"
  Write-Host "仓库根目录: $repoRoot"
  Write-Host "当前工作目录: $(Get-Location)" -ForegroundColor Cyan
  Write-Host "脚本根目录: $PSScriptRoot" -ForegroundColor Cyan
  Write-Host "说明: spec-init 只初始化根项目 Spec Pack；若后续需求涉及子仓，子仓分支应在 I1 -> I2 之间按计划创建并校验。" -ForegroundColor Yellow
  Write-Host ""
  
  # 步骤 1: 查找最大编号
  Write-Host "步骤 1: 查找最大编号"
  Write-Host "------------------------------------------"
  $maxNumber = Find-MaxNumber -RepoRoot $repoRoot
  $nextNumber = $maxNumber + 1
  $formattedNumber = $nextNumber.ToString("000")
  Write-Host "下一个编号: $formattedNumber"
  Write-Host ""
  
  # 步骤 2: 创建分支
  Write-Host "步骤 2: 创建分支"
  Write-Host "------------------------------------------"
  $branchName = Create-SpecBranch -Number $formattedNumber -ShortName $ShortName -RepoRoot $repoRoot
  Write-Host ""
  
  # 步骤 3: 创建目录结构
  Write-Host "步骤 3: 创建目录结构"
  Write-Host "------------------------------------------"
  $specDir = Create-SpecDirectory -Number $formattedNumber -ShortName $ShortName -RepoRoot $repoRoot
  Write-Host ""
  
  # 步骤 4: 写入原始需求
  Write-Host "步骤 4: 写入原始需求"
  Write-Host "------------------------------------------"
  Write-RawRequirement -SpecDir $specDir -SourceFilePath $SourceFilePath
  Write-Host ""
  
  # 步骤 5: 删除原始文件
  Write-Host "步骤 5: 删除原始文件"
  Write-Host "------------------------------------------"
  Remove-SourceFile -FilePath $SourceFilePath
  Write-Host ""
  
  Write-Host "=========================================="
  Write-Host "完成！"
  Write-Host "=========================================="
  Write-Output "REPO_ROOT=$repoRoot"
  Write-Output "CURRENT_BRANCH=$branchName"
  Write-Output "FEATURE_DIR=$specDir"
  Write-Output "SPEC_NUMBER=$formattedNumber"
  Write-Output "SHORT_NAME=$ShortName"
  Write-Host ""
  
  # 返回结果（JSON 格式，供其他脚本使用）
  $result = @{
    number = $formattedNumber
    shortName = $ShortName
    branchName = $branchName
    specDir = $specDir
    title = $Title
  }
  
  return $result
}

# 如果直接运行脚本（非作为模块导入），执行主函数
# 注意：param() 块必须在脚本顶部，这里使用 $args 或通过函数参数传递
# 脚本应通过函数调用方式使用，而不是直接执行

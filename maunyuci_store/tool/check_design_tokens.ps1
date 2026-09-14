# Guardrail design token modul maunyuci_store.
# Gagal (exit 1) bila ada pemakaian langsung yang wajib lewat token:
#   - GoogleFonts.* di luar lib/app/core/constants/app_fonts.dart
#     (pengecualian: GoogleFonts.interTextTheme hanya via AppFonts.interTextTheme)
#   - Colors.* material di luar lib/app/core/constants/app_colors.dart
#     (pengecualian: Colors.transparent)
#
# Cara pakai:  powershell -File tool/check_design_tokens.ps1
#   (dijalankan dari root folder maunyuci_store)

$ErrorActionPreference = 'Stop'
$root = Join-Path (Join-Path $PSScriptRoot '..') 'lib'
$failed = $false

Write-Host '== Cek GoogleFonts langsung =='
Get-ChildItem -Path $root -Filter '*.dart' -Recurse |
  Where-Object { $_.Name -ne 'app_fonts.dart' } |
  Select-String -Pattern 'GoogleFonts\.' -CaseSensitive |
  ForEach-Object {
    $failed = $true
    Write-Host ("VIOLATION {0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim())
  }

Write-Host '== Cek Colors material langsung (selain transparent) =='
Get-ChildItem -Path $root -Filter '*.dart' -Recurse |
  Where-Object { $_.Name -ne 'app_colors.dart' } |
  Select-String -Pattern '(?<!App)Colors\.(?!transparent\b)[A-Za-z]+' -CaseSensitive |
  ForEach-Object {
    $failed = $true
    Write-Host ("VIOLATION {0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim())
  }

if ($failed) {
  Write-Host ''
  Write-Host 'Design token check GAGAL. Gunakan AppFonts.* / AppColors.* sebagai gantinya.'
  exit 1
}

Write-Host 'Design token check LOLOS.'

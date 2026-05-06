# ============================================================
# Block 1/6 — Parameters, help, drag & drop, metadata helpers
# ============================================================

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$InputPath,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$OutputPath,

    [string]$PreferredAccel = "",
    [string]$TargetCodec = "",
    [switch]$ForceStabilize,
    [switch]$VerboseMode,

    [switch]$ParallelMode,
    [int]$MaxParallel = 1,
    [switch]$Mirror,
    [int]$RotationMode = 0,
    [switch]$SizeMode,
    [string]$RequestedSizeString = "",
    [string]$FilterChoice = "1,2",

    [switch]$FastCompression,
    [switch]$RotationOnlyAuto,
    [switch]$RotationOnly
)

# ------------------------------------------------------------
# UNIFIED HELP SYSTEM
# ------------------------------------------------------------
$green = "`e[92m"
$cyan  = "`e[96m"
$reset = "`e[0m"

$showShort  = $false
$showHelp   = $false
$showManual = $false

foreach ($a in $args) {
    switch ($a) {
        "-h"        { $showShort = $true }
        "-help"     { $showHelp = $true }
        "--help"    { $showHelp = $true }
        "/help"     { $showHelp = $true }
        "/?"        { $showHelp = $true }
        "-manual"   { $showManual = $true }
        "--manual"  { $showManual = $true }
        "-man"      { $showManual = $true }
        "--man"     { $showManual = $true }
    }
}

if ($showShort -or $showHelp -or $showManual) {

    # --------------------------------------------------------
    # SHORT HELP (-h)
    # --------------------------------------------------------
    if ($showShort) {
        Write-Host ""
        Write-Host "${green}ffmpeg_hw_wrapper.ps1 — Short Help${reset}"
        Write-Host ""

        Write-Host "${cyan}Usage:${reset}"
        Write-Host "  ffmpeg_hw_wrapper.ps1 -InputPath <file|folder> [mode] [options]"
        Write-Host ""

        Write-Host "${cyan}Modes:${reset}"
        Write-Host "  -FastCompression     → Auto HEVC compression, no prompts"
        Write-Host "  -RotationOnlyAuto    → Auto rotation-only (angle/codec/quality), no prompts"
        Write-Host "  -RotationOnly        → Rotate videos only (angle/codec/quality prompts)"
        Write-Host "  (no mode flags)      → Show main menu (Fast/RotationAuto/RotationOnly/Advanced)"
        Write-Host ""

        Write-Host "${cyan}Common:${reset}"
        Write-Host "  -InputPath <path>    → File or folder (drag & drop supported)"
        Write-Host "  -OutputPath <path>   → Optional output file"
        Write-Host ""

        Write-Host "${cyan}Help:${reset}"
        Write-Host "  -help, --help        → Full help"
        Write-Host "  --manual             → Man‑page help"
        Write-Host ""

        exit 0
    }

    # --------------------------------------------------------
    # FULL HELP (-help, --help, /help, /?)
    # --------------------------------------------------------
    if ($showHelp) {
        Write-Host ""
        Write-Host "${green}ffmpeg_hw_wrapper.ps1 — Full Help${reset}"
        Write-Host ""

        Write-Host "${cyan}Usage:${reset}"
        Write-Host "  ffmpeg_hw_wrapper.ps1 -InputPath <file|folder> [mode] [options]"
        Write-Host ""

        Write-Host "${cyan}Modes:${reset}"
        Write-Host "  -FastCompression     → Auto HEVC compression, no prompts"
        Write-Host "  -RotationOnlyAuto    → Auto rotation-only (angle/codec/quality), no prompts"
        Write-Host "  -RotationOnly        → Rotate videos only (angle/codec/quality prompts)"
        Write-Host "  (no mode flags)      → Show main menu (Fast/RotationAuto/RotationOnly/Advanced)"
        Write-Host ""

        Write-Host "${cyan}RotationOnly Options:${reset}"
        Write-Host "  Angles: +90, -90, +180, -180"
        Write-Host "  Codecs: 1=h264, 2=h265"
        Write-Host "  Quality: 1=Lossless, 2=Near-lossless, 3=Normal"
        Write-Host ""

        Write-Host "${cyan}Advanced Options:${reset}"
        Write-Host "  -TargetCodec <h264|hevc|av1>"
        Write-Host "  -ParallelMode"
        Write-Host "  -MaxParallel <int>"
        Write-Host "  -RotationMode <0|1|2|3|4>"
        Write-Host "  -SizeMode"
        Write-Host "  -RequestedSizeString <10MB>"
        Write-Host "  -FilterChoice <1,2,3>"
        Write-Host "  -Mirror"
        Write-Host "  -PreferredAccel <cuda|vaapi|qsv|amf|auto>"
        Write-Host "  -VerboseMode"
        Write-Host ""

        Write-Host "${cyan}Filename Policy:${reset}"
        Write-Host "  FastCompression: <name>_<codec>_<mode>_<timestamp>.ext"
        Write-Host "  RotationOnly:    <name>_<codec>_<mode>_<rotation>_<timestamp>.ext"
        Write-Host "  Advanced:        <name>_<codec>_<mode>_<timestamp>.ext"
        Write-Host ""

        Write-Host "Use --manual for detailed documentation."
        Write-Host ""

        exit 0
    }

    # --------------------------------------------------------
    # MANUAL (--manual, -manual, --man, -man)
    # --------------------------------------------------------
    if ($showManual) {
        Write-Host ""
        Write-Host "${green}FFMPEG_HW_WRAPPER(1) — User Commands${reset}"
        Write-Host ""

        Write-Host "${cyan}NAME${reset}"
        Write-Host "    ffmpeg_hw_wrapper.ps1 — multi‑mode hardware‑accelerated video processing wrapper"
        Write-Host ""

        Write-Host "${cyan}SYNOPSIS${reset}"
        Write-Host "    ffmpeg_hw_wrapper.ps1 -InputPath <file|folder> [mode] [options]"
        Write-Host ""

        Write-Host "${cyan}DESCRIPTION${reset}"
        Write-Host "    Provides:"
        Write-Host "      • Fast hardware‑accelerated compression"
        Write-Host "      • Rotation‑only workflow (interactive)"
        Write-Host "      • Rotation‑only workflow (automatic)"
        Write-Host "      • Advanced per‑file processing (filters/size/rotation)"
        Write-Host "      • Automatic encoder detection"
        Write-Host "      • Optional parallelisation"
        Write-Host "      • Drag & drop support"
        Write-Host ""

        Write-Host "${cyan}MODES${reset}"
        Write-Host "    -FastCompression"
        Write-Host "        Fully automatic HEVC compression."
        Write-Host ""
        Write-Host "    -RotationOnlyAuto"
        Write-Host "        Automatic rotation-only mode:"
        Write-Host "          • Angle from metadata (fallback +90°)"
        Write-Host "          • Codec matched to source (H.264/HEVC)"
        Write-Host "          • Lossless‑oriented quality"
        Write-Host ""
        Write-Host "    -RotationOnly"
        Write-Host "        Rotate videos only. Prompts for:"
        Write-Host "          • Rotation angle"
        Write-Host "          • Codec"
        Write-Host "          • Quality"
        Write-Host ""
        Write-Host "    (no mode flags)"
        Write-Host "        Shows interactive menu:"
        Write-Host "          • Fast Compression"
        Write-Host "          • Rotation Only Automatic"
        Write-Host "          • Rotation Only"
        Write-Host "          • Advanced Work"
        Write-Host ""

        Write-Host "${cyan}ROTATION OPTIONS${reset}"
        Write-Host "    Angles: +90, -90, +180, -180"
        Write-Host "    Codecs: 1=h264, 2=h265"
        Write-Host "    Quality: 1=Lossless, 2=Near-lossless, 3=Normal"
        Write-Host ""

        Write-Host "${cyan}ADVANCED OPTIONS${reset}"
        Write-Host "    -TargetCodec <h264|hevc|av1>"
        Write-Host "    -ParallelMode"
        Write-Host "    -MaxParallel <int>"
        Write-Host "    -RotationMode <0|1|2|3|4>"
        Write-Host "    -SizeMode"
        Write-Host "    -RequestedSizeString <10MB>"
        Write-Host "    -FilterChoice <1,2,3>"
        Write-Host "    -Mirror"
        Write-Host "    -PreferredAccel <cuda|vaapi|qsv|amf|auto>"
        Write-Host "    -VerboseMode"
        Write-Host ""

        Write-Host "${cyan}FILENAME POLICY${reset}"
        Write-Host "    FastCompression: <name>_<codec>_<mode>_<timestamp>.ext"
        Write-Host "    RotationOnly:    <name>_<codec>_<mode>_<rotation>_<timestamp>.ext"
        Write-Host "    Advanced:        <name>_<codec>_<mode>_<timestamp>.ext"
        Write-Host ""

        Write-Host "${cyan}EXIT STATUS${reset}"
        Write-Host "    0   Success"
        Write-Host "    >0  ffmpeg or wrapper error"
        Write-Host ""

        Write-Host "${cyan}AUTHOR${reset}"
        Write-Host "    Script logic designed by Joël Kerléguer"
        Write-Host ""

        Write-Host "${cyan}SEE ALSO${reset}"
        Write-Host "    ffmpeg(1), ffprobe(1)"
        Write-Host ""

        exit 0
    }
}

# INIT FORCED ANGLE VAR
$script:ForcedRotationAngle = $null

# ------------------------------------------------------------
# Drag & drop support (first arg becomes InputPath if not set)
# ------------------------------------------------------------
if (-not $InputPath -and $args.Count -gt 0) {
    $InputPath = $args[0]
}

if (-not $InputPath) {
    Write-Host "Usage: ffmpeg_hw_wrapper.ps1 -InputPath <file-or-folder> [mode/options]"
    exit 1
}

function Write-Info { param($m) if ($VerboseMode) { Write-Host "[INFO] $m" } }
function Write-Warn { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }

# ------------------------------------------------------------
# PreferredAccel handling (named param > script var > prompt)
# ------------------------------------------------------------
if ($PSBoundParameters.ContainsKey('PreferredAccel')) {
    # named param wins
}
else {
    $gv = Get-Variable -Scope Script -Name 'PreferredAccel' -ErrorAction SilentlyContinue
    if ($gv -and $gv.Value) {
        $PreferredAccel = $gv.Value
    }
    else {
        $otherNamed = $PSBoundParameters.Keys | Where-Object {
            $_ -ne 'InputPath' -and $_ -ne 'OutputPath' -and $_ -ne 'PreferredAccel'
        }
        if ($otherNamed.Count -gt 0) {
            $PreferredAccel = ""
        } else {
            $PreferredAccel = Read-Host "Preferred hardware accel (cuda/vaapi/qsv/amf) or leave empty for auto"
        }
    }
}
if (-not $PreferredAccel) { $PreferredAccel = "" }

function Get-AvailableEncoders { & ffmpeg -hide_banner -encoders 2>$null }

function Test-Encoder {
    param([string]$encName)
    try {
        $probeArgs = @(
            "-hide_banner","-f","lavfi","-i",
            "testsrc=duration=0.5:size=320x240:rate=15",
            "-c:v",$encName,"-t","0.5","-f","null","NUL"
        )
        & ffmpeg @probeArgs > $null 2>&1
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Choose-Encoder {
    param([string]$preferred)
    $encs = Get-AvailableEncoders
    if ($preferred -and $preferred -ne "auto") {
        switch ($preferred.ToLower()) {
            "av1" {
                if ($encs -match "av1_nvenc" -and (Test-Encoder "av1_nvenc")) { return "av1_nvenc" }
                if ($encs -match "libaom-av1") { return "libaom-av1" }
            }
            "hevc" {
                if ($encs -match "hevc_nvenc" -and (Test-Encoder "hevc_nvenc")) { return "hevc_nvenc" }
                if ($encs -match "libx265") { return "libx265" }
            }
            "h264" {
                if ($encs -match "h264_nvenc" -and (Test-Encoder "h264_nvenc")) { return "h264_nvenc" }
                if ($encs -match "libx264") { return "libx264" }
            }
        }
    }
    if ($encs -match "av1_nvenc" -and (Test-Encoder "av1_nvenc")) { return "av1_nvenc" }
    if ($encs -match "hevc_nvenc" -and (Test-Encoder "hevc_nvenc")) { return "hevc_nvenc" }
    if ($encs -match "h264_nvenc" -and (Test-Encoder "h264_nvenc")) { return "h264_nvenc" }
    if ($encs -match "libaom-av1") { return "libaom-av1" }
    if ($encs -match "libx265") { return "libx265" }
    if ($encs -match "libx264") { return "libx264" }
    return $null
}

# =====================================================================
# SECTION — METADATA EXTRACTION + GUIDANCE HELPERS
# =====================================================================

function Get-VideoMetadata {
    param([string]$FilePath)

    $json = & ffprobe -v error -show_streams -show_format -of json $FilePath 2>$null
    if (-not $json) { return $null }

    try { $data = $json | ConvertFrom-Json } catch { return $null }

    $v = $data.streams | Where-Object { $_.codec_type -eq "video" } | Select-Object -First 1
    if (-not $v) { return $null }

    # Try to read rotation from stream tags if present
    $rotation = $null
    if ($v.tags -and $v.tags.rotate) {
        $rotation = $v.tags.rotate
    }

    $meta = [ordered]@{
        FileName   = [System.IO.Path]::GetFileName($FilePath)
        Container  = $data.format.format_name
        Codec      = $v.codec_name
        Width      = $v.width
        Height     = $v.height
        FPS        = $v.avg_frame_rate
        Bitrate    = $data.format.bit_rate
        PixFmt     = $v.pix_fmt
        ColorSpace = $v.color_space
        ColorRange = $v.color_range
        ColorPrim  = $v.color_primaries
        Transfer   = $v.color_transfer
        Matrix     = $v.color_matrix
        Chroma     = $v.chroma_location
        BitDepth   = $v.bits_per_raw_sample
        Rotation   = $rotation
    }

    return $meta
}

function Show-MetadataAndGuidance {
    param(
        [hashtable]$Meta,
        [string]$Mode
    )

    if (-not $Meta) { return }

    Write-Host "--------------------------------------------"
    Write-Host "File: $($Meta.FileName)"
    Write-Host "Codec: $($Meta.Codec)"
    Write-Host "Resolution: $($Meta.Width)x$($Meta.Height)"
    Write-Host "Framerate: $($Meta.FPS)"
    Write-Host "Bitrate: $([math]::Round($Meta.Bitrate/1000000,2)) Mbps"
    Write-Host "Color: $($Meta.ColorPrim) / $($Meta.Transfer)"
    Write-Host "Chroma: $($Meta.Chroma)"
    Write-Host "Bit depth: $($Meta.BitDepth)-bit"
    if ($Meta.Rotation) {
        Write-Host "Rotation (metadata): $($Meta.Rotation)°"
    }
    Write-Host "--------------------------------------------"

    Write-Host "Guidance:"
    switch ($Meta.Codec.ToLower()) {
        "h264" {
            Write-Host "  • Re-encoding will cause some loss unless using lossless/near-lossless."
            Write-Host "  • Input is H.264 — lossy, common, medium efficiency."
            Write-Host "  • H.265 preserves quality better at lower bitrates."
            $recommended = "hevc"
        }
        "hevc" {
            Write-Host "  • Input is HEVC — modern, efficient, good quality retention."
            Write-Host "  • Re-encoding to HEVC avoids generational loss."
            $recommended = "hevc"
        }
        "av1" {
            Write-Host "  • Input is AV1 — highly efficient, excellent compression."
            Write-Host "  • Re-encoding to AV1 keeps quality high but is slower."
            $recommended = "av1"
        }
        default {
            Write-Host "  • Input codec is $($Meta.Codec)."
            Write-Host "  • Consider HEVC or AV1 for better compression."
            $recommended = "hevc"
        }
    }

    Write-Host ""
    Write-Host "Recommended output codec: $recommended"

    # Determine whether rotation-quality hint should be shown
    $showRotationHint = $false

    if ($Mode -eq "RotationOnly" -or
        $Mode -eq "RotationOnlyAuto" -or
        $Mode -eq "Advanced") {

        # In Advanced mode, ALWAYS show rotation hint
        $showRotationHint = $true
    }

    if ($showRotationHint) {
        if ($Meta.Codec -eq "h264") {
            Write-Host "Suggested rotation quality: Near-lossless (2)"
        }
        elseif ($Meta.Codec -eq "hevc") {
            Write-Host "Suggested rotation quality: Lossless (1)"
        }
        elseif ($Meta.Codec -eq "av1") {
            Write-Host "Suggested rotation quality: Normal (3)"
        }
        else {
            Write-Host "Suggested rotation quality: Near-lossless (2)"
        }
    }

    Write-Host "--------------------------------------------"
    Write-Host ""
}


# ============================================================
# Block 2/6 — Size helpers, duration, filenames, filters, ffmpeg
# ============================================================

function Parse-SizeString {
    param([string]$s)
    if (-not $s) { return $null }
    $s = $s.Trim().ToUpper()
    if ($s -match '^\s*([0-9]*\.?[0-9]+)\s*(KB|K|MB|M|GB|G|B)?\s*$') {
        $num = [double]$matches[1]
        $unit = $matches[2]
        switch ($unit) {
            "KB" { return [int64]([math]::Round($num * 1024)) }
            "K"  { return [int64]([math]::Round($num * 1024)) }
            "MB" { return [int64]([math]::Round($num * 1024 * 1024)) }
            "M"  { return [int64]([math]::Round($num * 1024 * 1024)) }
            "GB" { return [int64]([math]::Round($num * 1024 * 1024 * 1024)) }
            "G"  { return [int64]([math]::Round($num * 1024 * 1024 * 1024)) }
            default { return [int64]([math]::Round($num)) }
        }
    } else { return $null }
}

function Compute-VideoBitrateKbps {
    param(
        [int64]$targetBytes,
        [double]$durationSeconds,
        [int]$audioKbps = 128
    )
    if (-not $targetBytes -or -not $durationSeconds -or $durationSeconds -le 0) { return $null }
    $audioBits = $audioKbps * 1000 * $durationSeconds
    $totalBits = $targetBytes * 8
    $videoBits = $totalBits - $audioBits
    if ($videoBits -le 0) { return $null }
    $videoKbps = [math]::Floor($videoBits / $durationSeconds / 1000)
    if ($videoKbps -lt 64) { $videoKbps = 64 }
    return [int]$videoKbps
}

function Get-DurationSeconds {
    param([string]$file)
    try {
        $out = & ffprobe -v error -show_entries format=duration -of default=nokey=1:noprint_wrappers=1 $file 2>$null
        if ($out) {
            return [double]::Parse($out.Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
        }
    } catch {}
    return $null
}

function Get-OutputPath {
    param(
        [string]$InputPathLocal,
        [string]$RequestedOutput
    )
    if ($RequestedOutput -and $RequestedOutput.Trim() -ne "") {
        try { return [System.IO.Path]::GetFullPath($RequestedOutput) }
        catch { return $RequestedOutput }
    }
    $dt = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPathLocal)
    $ext  = [System.IO.Path]::GetExtension($InputPathLocal)
    if (-not $script:ChosenCodecTag) { $script:ChosenCodecTag = "auto" }
    if (-not $script:ModeTag) { $script:ModeTag = "crf30" }
    if (-not $script:RotationTag) { $script:RotationTag = "" }

    if ($script:RotationTag) {
        $outName = "{0}_{1}_{2}_{3}_{4}{5}" -f $base, $script:ChosenCodecTag, $script:ModeTag, $script:RotationTag, $dt, $ext
    } else {
        $outName = "{0}_{1}_{2}_{3}{4}" -f $base, $script:ChosenCodecTag, $script:ModeTag, $dt, $ext
    }

    $dir = [System.IO.Path]::GetDirectoryName((Resolve-Path $InputPathLocal).Path)
    return (Join-Path $dir $outName)
}

function Build-VFChain {
    param(
        [bool]$ApplyRotate,
        [string]$RotateTranspose,
        [bool]$UseDenoise,
        [bool]$UseStab,
        [bool]$UseSharpen
    )
    $parts = @()
    if ($UseDenoise) { $parts += "hqdn3d" }
    if ($UseStab)    { $parts += "vidstabtransform=input='transforms.trf':smoothing=30" }
    if ($ApplyRotate -and $RotateTranspose) { $parts += $RotateTranspose }
    if ($UseSharpen) { $parts += "unsharp=5:5:1.0:5:5:0.0" }
    if ($parts.Count -gt 0) { return ($parts -join ",") } else { return $null }
}

function Run-FFmpeg {
    param([string[]]$ArgsArray)
    $cmd = "ffmpeg " + ($ArgsArray -join " ")
    Write-Host "Final ffmpeg command to run:"
    Write-Host $cmd
    try {
        & ffmpeg @ArgsArray
        return $LASTEXITCODE
    } catch {
        Write-Err "ffmpeg failed: $_"
        return -1
    }
}


# ============================================================
# Block 3/6 — Advanced per-file processing (filters/size/rotation)
# ============================================================

function Process-File {
    param(
        [string]$FullInputPath,
        [string]$RequestedOutput
    )

    if (-not (Test-Path $FullInputPath)) {
        Write-Err "Input not found: $FullInputPath"
        return
    }

    $inFull = (Resolve-Path $FullInputPath).Path
    $inDir  = Split-Path -Parent $inFull
    $inLeaf = Split-Path -Leaf  $inFull

    # --------------------------------------------------------
    # Metadata extraction + guidance (Advanced mode)
    # --------------------------------------------------------
    $meta = Get-VideoMetadata $inFull
    Show-MetadataAndGuidance -Meta $meta -Mode "Advanced"

    # --------------------------------------------------------
    # Encoder selection (Advanced)
    # --------------------------------------------------------
    $encoder = Choose-Encoder $TargetCodec
    if (-not $encoder) {
        Write-Warn "No suitable encoder found; defaulting to libx264"
        $encoder = "libx264"
    }

    switch ($encoder) {
        "av1_nvenc"  { $script:ChosenCodecTag = "av1_nvenc" }
        "libaom-av1" { $script:ChosenCodecTag = "av1" }
        "hevc_nvenc" { $script:ChosenCodecTag = "hevc" }
        "libx265"    { $script:ChosenCodecTag = "hevc" }
        "h264_nvenc" { $script:ChosenCodecTag = "h264" }
        default      { $script:ChosenCodecTag = $encoder }
    }

    $script:ModeTag     = "auto"
    $script:RotationTag = ""

    $outPath = Get-OutputPath -InputPathLocal $inFull -RequestedOutput $RequestedOutput

    Write-Info "Processing: $inFull"
    Write-Info "Output: $outPath"
    Write-Info "Chosen encoder: $encoder"

    Push-Location $inDir
    try {

        # ----------------------------------------------------
        # ROTATION METADATA (for Advanced RotationMode 1/2)
        # ----------------------------------------------------
        $rotateMeta = 0
        try {
            $r = & ffprobe -v error -select_streams v:0 -show_entries stream_tags=rotate -of default=nokey=1:noprint_wrappers=1 $inLeaf 2>$null
            if ($r) { $rotateMeta = $r.Trim() }
        } catch { $rotateMeta = 0 }

        # ----------------------------------------------------
        # SIZE MODE (ASK BEFORE vidstabdetect)
        # ----------------------------------------------------
        $encArgs = @()
        if ($SizeMode) {

            if (-not $script:SizeModePerFile) {
                if (-not $script:RequestedSizeString) {
                    $script:RequestedSizeString = Read-Host "Choose target size for ALL videos (e.g. 10MB or 1.5GB):"
                }
                $sizeInput = $script:RequestedSizeString
            }
            else {
                $sizeInput = Read-Host "Choose target size for THIS file (e.g. 10MB or 1.5GB) [Leave empty for quality mode]"
            }

            if ($sizeInput -and $sizeInput.Trim() -ne "") {
                $sizeBytes = Parse-SizeString $sizeInput
                if ($sizeBytes) {
                    $duration = Get-DurationSeconds $inLeaf
                    if ($duration) {
                        $videoKbps = Compute-VideoBitrateKbps -targetBytes $sizeBytes -durationSeconds $duration -audioKbps 128
                        if ($videoKbps) {
                            $script:ModeTag = ("size{0}kb" -f $videoKbps)
                            switch ($encoder) {
                                "av1_nvenc"  { $encArgs += "-c:v","av1_nvenc","-b:v","${videoKbps}k" }
                                "hevc_nvenc" { $encArgs += "-c:v","hevc_nvenc","-b:v","${videoKbps}k","-preset","p5" }
                                "h264_nvenc" { $encArgs += "-c:v","h264_nvenc","-b:v","${videoKbps}k","-preset","p5" }
                                "libaom-av1" { $encArgs += "-c:v","libaom-av1","-b:v","${videoKbps}k" }
                                "libx265"    { $encArgs += "-c:v","libx265","-b:v","${videoKbps}k" }
                                default      { $encArgs += "-c:v","libx264","-b:v","${videoKbps}k" }
                            }
                        }
                    }
                }
            }
        }

        # ----------------------------------------------------
        # ROTATION LOGIC (Advanced RotationMode 1–4)
        # ----------------------------------------------------
        $applyRotate  = $false
        $transposeCmd = ""

        # RotationMode 3: global forced angle
        if ($RotationMode -eq 3 -and $script:ForcedRotationAngle) {
            $RotationChoice = $script:ForcedRotationAngle

            switch ($RotationChoice) {
                "+90"  { $transposeCmd = "transpose=1";             $applyRotate = $true; $script:RotationTag = "rot90" }
                "-90"  { $transposeCmd = "transpose=2";             $applyRotate = $true; $script:RotationTag = "rot-90" }
                "+180" { $transposeCmd = "transpose=2,transpose=2"; $applyRotate = $true; $script:RotationTag = "rot180" }
                "-180" { $transposeCmd = "transpose=2,transpose=2"; $applyRotate = $true; $script:RotationTag = "rot-180" }
            }
        }

        # RotationMode 4: ask per file (Advanced)
        elseif ($RotationMode -eq 4) {

            Write-Host ""
            Write-Host "Choose rotation angle for THIS file:"
            Write-Host "  1) +90°"
            Write-Host "  2) -90°"
            Write-Host "  3) +180°"
            Write-Host "  4) -180°"
            $rotChoice = Read-Host "Enter choice (1-4 or angle: +90, -90, +180, -180)"

            switch ($rotChoice) {
                "1"     { $RotationChoice = "+90" }
                "2"     { $RotationChoice = "-90" }
                "3"     { $RotationChoice = "+180" }
                "4"     { $RotationChoice = "-180" }
                "+90"   { $RotationChoice = "+90" }
                "-90"   { $RotationChoice = "-90" }
                "+180"  { $RotationChoice = "+180" }
                "-180"  { $RotationChoice = "-180" }
                default {
                    Write-Warn "Invalid choice. Defaulting to +90°."
                    $RotationChoice = "+90"
                }
            }

            switch ($RotationChoice) {
                "+90"  { $transposeCmd = "transpose=1";             $applyRotate = $true; $script:RotationTag = "rot90" }
                "-90"  { $transposeCmd = "transpose=2";             $applyRotate = $true; $script:RotationTag = "rot-90" }
                "+180" { $transposeCmd = "transpose=2,transpose=2"; $applyRotate = $true; $script:RotationTag = "rot180" }
                "-180" { $transposeCmd = "transpose=2,transpose=2"; $applyRotate = $true; $script:RotationTag = "rot-180" }
            }
        }

        # RotationMode 1/2: metadata-based
        elseif ($rotateMeta -ne 0 -and $rotateMeta -ne "") {

            if     ($RotationMode -eq 1) { $doRotate = $true }
            elseif ($RotationMode -eq 2) {
                $ans = Read-Host "Detected rotation $rotateMeta degrees. Rotate this file? (y/n) [y]"
                $doRotate = ($ans -eq "" -or $ans.ToLower().StartsWith("y"))
            }
            else { $doRotate = $false }

            if ($doRotate) {
                switch ($rotateMeta) {
                    "90"  { $transposeCmd = "transpose=1";             $applyRotate = $true; $script:RotationTag = "rot90" }
                    "-90" { $transposeCmd = "transpose=2";             $applyRotate = $true; $script:RotationTag = "rot-90" }
                    "180" { $transposeCmd = "transpose=2,transpose=2"; $applyRotate = $true; $script:RotationTag = "rot180" }
                }
            }
        }

        # ----------------------------------------------------
        # STABILISATION PRE-PASS (vidstabdetect)
        # ----------------------------------------------------
        if ($ForceStabilize -or ($FilterChoice -match "2")) {
            Write-Host "Running vidstabdetect (writing transforms.trf)..."
            $argsDetect = @(
                "-y","-i",$inLeaf,
                "-vf","vidstabdetect=shakiness=5:accuracy=15:result='transforms.trf'",
                "-f","null","NUL"
            )
            $rcDetect = Run-FFmpeg -ArgsArray $argsDetect
            if ($rcDetect -ne 0) {
                Write-Warn "vidstabdetect returned non-zero ($rcDetect). Continuing."
            } else {
                Write-Host "transforms.trf created."
            }
        }

        # ----------------------------------------------------
        # FILTER CHAIN (denoise/stab/sharpen + optional rotate)
        # ----------------------------------------------------
        $useDenoise = ($FilterChoice -match "1")
        $useStab    = ($FilterChoice -match "2")
        $useSharpen = ($FilterChoice -match "3")

        $vf = Build-VFChain -ApplyRotate:$applyRotate -RotateTranspose:$transposeCmd -UseDenoise:$useDenoise -UseStab:$useStab -UseSharpen:$useSharpen
        if ($vf) { $vfArg = "-vf"; $vfVal = $vf } else { $vfArg = ""; $vfVal = "" }

        # ----------------------------------------------------
        # ENCODER ARGS (IF NOT SIZE-BASED)
        # ----------------------------------------------------
        if ($encArgs.Count -eq 0) {
            switch ($encoder) {
                "av1_nvenc"  { $encArgs += "-c:v","av1_nvenc","-cq","28" }
                "hevc_nvenc" { $encArgs += "-c:v","hevc_nvenc","-preset","p5","-cq","28" }
                "h264_nvenc" { $encArgs += "-c:v","h264_nvenc","-preset","p5","-cq","23" }
                "libaom-av1" { $encArgs += "-c:v","libaom-av1","-crf","30","-cpu-used","4" }
                "libx265"    { $encArgs += "-c:v","libx265","-crf","28","-preset","medium" }
                default      { $encArgs += "-c:v","libx264","-crf","23","-preset","medium" }
            }
        }

        # ----------------------------------------------------
        # FINAL FFMPEG COMMAND (Advanced)
        # ----------------------------------------------------
        $audioArgs = @("-c:a","aac","-b:a","128k")
        $args = @("-y","-i",$inLeaf)
        if ($vfArg -ne "") { $args += $vfArg; $args += $vfVal }
        $args += $encArgs
        $args += $audioArgs
        $args += $outPath

        $rc = Run-FFmpeg -ArgsArray $args

        if ($rc -ne 0) {
            Write-Warn "Primary encoder ($encoder) failed with exit code $rc. Attempting fallbacks..."
            $fallbackOrder = @("hevc_nvenc","h264_nvenc","libaom-av1","libx264")

            foreach ($fb in $fallbackOrder) {
                if ($fb -eq $encoder) { continue }
                $encs = Get-AvailableEncoders
                if ($encs -notmatch $fb) { continue }
                if ($fb -match "nvenc" -and -not (Test-Encoder $fb)) { continue }

                Write-Host "Trying fallback encoder: $fb"

                switch ($fb) {
                    "hevc_nvenc" { $script:ChosenCodecTag = "hevc"; $encArgs = @("-c:v","hevc_nvenc","-preset","p5","-cq","28") }
                    "h264_nvenc" { $script:ChosenCodecTag = "h264"; $encArgs = @("-c:v","h264_nvenc","-preset","p5","-cq","23") }
                    "libaom-av1" { $script:ChosenCodecTag = "av1";  $encArgs = @("-c:v","libaom-av1","-crf","30","-cpu-used","4") }
                    "libx264"    { $script:ChosenCodecTag = "h264"; $encArgs = @("-c:v","libx264","-crf","23","-preset","medium") }
                }

                $args = @("-y","-i",$inLeaf)
                if ($vfArg -ne "") { $args += $vfArg; $args += $vfVal }
                $args += $encArgs
                $args += $audioArgs
                $args += $outPath

                $rc = Run-FFmpeg -ArgsArray $args
                if ($rc -eq 0) { break }
            }
        }

        if ($rc -eq 0) {
            Write-Host "Encode finished successfully: $outPath"
            if (Test-Path "transforms.trf") {
                try { Remove-Item "transforms.trf" -ErrorAction SilentlyContinue } catch {}
            }
        } else {
            Write-Err "All encodes failed. Last exit code: $rc"
        }

    }
    finally {
        Pop-Location
    }
}


# ============================================================
# Block 4/6 — FastCompression & RotationOnly per-file helpers
# ============================================================

function Process-FastCompressionFile {
    param(
        [string]$FullInputPath,
        [string]$RequestedOutput
    )

    if (-not (Test-Path $FullInputPath)) {
        Write-Err "Input not found: $FullInputPath"
        return
    }

    # --------------------------------------------------------
    # Metadata extraction + guidance (FastCompression mode)
    # --------------------------------------------------------
    $meta = Get-VideoMetadata $FullInputPath
    Show-MetadataAndGuidance -Meta $meta -Mode "FastCompression"
    # --------------------------------------------------------

    # --------------------------------------------------------
    # AUTO-ANSWERS (NO PROMPTS) — INFORM USER
    # --------------------------------------------------------
    if ($PreferredAccel -and $PreferredAccel.Trim() -ne "") {
        $hwChoice = $PreferredAccel
    } else {
        $hwChoice = "auto"
    }

    $autoMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel 0 -TargetCodecLocal "hevc"

    Write-Host ""
    Write-Host "FastCompression automatic decisions:"
    Write-Host "  • Hardware acceleration: $hwChoice"
    Write-Host "  • Parallelisation: enabled"
    Write-Host "  • Jobs: auto (max_safe = $autoMaxParallel)"
    Write-Host "  • Rotation: none"
    Write-Host "  • Video codec: libx265 (HEVC)"
    Write-Host "  • Quality: CRF 28, preset medium"
    Write-Host "  • Audio codec: AAC 128k"
    Write-Host "  • Filters: none"
    Write-Host "  • Size mode: disabled"
    Write-Host "  • Rotation mode: disabled"
    Write-Host ""

    # --------------------------------------------------------
    # Actual FastCompression encode (no prompts)
    # --------------------------------------------------------
    $inFull = (Resolve-Path $FullInputPath).Path
    $inDir  = Split-Path -Parent $inFull
    $inLeaf = Split-Path -Leaf  $inFull

    $script:ChosenCodecTag = "hevc"
    $script:ModeTag        = "fast"
    $script:RotationTag    = ""

    $outPath = Get-OutputPath -InputPathLocal $inFull -RequestedOutput $RequestedOutput

    Push-Location $inDir
    try {
        $encArgs   = @("-c:v","libx265","-crf","28","-preset","medium")
        $audioArgs = @("-c:a","aac","-b:a","128k")

        $args = @("-y","-i",$inLeaf)
        $args += $encArgs
        $args += $audioArgs
        $args += $outPath

        $rc = Run-FFmpeg -ArgsArray $args
        if ($rc -eq 0) {
            Write-Host "Fast compression finished: $outPath"
        } else {
            Write-Err "Fast compression failed with exit code $rc"
        }
    }
    finally {
        Pop-Location
    }
}

# ------------------------------------------------------------
# RotationOnly per-file encoder (used by interactive + auto)
# ------------------------------------------------------------
function Process-RotationOnlyFile {
    param(
        [string]$FullInputPath,
        [string]$RequestedOutput,
        [string]$RotationChoice,
        [string]$CodecChoice,
        [string]$QualityChoice,
        [switch]$SkipMetadata
    )

    if (-not (Test-Path $FullInputPath)) {
        Write-Err "Input not found: $FullInputPath"
        return
    }

    $inFull = (Resolve-Path $FullInputPath).Path
    $inDir  = Split-Path -Parent $inFull
    $inLeaf = Split-Path -Leaf  $inFull

    if (-not $SkipMetadata) {
        $meta = Get-VideoMetadata $inFull
        Show-MetadataAndGuidance -Meta $meta -Mode "RotationOnly"
    }

    # Map rotation choice to transpose filter + tag
    $applyRotate  = $true
    $transposeCmd = ""
    $script:RotationTag = ""

    switch ($RotationChoice) {
        "+90"  { $transposeCmd = "transpose=1";             $script:RotationTag = "rot90" }
        "-90"  { $transposeCmd = "transpose=2";             $script:RotationTag = "rot-90" }
        "+180" { $transposeCmd = "transpose=2,transpose=2"; $script:RotationTag = "rot180" }
        "-180" { $transposeCmd = "transpose=2,transpose=2"; $script:RotationTag = "rot-180" }
        default {
            Write-Warn "Invalid rotation '$RotationChoice'. Defaulting to +90°."
            $transposeCmd = "transpose=1"
            $script:RotationTag = "rot90"
        }
    }

    # Codec + quality mapping (simple, rotation-only)
    $encArgs = @()
    if ($CodecChoice -eq "2") {
        # HEVC
        $script:ChosenCodecTag = "hevc"
        switch ($QualityChoice) {
            "1" { $encArgs = @("-c:v","libx265","-crf","12","-preset","slow") }   # lossless-ish
            "2" { $encArgs = @("-c:v","libx265","-crf","18","-preset","medium") } # near-lossless
            "3" { $encArgs = @("-c:v","libx265","-crf","26","-preset","medium") } # normal
            default {
                Write-Warn "Invalid quality '$QualityChoice'. Defaulting to Lossless for HEVC."
                $encArgs = @("-c:v","libx265","-crf","12","-preset","slow")
            }
        }
    } else {
        # H.264
        $script:ChosenCodecTag = "h264"
        switch ($QualityChoice) {
            "1" { $encArgs = @("-c:v","libx264","-crf","10","-preset","slow") }   # lossless-ish
            "2" { $encArgs = @("-c:v","libx264","-crf","18","-preset","medium") } # near-lossless
            "3" { $encArgs = @("-c:v","libx264","-crf","23","-preset","medium") } # normal
            default {
                Write-Warn "Invalid quality '$QualityChoice'. Defaulting to Lossless for H.264."
                $encArgs = @("-c:v","libx264","-crf","10","-preset","slow")
            }
        }
    }

    $script:ModeTag = "rot"

    $outPath = Get-OutputPath -InputPathLocal $inFull -RequestedOutput $RequestedOutput

    # Rotation-only filter chain (no denoise/stab/sharpen here)
    $vf = $null
    if ($applyRotate -and $transposeCmd) {
        $vf = $transposeCmd
    }

    Push-Location $inDir
    try {
        $audioArgs = @("-c:a","aac","-b:a","128k")
        $args = @("-y","-i",$inLeaf)
        if ($vf) { $args += "-vf"; $args += $vf }
        $args += $encArgs
        $args += $audioArgs
        $args += $outPath

        $rc = Run-FFmpeg -ArgsArray $args
        if ($rc -eq 0) {
            Write-Host "Rotation-only encode finished: $outPath"
        } else {
            Write-Err "Rotation-only encode failed with exit code $rc"
        }
    }
    finally {
        Pop-Location
    }
}

function Process-RotationOnlyAutoFile {
    param(
        [string]$FullInputPath,
        [string]$RequestedOutput
    )

    if (-not (Test-Path $FullInputPath)) {
        Write-Err "Input not found: $FullInputPath"
        return
    }

    $inFull = (Resolve-Path $FullInputPath).Path

    # --------------------------------------------------------
    # Metadata extraction + guidance (RotationOnlyAuto mode)
    # --------------------------------------------------------
    $meta = Get-VideoMetadata $inFull
    Show-MetadataAndGuidance -Meta $meta -Mode "RotationOnlyAuto"
    # --------------------------------------------------------

    # Auto rotation from metadata (fallback +90)
    $RotationChoice = "+90"
    if ($meta -and $meta.Rotation) {
        $rot = [int]$meta.Rotation
        switch ($rot) {
            90   { $RotationChoice = "+90" }
            -90  { $RotationChoice = "-90" }
            180  { $RotationChoice = "+180" }
            -180 { $RotationChoice = "-180" }
            default { $RotationChoice = "+90" }
        }
    }

    # Auto codec: match source
    $CodecChoice = "1"
    if ($meta -and $meta.Codec) {
        $c = $meta.Codec.ToLower()
        if ($c -like "*265*" -or $c -like "*hevc*") { $CodecChoice = "2" }
        else { $CodecChoice = "1" }
    }

    # Auto quality: lossless-ish
    $QualityChoice = "1"

    # Auto parallelisation info (per file, informational)
    $targetCodecLocal = if ($CodecChoice -eq "2") { "hevc" } else { "h264" }
    $autoMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel 0 -TargetCodecLocal $targetCodecLocal

    Write-Host ""
    Write-Host "RotationOnlyAuto automatic decisions:"
    Write-Host "  • Hardware acceleration: auto"
    Write-Host "  • Filters: rotation only"
    Write-Host "  • Rotation mode: auto"
    Write-Host "  • Rotation: $RotationChoice (auto from metadata, +90° fallback)"
    Write-Host "  • Video codec: " -NoNewline
    if ($CodecChoice -eq "2") { Write-Host "libx265 (HEVC, match source)" } else { Write-Host "libx264 (H.264, match source)" }
    Write-Host "  • Quality: Lossless"
    Write-Host "  • Audio codec: AAC 128k"
    Write-Host "  • Size mode: disabled"
    Write-Host "  • Parallelisation: enabled"
    Write-Host "  • Parallelisation: auto (max_safe = $autoMaxParallel)"
    Write-Host ""

    # Reuse RotationOnly per-file encoder (no extra prompts)
    Process-RotationOnlyFile `
        -FullInputPath $inFull `
        -RequestedOutput $RequestedOutput `
        -RotationChoice $RotationChoice `
        -CodecChoice $CodecChoice `
        -QualityChoice $QualityChoice `
        -SkipMetadata
}

function Get-EffectiveMaxParallel {
    param(
        [int]$UserMaxParallel,
        [string]$TargetCodecLocal
    )

    if ($UserMaxParallel -gt 0) {
        return [math]::Max(1, $UserMaxParallel)
    }

    $logical = [Environment]::ProcessorCount
    $encs = Get-AvailableEncoders

    if ($TargetCodecLocal -eq "av1" -or $TargetCodecLocal -eq "av1_nvenc") {
        # AV1 is heavy; keep concurrency conservative
        return 1
    }

    return [math]::Max(1, [math]::Floor($logical / 2))
}


# ============================================================
# Block 5/6 — RotationOnly controllers (interactive + auto)
# ============================================================

function Run-RotationOnlyMode {
    param(
        [string]$InputPathLocal,
        [string]$OutputPathLocal
    )

    # Resolve input
    if (-not (Test-Path $InputPathLocal)) {
        Write-Err "Input not found: $InputPathLocal"
        return
    }

    # --------------------------------------------------------
    # Metadata extraction + guidance BEFORE ANY PROMPTS
    # --------------------------------------------------------
    $meta = Get-VideoMetadata $InputPathLocal
    Show-MetadataAndGuidance -Meta $meta -Mode "RotationOnly"
    # --------------------------------------------------------

    # Ask rotation angle
    Write-Host ""
    Write-Host "Choose rotation angle:"
    Write-Host "  1) +90°"
    Write-Host "  2) -90°"
    Write-Host "  3) +180°"
    Write-Host "  4) -180°"
    $rotChoice = Read-Host "Enter choice (1-4 or angle: +90, -90, +180, -180)"

    switch ($rotChoice) {
        "1"     { $RotationChoice = "+90" }
        "2"     { $RotationChoice = "-90" }
        "3"     { $RotationChoice = "+180" }
        "4"     { $RotationChoice = "-180" }
        "+90"   { $RotationChoice = "+90" }
        "-90"   { $RotationChoice = "-90" }
        "+180"  { $RotationChoice = "+180" }
        "-180"  { $RotationChoice = "-180" }
        default {
            Write-Warn "Invalid choice. Defaulting to +90°."
            $RotationChoice = "+90"
        }
    }

    # Ask codec
    Write-Host ""
    Write-Host "Choose codec:"
    Write-Host "  1) H.264"
    Write-Host "  2) H.265 / HEVC"
    $codecChoice = Read-Host "Enter choice (1-2)"

    if ($codecChoice -ne "1" -and $codecChoice -ne "2") {
        Write-Warn "Invalid choice. Defaulting to H.264."
        $codecChoice = "1"
    }

    # Ask quality
    Write-Host ""
    Write-Host "Choose quality:"
    Write-Host "  1) Lossless"
    Write-Host "  2) Near-lossless"
    Write-Host "  3) Normal"
    $qualityChoice = Read-Host "Enter choice (1-3)"

    if ($qualityChoice -notin @("1","2","3")) {
        Write-Warn "Invalid choice. Defaulting to Lossless."
        $qualityChoice = "1"
    }

    # --------------------------------------------------------
    # Parallel / concurrency options (RotationOnly)
    # --------------------------------------------------------
    if ($PSBoundParameters.ContainsKey('ParallelMode')) {
        # use provided
    } else {
        $gv = Get-Variable -Scope Script -Name 'ParallelMode' -ErrorAction SilentlyContinue
        if ($gv -and $gv.Value) {
            $ParallelMode = $true
            $gv2 = Get-Variable -Scope Script -Name 'MaxParallel' -ErrorAction SilentlyContinue
            if ($gv2 -and $gv2.Value) { $MaxParallel = $gv2.Value }
        } else {
            $parallelQ = Read-Host "Enable parallel encoding (start multiple ffmpeg processes)? (y/n) [y]"
            if ($parallelQ -eq "" -or $parallelQ.ToLower().StartsWith("y")) {
                $ParallelMode = $true
                $capQ = Read-Host "Set concurrency cap? (y/n) [n]"
                if ($capQ -and $capQ.ToLower().StartsWith("y")) {
                    $capVal = Read-Host "Enter max number of parallel jobs (integer)"
                    if ($capVal -match '^\d+$') { $MaxParallel = [int]$capVal } else { $MaxParallel = 2 }
                } else {
                    $MaxParallel = 0
                }
            } else {
                $ParallelMode = $false
                $MaxParallel = 1
            }
        }
    }

    # --------------------------------------------------------
    # ALWAYS show parallelisation summary to the user
    # --------------------------------------------------------
    $targetCodecLocal = if ($codecChoice -eq "2") { "hevc" } else { "h264" }
    $effectiveMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel $MaxParallel -TargetCodecLocal $targetCodecLocal

    Write-Host ""
    Write-Host "RotationOnly parallelisation:"
    Write-Host "  • Parallel mode: $ParallelMode"
    Write-Host "  • Jobs: $effectiveMaxParallel (effective max_safe)"
    Write-Host ""

    # --------------------------------------------------------
    # Collect files (single, folder, multi)
    # --------------------------------------------------------
    $inputItem = Get-Item $InputPathLocal

    $files = @()
    if ($inputItem.PSIsContainer) {
        $files = Get-ChildItem -Path $InputPathLocal -Recurse -File -Include *.mp4,*.mov,*.mkv,*.avi,*.webm,*.m4v
    } else {
        $files = @($inputItem)
    }

    if ($files.Count -eq 0) {
        Write-Warn "No video files found for rotation in: $InputPathLocal"
        return
    }

    # --------------------------------------------------------
    # Sequential vs parallel execution (RotationOnly)
    # --------------------------------------------------------
    if (-not $ParallelMode -or $files.Count -eq 1) {
        foreach ($f in $files) {
            Process-RotationOnlyFile `
                -FullInputPath $f.FullName `
                -RequestedOutput $OutputPathLocal `
                -RotationChoice $RotationChoice `
                -CodecChoice $codecChoice `
                -QualityChoice $qualityChoice `
                -SkipMetadata
        }
        return
    }

    # Parallel path
    $targetCodecLocal = if ($codecChoice -eq "2") { "hevc" } else { "h264" }
    $effectiveMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel $MaxParallel -TargetCodecLocal $targetCodecLocal

    Write-Host ""
    Write-Host "RotationOnly parallelisation:"
    Write-Host "  • Parallel mode: enabled"
    Write-Host "  • Jobs: $effectiveMaxParallel (effective max_safe)"
    Write-Host ""

    $extraScript = @"
param(
    [string]`$FullInputPath,
    [string]`$RequestedOutput,
    [string]`$RotationChoice,
    [string]`$CodecChoice,
    [string]`$QualityChoice
)
"@

    Run-Parallel `
        -Files $files `
        -FunctionName "Process-RotationOnlyFile" `
        -EffectiveMaxParallel $effectiveMaxParallel `
        -ExtraScript $extraScript `
        -ExtraArgs @{
            RotationChoice = $RotationChoice
            CodecChoice    = $codecChoice
            QualityChoice  = $qualityChoice
            SkipMetadata   = $true
        }

    Write-Info "All RotationOnly jobs completed."
}

function Run-RotationOnlyAutoMode {
    param(
        [string]$InputPathLocal,
        [string]$OutputPathLocal
    )

    if (-not (Test-Path $InputPathLocal)) {
        Write-Err "Input not found: $InputPathLocal"
        return
    }

    # Collect files (single or folder)
    $inputItem = Get-Item $InputPathLocal

    $files = @()
    if ($inputItem.PSIsContainer) {
        $files = Get-ChildItem -Path $InputPathLocal -Recurse -File -Include *.mp4,*.mov,*.mkv,*.avi,*.webm,*.m4v
    } else {
        $files = @($inputItem)
    }

    if ($files.Count -eq 0) {
        Write-Warn "No video files found for RotationOnlyAuto in: $InputPathLocal"
        return
    }

    # Compute auto parallelisation (needed for both single and multi-file)
    $autoMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel 0 -TargetCodecLocal "h264"

    # Single file → direct processing
    if ($files.Count -eq 1) {
        Process-RotationOnlyAutoFile -FullInputPath $files[0].FullName -RequestedOutput $OutputPathLocal
        return
    }

    # Parallel execution for auto mode
    $effectiveMaxParallel = $autoMaxParallel

    $extraScript = @"
param(
    [string]`$FullInputPath,
    [string]`$RequestedOutput
)
"@

    Run-Parallel `
        -Files $files `
        -FunctionName "Process-RotationOnlyAutoFile" `
        -EffectiveMaxParallel $effectiveMaxParallel `
        -ExtraScript $extraScript

    Write-Info "All RotationOnlyAuto jobs completed."
}


# ============================================================
# Block 6/6 — Global mode dispatch and advanced workflow
# ============================================================

# ------------------------------------------------------------
# MODE DISPATCH (FastCompression, RotationOnly, RotationOnlyAuto)
# ------------------------------------------------------------

if ($FastCompression -and $PSBoundParameters.ContainsKey('FastCompression')) {
    Process-FastCompressionFile -FullInputPath $InputPath -RequestedOutput $OutputPath
    exit 0
}

if ($RotationOnlyAuto -and $PSBoundParameters.ContainsKey('RotationOnlyAuto')) {
    Run-RotationOnlyAutoMode -InputPathLocal $InputPath -OutputPathLocal $OutputPath
    exit 0
}

if ($RotationOnly -and $PSBoundParameters.ContainsKey('RotationOnly')) {
    Run-RotationOnlyMode -InputPathLocal $InputPath -OutputPathLocal $OutputPath
    exit 0
}

# ------------------------------------------------------------
# MENU IF NO FLAGS (simple entry point)
# ------------------------------------------------------------
$hasAdvancedFlags =
    $PSBoundParameters.ContainsKey('TargetCodec')   -or
    $PSBoundParameters.ContainsKey('ParallelMode')  -or
    $PSBoundParameters.ContainsKey('SizeMode')      -or
    $PSBoundParameters.ContainsKey('FilterChoice')  -or
    $PSBoundParameters.ContainsKey('RotationMode')

if (
    -not $FastCompression -and
    -not $RotationOnly -and
    -not $RotationOnlyAuto -and
    -not $hasAdvancedFlags
) {
    Write-Host ""
    Write-Host "Select mode:"
    Write-Host "  1) Fast Compression"
    Write-Host "  2) Rotation Only Automatic"
    Write-Host "  3) Rotation Only"
    Write-Host "  4) Advanced Work"
    $modeChoice = Read-Host "Enter choice (1-4) [1]"

    switch ($modeChoice) {
        "2" { Run-RotationOnlyAutoMode -InputPathLocal $InputPath -OutputPathLocal $OutputPath; exit 0 }
        "3" { Run-RotationOnlyMode     -InputPathLocal $InputPath -OutputPathLocal $OutputPath; exit 0 }
        "4" { } # continue to Advanced
        default {
            Process-FastCompressionFile -FullInputPath $InputPath -RequestedOutput $OutputPath
            exit 0
        }
    }
}

# ------------------------------------------------------------
# ADVANCED MODE ENTRY
# ------------------------------------------------------------
if (-not (Test-Path $InputPath)) {
    Write-Err "Input path not found: $InputPath"
    exit 1
}

# ------------------------------------------------------------
# METADATA PREVIEW FOR FIRST FILE (ADVANCED MODE)
# ------------------------------------------------------------
function Get-FirstVideoFile {
    param([string]$Path)

    $item = Get-Item $Path

    if (-not $item.PSIsContainer) {
        return $item.FullName
    }

    $files = Get-ChildItem -Path $Path -Recurse -File -Include *.mp4,*.mov,*.mkv,*.avi,*.webm,*.m4v
    if ($files.Count -gt 0) {
        return $files[0].FullName
    }

    return $null
}

$firstVideo = Get-FirstVideoFile -Path $InputPath

if ($firstVideo) {
    Write-Host ""
    Write-Host "--------------------------------------------"
    Write-Host "Metadata for FIRST FILE (to help choose codec)"
    Write-Host "--------------------------------------------"
    $meta = Get-VideoMetadata $firstVideo
    Show-MetadataAndGuidance -Meta $meta -Mode "Advanced"
    Write-Host ""
} else {
    Write-Warn "No video files found for metadata preview."
}

# ------------------------------------------------------------
# CODEC SELECTION (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('TargetCodec')) {
    Write-Host "Choose codec:"
    Write-Host "  1 - H.265 / HEVC"
    Write-Host "  2 - AV1"
    Write-Host "  3 - H.264"
    $choice = Read-Host "Codec (1/2/3) [1]"
    if ($choice -eq "2") { $TargetCodec = "av1" }
    elseif ($choice -eq "3") { $TargetCodec = "h264" }
    else { $TargetCodec = "hevc" }
}

# ------------------------------------------------------------
# PARALLEL MODE (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('ParallelMode')) {
    $parallelQ = Read-Host "Enable parallel encoding (start multiple ffmpeg processes)? (y/n) [y]"
    if ($parallelQ -eq "" -or $parallelQ.ToLower().StartsWith("y")) {
        $ParallelMode = $true
        $capQ = Read-Host "Set concurrency cap? (y/n) [n]"
        if ($capQ -and $capQ.ToLower().StartsWith("y")) {
            $capVal = Read-Host "Enter max number of parallel jobs (integer)"
            if ($capVal -match '^\d+$') { $MaxParallel = [int]$capVal } else { $MaxParallel = 2 }
        } else {
            $MaxParallel = 0
        }
    } else {
        $ParallelMode = $false
        $MaxParallel = 1
    }
}

# ------------------------------------------------------------
# MIRROR MODE (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('Mirror')) {
    $mirrorQ = Read-Host "Mirror folder structure for dropped folders? (y/n) [n]"
    $Mirror = ($mirrorQ -and $mirrorQ.ToLower().StartsWith("y"))
}

# ------------------------------------------------------------
# ROTATION MODE (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('RotationMode')) {
    Write-Host "Rotation mode:"
    Write-Host "  0 - No rotation handling"
    Write-Host "  1 - Auto-rotate if metadata != 0"
    Write-Host "  2 - Ask per file if rotation metadata != 0"
    Write-Host "  3 - Rotate all videos to the same angle"
    Write-Host "  4 - Rotate each video to a respective angle (ask every time)"
    $rot = Read-Host "Choose rotation mode (0/1/2/3/4) [0]"

    switch ($rot) {
        "1" { $RotationMode = 1 }
        "2" { $RotationMode = 2 }
        "3" { $RotationMode = 3 }
        "4" { $RotationMode = 4 }
        default { $RotationMode = 0 }
    }

    # RotationMode 3 → ask global angle
    if ($RotationMode -eq 3) {
        Write-Host ""
        Write-Host "Force rotation angle for ALL files:"
        Write-Host "  1) +90°"
        Write-Host "  2) -90°"
        Write-Host "  3) +180°"
        Write-Host "  4) -180°"
        $forceChoice = Read-Host "Enter choice (1-4 or angle: +90, -90, +180, -180)"

        switch ($forceChoice) {
            "1"     { $script:ForcedRotationAngle = "+90" }
            "2"     { $script:ForcedRotationAngle = "-90" }
            "3"     { $script:ForcedRotationAngle = "+180" }
            "4"     { $script:ForcedRotationAngle = "-180" }
            "+90"   { $script:ForcedRotationAngle = "+90" }
            "-90"   { $script:ForcedRotationAngle = "-90" }
            "+180"  { $script:ForcedRotationAngle = "+180" }
            "-180"  { $script:ForcedRotationAngle = "-180" }
            default {
                Write-Warn "Invalid choice. Defaulting to +90°."
                $script:ForcedRotationAngle = "+90"
            }
        }
    }

    # RotationMode 4 → ALWAYS per-file angle (Advanced)
    if ($RotationMode -eq 4) {
        $script:RotationAnglePerFile = $true
    }
}

# ------------------------------------------------------------
# SIZE MODE (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('SizeMode')) {
    $sizeQ = Read-Host "Do you want to choose a specific target size? (y/n) [n]"
    $SizeMode = ($sizeQ -and $sizeQ.ToLower().StartsWith("y"))

    if ($SizeMode) {
        Write-Host ""
        Write-Host "Size selection mode:"
        Write-Host "  1 - Use ONE size for ALL videos"
        Write-Host "  2 - Ask for a size for EACH video"
        $sizeModeChoice = Read-Host "Choose size mode (1/2) [1]"

        if ($sizeModeChoice -eq "2") {
            $script:SizeModePerFile = $true
            $script:RequestedSizeString = ""
        } else {
            $script:SizeModePerFile = $false
            $script:RequestedSizeString = Read-Host "Choose target size for ALL videos (e.g. 10MB or 1.5GB):"
        }
    } else {
        $script:SizeModePerFile = $true
        $script:RequestedSizeString = ""
    }

    $script:SizeMode = $SizeMode
}

# ------------------------------------------------------------
# FILTERS (Advanced)
# ------------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('FilterChoice')) {
    $fQ = Read-Host "Enable filters (denoise/stabilize/sharpen)? (y/n) [y]"
    if ($fQ -and $fQ.ToLower().StartsWith("n")) {
        $FilterChoice = ""
    } else {
        Write-Host "Choose filters (comma separated):"
        Write-Host "  1 - Denoise (hqdn3d)"
        Write-Host "  2 - Stabilize (vidstab)"
        Write-Host "  3 - Sharpen (unsharp)"
        $fChoice = Read-Host "Filters (e.g. 1,2,3) [1,2]"
        if (-not $fChoice) { $fChoice = "1,2" }
        $FilterChoice = $fChoice -replace '\s+',''
    }
}

# ------------------------------------------------------------
# FILE OR FOLDER DISPATCH (Advanced)
# ------------------------------------------------------------
$inputItem = Get-Item $InputPath

if (-not $inputItem.PSIsContainer) {
    Process-File -FullInputPath $InputPath -RequestedOutput $OutputPath
    exit 0
}

# ------------------------------------------------------------
# FOLDER — collect files (Advanced)
# ------------------------------------------------------------
$files = Get-ChildItem -Path $InputPath -Recurse -File -Include *.mp4,*.mov,*.mkv,*.avi,*.webm,*.m4v
if ($files.Count -eq 0) {
    Write-Warn "No video files found in folder: $InputPath"
    exit 0
}

if (-not $ParallelMode -or $files.Count -eq 1) {
    foreach ($f in $files) {
        Process-File -FullInputPath $f.FullName -RequestedOutput $null
    }
    exit 0
}

# ------------------------------------------------------------
# PARALLEL MODE (Advanced)
# ------------------------------------------------------------
$effectiveMaxParallel = Get-EffectiveMaxParallel -UserMaxParallel $MaxParallel -TargetCodecLocal $TargetCodec
Write-Info "Advanced parallel mode. Effective MaxParallel = $effectiveMaxParallel"

$extraScript = @"
param([string]`$FullInputPath,[string]`$RequestedOutput)
"@
Run-Parallel -Files $files -FunctionName "Process-File" -EffectiveMaxParallel $effectiveMaxParallel -ExtraScript $extraScript
Write-Info "All advanced jobs completed."

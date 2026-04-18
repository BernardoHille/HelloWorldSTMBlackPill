param(
    [switch]$Flash,
    [string]$ProgrammerPath = 'C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe',
    [string]$ToolchainBin = 'C:\Program Files (x86)\Arm GNU Toolchain arm-none-eabi\14.2 rel1\bin'
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$gcc = Join-Path $ToolchainBin 'arm-none-eabi-gcc.exe'
$objcopy = Join-Path $ToolchainBin 'arm-none-eabi-objcopy.exe'
$size = Join-Path $ToolchainBin 'arm-none-eabi-size.exe'

foreach ($tool in @($gcc, $objcopy, $size)) {
    if (-not (Test-Path $tool)) {
        throw "Toolchain not found: $tool"
    }
}

if ($Flash -and -not (Test-Path $ProgrammerPath)) {
    throw "STM32CubeProgrammer not found: $ProgrammerPath"
}

New-Item -ItemType Directory -Force -Path 'build' | Out-Null

& $gcc -c -mcpu=cortex-m4 -mthumb -DSTM32F401xE -Wall -Wextra `
    -fdata-sections -ffunction-sections -ffreestanding -std=c99 -O2 -g3 `
    '-MMD' '-MP' '-MF' 'build/main.d' 'src/main.c' '-o' 'build/main.o'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $gcc -x assembler-with-cpp -c -mcpu=cortex-m4 -mthumb -Wall `
    -fdata-sections -ffunction-sections 'startup/startup_stm32f401ceux.s' `
    '-o' 'build/startup_stm32f401ceux.o'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $gcc 'build/main.o' 'build/startup_stm32f401ceux.o' `
    -mcpu=cortex-m4 -mthumb -nostdlib `
    '-Tlinker/STM32F401CETX_FLASH.ld' `
    '-Wl,-Map=build/HelloWorld.map,--cref' `
    '-Wl,--gc-sections' `
    '-Wl,--print-memory-usage' `
    '-Wl,--build-id=none' `
    '-o' 'build/HelloWorld.elf'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $size 'build/HelloWorld.elf'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $objcopy -O ihex 'build/HelloWorld.elf' 'build/HelloWorld.hex'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $objcopy -O binary -S 'build/HelloWorld.elf' 'build/HelloWorld.bin'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Flash) {
    & $ProgrammerPath -c port=SWD freq=4000 mode=UR -w 'build/HelloWorld.bin' 0x08000000 -v -rst
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

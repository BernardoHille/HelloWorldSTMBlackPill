# HelloWorldSTMBlackPill

Projeto minimo bare-metal para STM32 Black Pill com `STM32F401CEU6`.

O projeto faz o LED onboard em `PC13` piscar e inclui:
- `src/main.c`
- `startup/startup_stm32f401ceux.s`
- `linker/STM32F401CETX_FLASH.ld`
- `Makefile`
- `build.ps1` para compilar no Windows e opcionalmente gravar pela ST-LINK

## Requisitos

- GNU Arm Embedded Toolchain
- STM32CubeProgrammer
- ST-LINK conectada na placa

## Como compilar

```powershell
.\build.ps1
```

## Como compilar e gravar

```powershell
.\build.ps1 -Flash
```

O binario gerado fica em `build/HelloWorld.bin`.

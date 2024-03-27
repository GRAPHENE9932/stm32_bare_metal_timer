cmake_minimum_required(VERSION 3.11)

project("stm32_bare_metal_timer" ASM)

set(CPU cortex-m0)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

set(LINKER_SCRIPT "${PROJECT_SOURCE_DIR}/linker_script.ld")

add_compile_options(
    -mcpu=${CPU}
    -std=gnu11
    -Os
    -Wall
    -Wno-main
    -Wundef
    -Werror
    -Wfatal-errors
    --param=min-pagesize=0
    -Wl,--relax,--gc-sections
    -nostdlib
    -T ${LINKER_SCRIPT}
)

add_link_options(
    -nostdlib
    -T ${LINKER_SCRIPT}
)

add_executable(stm32_bare_metal_timer src/main.s src/startup.s src/io_operations.s src/seven_seg_disp.s src/pwm_clock.s)
set_target_properties(stm32_bare_metal_timer PROPERTIES OUTPUT_NAME stm32_bare_metal_timer.elf)

add_custom_target(
    upload
    COMMAND arm-none-eabi-objcopy -O binary stm32_bare_metal_timer.elf firmware.bin
    COMMAND st-flash write firmware.bin 0x08000000
)
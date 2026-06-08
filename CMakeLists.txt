# ESP-IDF v5/v6 component registration for the VL53L0X driver (ST API + C++
# wrapper). The upstream used the pre-v5 register_component()/COMPONENT_SRCS
# syntax, which IDF v5/v6 removed; this is the modern idf_component_register form.
#
# The public header inc/VL53L0X.h includes "driver/i2c.h" (legacy I2C API, still
# shipped by the `driver` component in IDF v6, deprecated-not-removed) and
# "driver/gpio.h" (esp_driver_gpio), so both are PUBLIC requirements.
idf_component_register(
    SRCS
        "api/core/src/vl53l0x_api.c"
        "api/core/src/vl53l0x_api_calibration.c"
        "api/core/src/vl53l0x_api_core.c"
        "api/core/src/vl53l0x_api_ranging.c"
        "api/core/src/vl53l0x_api_strings.c"
        "api/platform/src/vl53l0x_platform.c"
        "api/platform/src/vl53l0x_platform_log.c"
    INCLUDE_DIRS
        "inc"
        "api/core/inc"
        "api/platform/inc"
    REQUIRES driver esp_driver_gpio
)

# Preserve the upstream build flag: USE_I2C_2V8 selects the sensor's 2.8 V I2C
# mode in the ST platform layer.
target_compile_definitions(${COMPONENT_LIB} PRIVATE USE_I2C_2V8=1)

# This is vendored third-party code (ST's VL53L0X API). Don't subject it to the
# consuming project's -Werror; silence its warnings so it builds cleanly under
# strict firmware flags.
target_compile_options(${COMPONENT_LIB} PRIVATE -w)

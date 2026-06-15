#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

if rg -n 'driver/i2c\.h|i2c_cmd_|i2c_driver_install|i2c_param_config|i2c_master_cmd_begin' inc api CMakeLists.txt >/tmp/vl53l0x_legacy_i2c.txt; then
  cat /tmp/vl53l0x_legacy_i2c.txt >&2
  fail 'legacy ESP-IDF I2C API is still used in production sources'
fi

rg -q '#include "driver/i2c_master\.h"' inc/VL53L0X.h \
  || fail 'C++ wrapper does not include driver/i2c_master.h'

rg -q '#include "driver/i2c_master\.h"' api/platform/inc/vl53l0x_platform.h \
  || fail 'platform header does not include driver/i2c_master.h'

rg -q 'i2c_master_bus_handle_t' inc/VL53L0X.h \
  || fail 'C++ wrapper does not expose shared bus handle API'

rg -q 'i2c_master_dev_handle_t[[:space:]]+i2c_dev' api/platform/inc/vl53l0x_platform.h \
  || fail 'platform device does not store an IDF v6 I2C device handle'

rg -q 'i2c_master_transmit_receive' api/platform/src/vl53l0x_platform.c \
  || fail 'platform reads do not use i2c_master_transmit_receive'

rg -q 'i2c_master_transmit' api/platform/src/vl53l0x_platform.c \
  || fail 'platform writes do not use i2c_master_transmit'

rg -q 'esp_driver_i2c' CMakeLists.txt \
  || fail 'component does not depend on esp_driver_i2c'

rg -q 'Shared I2C bus' README.md \
  || fail 'README does not document shared I2C bus usage'

rg -q 'Convenience-owned I2C bus' README.md \
  || fail 'README does not document convenience-owned I2C bus usage'

printf 'PASS: IDF v6 I2C migration checks passed\n'

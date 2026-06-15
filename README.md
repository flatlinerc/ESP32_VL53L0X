# ESP32_VL53L0X

C++ VL53L0X driver as an ESP-IDF component

## Dependency

- [ESP-IDF](https://github.com/espressif/esp-idf)

## Example

```sh
git clone https://github.com/kerikun11/ESP32_VL53L0X.git
cd ESP32_VL53L0X/examples/polling
idf.py build flash monitor
```

or open `examples/polling` directory with [PlatformIO IDE](https://platformio.org/platformio-ide)

## ESP-IDF v6 I2C usage

This component uses the ESP-IDF v6 I2C master bus/device API from
`driver/i2c_master.h`.

### Shared I2C bus

Use this form when the application owns one I2C bus and shares it with multiple
devices.

```cpp
#include "VL53L0X.h"

#include "driver/i2c_master.h"
#include "esp_log.h"

#define I2C_PORT I2C_NUM_0
#define PIN_SDA GPIO_NUM_21
#define PIN_SCL GPIO_NUM_22

extern "C" void app_main() {
  i2c_master_bus_config_t bus_config = {};
  bus_config.clk_source = I2C_CLK_SRC_DEFAULT;
  bus_config.i2c_port = I2C_PORT;
  bus_config.sda_io_num = PIN_SDA;
  bus_config.scl_io_num = PIN_SCL;
  bus_config.glitch_ignore_cnt = 7;
  bus_config.flags.enable_internal_pullup = true;

  i2c_master_bus_handle_t bus = nullptr;
  ESP_ERROR_CHECK(i2c_new_master_bus(&bus_config, &bus));

  VL53L0X range_sensor(bus);
  if (!range_sensor.init()) {
    ESP_LOGE("app_main", "Failed to initialize VL53L0X");
    return;
  }

  // Other I2C devices can be added to the same bus with
  // i2c_master_bus_add_device(bus, &other_device_config, &other_device).
}
```

Multiple VL53L0X sensors need separate XSHUT control or another isolation
method during startup because every sensor powers up at address `0x29`.
Initialize them one at a time, call `setDeviceAddress()` to assign unique
addresses, then keep them on the shared bus.

### Convenience-owned I2C bus

Use this form for simple applications where the VL53L0X wrapper can create and
own the I2C bus.

```cpp
#include "VL53L0X.h"

#include "esp_log.h"

#define I2C_PORT I2C_NUM_0
#define PIN_SDA GPIO_NUM_21
#define PIN_SCL GPIO_NUM_22

extern "C" void app_main() {
  VL53L0X range_sensor(I2C_PORT);
  range_sensor.i2cMasterInit(PIN_SDA, PIN_SCL);

  if (!range_sensor.init()) {
    ESP_LOGE("app_main", "Failed to initialize VL53L0X");
    return;
  }
}
```

## API using

[STMicroelectronics official VL53L0X API](http://www.st.com/content/st_com/en/products/embedded-software/proximity-sensors-software/stsw-img005.html)

- core
- platform

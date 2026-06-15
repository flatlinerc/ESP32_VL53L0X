# IDF v6 I2C Shared Bus Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the VL53L0X library from legacy `driver/i2c.h` command-link usage to the ESP-IDF v6 `driver/i2c_master.h` bus/device API while supporting shared I2C buses.

**Architecture:** The C platform layer stores and uses an `i2c_master_dev_handle_t` for all register transactions. The C++ wrapper supports two ownership modes: callers can pass an existing `i2c_master_bus_handle_t` for shared-bus applications, or call the existing `i2cMasterInit()` convenience method to let the wrapper create its own bus.

**Tech Stack:** ESP-IDF v6 I2C master driver, C platform adapter, C++ wrapper, shell-based static migration checks.

---

### Task 1: Migration Guard

**Files:**
- Create: `tests/check_idf_v6_i2c.sh`

- [x] **Step 1: Write the failing migration check**

Create a shell script that verifies the source no longer includes `driver/i2c.h`, that the new public API exposes `i2c_master_bus_handle_t`, that the platform layer stores `i2c_master_dev_handle_t`, that `CMakeLists.txt` requires `esp_driver_i2c`, and that README documents both shared-bus and convenience usage.

- [x] **Step 2: Run the check to verify it fails**

Run: `./tests/check_idf_v6_i2c.sh`
Expected: FAIL because the current code still uses legacy I2C symbols and README lacks both examples.

### Task 2: IDF v6 I2C API Migration

**Files:**
- Modify: `inc/VL53L0X.h`
- Modify: `api/platform/inc/vl53l0x_platform.h`
- Modify: `api/platform/src/vl53l0x_platform.c`
- Modify: `CMakeLists.txt`

- [x] **Step 1: Replace legacy public includes and device state**

Use `driver/i2c_master.h` in public headers. Store `i2c_master_dev_handle_t` in `VL53L0X_Dev_t`. In the C++ class, store the optional shared bus, owned bus, device handle, address, frequency, and ownership flags.

- [x] **Step 2: Add shared-bus and compatibility initialization paths**

Add a constructor accepting `i2c_master_bus_handle_t`. Keep the existing `i2c_port_t` constructor and `i2cMasterInit()` method, but implement them with `i2c_new_master_bus()` and `i2c_master_bus_add_device()`.

- [x] **Step 3: Replace register transactions**

Implement writes with `i2c_master_transmit()` and reads with `i2c_master_transmit_receive()`. Preserve the existing `VL53L0X_Error` mapping.

- [x] **Step 4: Update component dependencies**

Change the component public dependency from the legacy `driver` component to `esp_driver_i2c` plus the existing GPIO dependency.

### Task 3: Documentation

**Files:**
- Modify: `README.md`

- [x] **Step 1: Document shared-bus usage**

Add an example that creates one `i2c_master_bus_handle_t`, passes it to `VL53L0X`, and leaves room for other devices on the same bus.

- [x] **Step 2: Document compatibility usage**

Add an example showing `VL53L0X vl(I2C_NUM_0); vl.i2cMasterInit(PIN_SDA, PIN_SCL);`.

### Task 4: Verification

**Files:**
- No new files.

- [x] **Step 1: Run static migration check**

Run: `./tests/check_idf_v6_i2c.sh`
Expected: PASS.

- [x] **Step 2: Scan for legacy I2C usage**

Run: `rg -n "driver/i2c.h|i2c_cmd_|i2c_driver_install|i2c_param_config|i2c_master_cmd_begin" inc api CMakeLists.txt README.md`
Expected: no production legacy I2C usage.

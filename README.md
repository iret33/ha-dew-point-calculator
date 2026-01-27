# Dew Point Calculator for Home Assistant

[![GitHub Release](https://img.shields.io/github/v/release/iret33/ha-dew-point-calculator?style=flat-square)](https://github.com/iret33/ha-dew-point-calculator/releases)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/iret33/ha-dew-point-calculator/validate.yml?style=flat-square&label=validate)](https://github.com/iret33/ha-dew-point-calculator/actions/workflows/validate.yml)
[![HACS](https://img.shields.io/badge/HACS-Custom-orange.svg?style=flat-square)](https://github.com/hacs/integration)
[![License](https://img.shields.io/github/license/iret33/ha-dew-point-calculator?style=flat-square)](LICENSE)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024.1.0+-blue?style=flat-square)](https://www.home-assistant.io/)
[![GitHub Stars](https://img.shields.io/github/stars/iret33/ha-dew-point-calculator?style=flat-square)](https://github.com/iret33/ha-dew-point-calculator/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/iret33/ha-dew-point-calculator?style=flat-square)](https://github.com/iret33/ha-dew-point-calculator/issues)
[![Maintenance](https://img.shields.io/maintenance/yes/2026?style=flat-square)](https://github.com/iret33/ha-dew-point-calculator)

A Home Assistant custom integration that calculates dew point from existing temperature and humidity sensors.

## Features

- 🌡️ Calculate dew point from any temperature and humidity sensor
- 🎯 Easy configuration through the UI
- ⚡ Real-time updates when sensor values change
- 📊 Uses the accurate Magnus formula for calculation
- 🔄 Multiple dew point sensors can be created

## Installation

### HACS (Recommended)

1. Open HACS in Home Assistant
2. Go to "Integrations"
3. Click the three dots in the top right corner
4. Select "Custom repositories"
5. Add this repository URL: `https://github.com/iret33/ha-dew-point-calculator`
6. Select category: "Integration"
7. Click "Add"
8. Find "Dew Point Calculator" in the integration list
9. Click "Download"
10. Restart Home Assistant

### Manual Installation

1. Download the `custom_components/dew_point_calculator` folder from this repository
2. Copy it to your Home Assistant's `custom_components` directory
   - If the `custom_components` directory doesn't exist, create it in your config folder
3. Restart Home Assistant

## Configuration

1. Go to **Settings** → **Devices & Services**
2. Click **+ Add Integration**
3. Search for **Dew Point Calculator**
4. Select your temperature sensor
5. Select your humidity sensor
6. Give your dew point sensor a name (optional)
7. Click **Submit**

The dew point sensor will be created and will update automatically whenever the temperature or humidity changes.

## How It Works

The integration uses the Magnus formula to calculate dew point:

```
Td = (b × α) / (a - α)

where:
α = ln(RH/100) + (a × T) / (b + T)
a = 17.27
b = 237.7 °C
T = temperature in °C
RH = relative humidity in %
```

This formula provides accuracy within ±0.4°C for temperatures between -40°C and 50°C.

## Example Use Cases

- **HVAC Control**: Prevent condensation by monitoring dew point
- **Comfort Monitoring**: Track indoor air quality
- **Greenhouse Management**: Optimize growing conditions
- **Mold Prevention**: Alert when conditions favor mold growth
- **Weather Stations**: Complete weather data reporting

## Troubleshooting

**Sensor shows "unavailable"**
- Check that both temperature and humidity sensors are working
- Verify the sensors are providing valid numeric values

**Dew point seems incorrect**
- Ensure your temperature sensor is in Celsius
- Verify humidity sensor reads 0-100%
- Check that sensors are reading from the same location

## Related Projects

### ESPHome Component

If you're using ESPHome devices and want to calculate dew point directly on the ESP device, check out the companion project:

**[ESPHome Dew Point Sensor Component](https://github.com/iret33/esphome-dew-point)** - Calculate dew point directly on your ESP8266/ESP32 devices.

### Which Should You Use?

| Feature | Home Assistant Integration | ESPHome Component |
|---------|---------------------------|-------------------|
| **Calculation Location** | In Home Assistant | On ESP device |
| **Configuration** | UI-based | YAML |
| **Works offline** | Requires HA running | Yes |
| **Sensor sources** | Any HA sensor | ESPHome sensors only |
| **Best for** | Centralized setup, mixed sensors | Edge computing, standalone |

**Choose Home Assistant Integration when:**
- Your sensors aren't ESPHome devices (Zigbee, Z-Wave, WiFi, etc.)
- You prefer UI-based configuration
- You want centralized management of all dew point calculations
- You're using sensors from different protocols/brands

**Choose ESPHome Component when:**
- You want calculations done locally on the device
- You need the dew point even when Home Assistant is down
- You're building a standalone weather station
- You want to reduce Home Assistant load

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:
- Open an issue on [GitHub](https://github.com/iret33/ha-dew-point-calculator/issues)
- Check the [Home Assistant Community Forum](https://community.home-assistant.io/)

## Changelog

### Version 1.0.0
- Initial release
- UI-based configuration
- Real-time dew point calculation
- Support for multiple sensors

---

Made with ❤️ for the Home Assistant community

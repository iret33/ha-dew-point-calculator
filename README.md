# Dew Point Calculator for Home Assistant

[![hacs_badge](https://img.shields.io/badge/HACS-Custom-orange.svg)](https://github.com/custom-components/hacs)
[![GitHub release](https://img.shields.io/github/release/iret33/ha-dew-point-calculator.svg)](https://github.com/iret33/ha-dew-point-calculator/releases)
[![License](https://img.shields.io/github/license/iret33/ha-dew-point-calculator.svg)](LICENSE)

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

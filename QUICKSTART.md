# Quick Start Guide

Get your Dew Point Calculator integration up and running in minutes!

## For Users

### Installation via HACS

1. Open HACS in Home Assistant
2. Go to "Integrations"
3. Click ⋮ (three dots) → "Custom repositories"
4. Add URL: `https://github.com/iret33/ha-dew-point-calculator`
5. Category: "Integration"
6. Click "Download"
7. Restart Home Assistant

### Setup

1. Go to **Settings** → **Devices & Services**
2. Click **+ Add Integration**
3. Search **"Dew Point Calculator"**
4. Select your **temperature sensor** (must be in Celsius)
5. Select your **humidity sensor** (must be in %)
6. Enter a **name** (optional, defaults to "Dew Point")
7. Click **Submit**

Your dew point sensor is ready! It will update automatically.

## For Developers

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/iret33/ha-dew-point-calculator.git
   cd ha-dew-point-calculator
   ```

2. Link to your Home Assistant:
   ```bash
   ln -s "$(pwd)/custom_components/dew_point_calculator" \
         /path/to/homeassistant/config/custom_components/
   ```

3. Restart Home Assistant

### File Structure

```
custom_components/dew_point_calculator/
├── __init__.py          # Integration setup
├── sensor.py            # Dew point sensor logic
├── config_flow.py       # UI configuration
├── const.py             # Constants
├── manifest.json        # Integration metadata
├── strings.json         # UI labels
└── translations/
    └── en.json          # English translations
```

### Key Components

**Magnus Formula** (in `sensor.py`):
```python
a = 17.27
b = 237.7
alpha = ((a * T) / (b + T)) + log(RH / 100)
dew_point = (b * alpha) / (a - alpha)
```

**Config Flow** (in `config_flow.py`):
- Validates sensor existence
- Prevents duplicate configurations
- Creates unique IDs based on sensor combination

**Real-time Updates** (in `sensor.py`):
- Listens to both sensor state changes
- Recalculates on any update
- Handles unavailable states gracefully

### Testing Locally

1. Enable debug logging in `configuration.yaml`:
   ```yaml
   logger:
     default: info
     logs:
       custom_components.dew_point_calculator: debug
   ```

2. Check logs: Settings → System → Logs

3. Test scenarios:
   - Valid sensor values
   - Unavailable sensors
   - Invalid values
   - Multiple configurations

### Making Changes

1. Edit files
2. Restart Home Assistant
3. Test the changes
4. Check logs for errors

### Common Modifications

**Add Fahrenheit support**:
- Modify `sensor.py` to detect temperature unit
- Convert to Celsius before calculation

**Add absolute humidity**:
- Add new calculation in `sensor.py`
- Create additional sensor entity

**Add configuration options**:
- Extend `config_flow.py` schema
- Update `const.py` with new options
- Modify `sensor.py` to use options

## Troubleshooting

**"Sensor not found" error**
- Entity ID doesn't exist
- Sensor not loaded yet (restart HA)

**Dew point shows "unavailable"**
- Source sensors are unavailable
- Invalid sensor values (non-numeric)

**Integration not appearing**
- Check `custom_components` folder structure
- Verify `manifest.json` is valid
- Restart Home Assistant

**No updates after sensor changes**
- Check entity IDs are correct
- Look for errors in logs
- Verify sensors are actually updating

## Resources

- [Home Assistant Developer Docs](https://developers.home-assistant.io/)
- [Config Flow Documentation](https://developers.home-assistant.io/docs/config_entries_config_flow_handler/)
- [Entity Documentation](https://developers.home-assistant.io/docs/core/entity/)
- [HACS Documentation](https://hacs.xyz/docs/publish/integration)

## Quick Commands

```bash
# Check Home Assistant logs
tail -f /config/home-assistant.log | grep dew_point_calculator

# Validate manifest
python -m json.tool manifest.json

# Search for TODO items
grep -r "TODO\|FIXME" custom_components/

# Count lines of code
find custom_components/ -name "*.py" | xargs wc -l
```

Happy coding! 🚀

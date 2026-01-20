# CLAUDE.md - AI Assistant Guide

This document provides comprehensive guidance for AI assistants working on the Dew Point Calculator for Home Assistant integration.

## Repository Overview

**Project**: Dew Point Calculator for Home Assistant
**Type**: Home Assistant Custom Integration
**Purpose**: Calculate dew point from existing temperature and humidity sensors
**Version**: 1.0.0
**License**: MIT
**HACS Compatible**: Yes

This is a Home Assistant custom integration that uses the Magnus formula to calculate dew point temperature from any temperature and humidity sensor pair. The integration provides a UI-based configuration flow and real-time updates.

## Directory Structure

```
ha-dew-point-calculator/
├── .github/
│   └── workflows/
│       └── validate.yml          # CI/CD for HACS and hassfest validation
├── custom_components/
│   └── dew_point_calculator/     # Main integration code
│       ├── __init__.py           # Integration setup and entry management
│       ├── config_flow.py        # UI configuration flow
│       ├── const.py              # Constants and configuration keys
│       ├── manifest.json         # Integration metadata
│       ├── sensor.py             # Dew point sensor implementation
│       ├── strings.json          # UI strings (English)
│       └── translations/
│           └── en.json           # Translation strings
├── CLAUDE.md                     # This file - AI assistant guide
├── CONTRIBUTING.md               # Contribution guidelines
├── hacs.json                     # HACS metadata
├── info.md                       # HACS store description
├── LICENSE                       # MIT license
├── QUICKSTART.md                 # Quick setup guide
├── README.md                     # Main documentation
├── SETUP_GUIDE.md                # Detailed setup instructions
├── WSL_INSTRUCTIONS.md           # WSL development setup
└── wsl_complete_setup.sh         # WSL setup script
```

## Key Files and Their Purpose

### Integration Core Files

#### `custom_components/dew_point_calculator/__init__.py`
- **Purpose**: Entry point for the integration
- **Key Functions**:
  - `async_setup_entry()`: Sets up the integration from a config entry
  - `async_unload_entry()`: Unloads the integration and cleans up
- **Pattern**: Uses Home Assistant's config entry system
- **Platform**: Only supports `Platform.SENSOR`

#### `custom_components/dew_point_calculator/sensor.py`
- **Purpose**: Implements the dew point sensor entity
- **Key Class**: `DewPointSensor(SensorEntity)`
- **Calculation**: Magnus formula implementation
  ```python
  α = ln(RH/100) + (a × T) / (b + T)
  Td = (b × α) / (a - α)
  where a = 17.27, b = 237.7
  ```
- **Features**:
  - Real-time updates via state change tracking
  - Error handling for invalid sensor values
  - Extra state attributes for debugging
  - Proper availability reporting
- **Device Class**: `SensorDeviceClass.TEMPERATURE`
- **State Class**: `SensorStateClass.MEASUREMENT`
- **Unit**: `UnitOfTemperature.CELSIUS`

#### `custom_components/dew_point_calculator/config_flow.py`
- **Purpose**: Provides UI-based configuration
- **Flow Type**: User-initiated flow
- **Validation**:
  - Checks if selected sensors exist
  - Prevents duplicate sensor combinations via unique_id
  - Uses entity selectors with device_class filters
- **Form Fields**:
  - Temperature sensor (required, filtered by device_class="temperature")
  - Humidity sensor (required, filtered by device_class="humidity")
  - Dew point name (optional, defaults to "Dew Point")

#### `custom_components/dew_point_calculator/const.py`
- **Purpose**: Constants and configuration keys
- **Key Constants**:
  - `DOMAIN = "dew_point_calculator"`
  - `CONF_TEMPERATURE_SENSOR`: Key for temperature sensor entity_id
  - `CONF_HUMIDITY_SENSOR`: Key for humidity sensor entity_id
  - `CONF_DEW_POINT_NAME`: Key for custom sensor name
  - `DEFAULT_NAME = "Dew Point"`

#### `custom_components/dew_point_calculator/manifest.json`
- **Purpose**: Integration metadata for Home Assistant
- **Key Fields**:
  - `domain`: Must match DOMAIN constant
  - `version`: Current version (1.0.0)
  - `config_flow`: true (supports UI configuration)
  - `integration_type`: "device"
  - `iot_class`: "calculated" (computed from other sensors)
  - `requirements`: [] (no external Python dependencies)

### Configuration Files

#### `hacs.json`
- **Purpose**: HACS (Home Assistant Community Store) metadata
- **Fields**:
  - `name`: Display name in HACS
  - `render_readme`: true (shows README in HACS)
  - `homeassistant`: "2023.1.0" (minimum HA version)

#### `.github/workflows/validate.yml`
- **Purpose**: CI/CD validation
- **Jobs**:
  - `validate-hacs`: Validates HACS compatibility
  - `validate-hassfest`: Validates Home Assistant standards
- **Triggers**: push, pull_request, schedule (daily), workflow_dispatch

## Code Conventions

### Python Style

1. **Type Hints**: Always use type hints for function parameters and return values
   ```python
   async def async_setup_entry(
       hass: HomeAssistant,
       config_entry: ConfigEntry,
       async_add_entities: AddEntitiesCallback,
   ) -> None:
   ```

2. **Imports**: Follow Home Assistant's import order
   ```python
   from __future__ import annotations  # Always first

   import logging  # Standard library
   import math

   from homeassistant.components.sensor import ...  # Home Assistant core
   from homeassistant.config_entries import ...

   from .const import ...  # Local imports last
   ```

3. **Logging**: Use module-level logger
   ```python
   _LOGGER = logging.getLogger(__name__)
   ```

4. **Async/Await**: Use async functions for I/O operations
   - Prefix async functions with `async_`
   - Use `@callback` decorator for synchronous callbacks

5. **Error Handling**:
   - Catch specific exceptions (ValueError, TypeError, ZeroDivisionError)
   - Log errors with context
   - Set sensor to unavailable on calculation errors

### Home Assistant Patterns

1. **Config Entry System**: Use `ConfigEntry` for all configuration
   - No YAML configuration
   - All settings in `config_entry.data`

2. **Entity Attributes**:
   - Use `_attr_` prefix for class attributes
   - Set `_attr_should_poll = False` for event-driven sensors
   - Implement `extra_state_attributes` for debugging info

3. **State Tracking**:
   - Use `async_track_state_change_event()` for sensor updates
   - Register cleanup with `async_on_remove()`
   - Initialize with current sensor values in `async_added_to_hass()`

4. **Unique IDs**:
   - Use combination of entry_id and sensor type
   - Format: `f"{entry_id}_dew_point"`
   - Allows multiple instances with different sensor pairs

5. **Availability**:
   - Report unavailable when calculation cannot be performed
   - Check for "unknown" and "unavailable" source sensor states

## Development Workflows

### Adding a New Feature

1. **Read Existing Code**: Always read relevant files before making changes
   ```python
   # Read: sensor.py, config_flow.py, const.py
   ```

2. **Update Constants**: Add new configuration keys to `const.py`
   ```python
   CONF_NEW_OPTION = "new_option"
   DEFAULT_NEW_VALUE = "default"
   ```

3. **Update Config Flow**: Add new fields to `config_flow.py`
   ```python
   vol.Optional(CONF_NEW_OPTION, default=DEFAULT_NEW_VALUE): cv.string
   ```

4. **Update Translations**: Add strings to `strings.json` and `translations/en.json`
   ```json
   {
     "config": {
       "step": {
         "user": {
           "data": {
             "new_option": "New Option Label"
           }
         }
       }
     }
   }
   ```

5. **Implement Feature**: Update `sensor.py` or other relevant files

6. **Test Manually**: Test in a Home Assistant instance

### Fixing a Bug

1. **Understand the Issue**: Read the bug report and related code
2. **Locate the Code**: Find the relevant function/class
3. **Reproduce**: Understand the conditions that cause the bug
4. **Fix**: Make minimal changes to fix the issue
5. **Add Error Handling**: Add appropriate try/except blocks if needed
6. **Test**: Verify the fix works and doesn't break existing functionality

### Adding Error Handling

Follow the existing pattern:
```python
try:
    # Calculation or operation
    value = float(state.state)
except (ValueError, TypeError) as ex:
    _LOGGER.warning("Unable to process value: %s", ex)
    return None
```

### Code Review Checklist

Before committing changes:

- [ ] Type hints added to all functions
- [ ] Docstrings added to public functions and classes
- [ ] Error handling for invalid inputs
- [ ] Logging for important operations
- [ ] Constants used instead of magic strings/numbers
- [ ] No security vulnerabilities (command injection, XSS, etc.)
- [ ] Follows Home Assistant development guidelines
- [ ] Translation strings added if UI changes made
- [ ] manifest.json version updated if needed

## Testing Guidelines

### Manual Testing

1. **Installation**: Test both HACS and manual installation
2. **Configuration**: Test the config flow
   - Valid sensor selection
   - Invalid sensor handling
   - Duplicate prevention
3. **Functionality**: Test dew point calculation
   - Normal operation with valid sensors
   - Behavior with unavailable sensors
   - Behavior with invalid sensor values
4. **Updates**: Test real-time updates when sensors change
5. **Multiple Instances**: Test creating multiple dew point sensors

### Test Scenarios

1. **Happy Path**:
   - Temperature: 20°C, Humidity: 60% → Dew Point: ~12.0°C
   - Temperature: 25°C, Humidity: 80% → Dew Point: ~21.3°C

2. **Edge Cases**:
   - Temperature sensor unavailable
   - Humidity sensor unavailable
   - Invalid sensor values (non-numeric)
   - Extreme temperatures (-40°C to 50°C)
   - Extreme humidity (0% to 100%)

3. **Error Cases**:
   - Sensor entity doesn't exist
   - Sensor returns "unknown"
   - Sensor returns "unavailable"
   - Division by zero in calculation

### Validation

The repository includes automated validation:
- **HACS validation**: Ensures HACS compatibility
- **Hassfest validation**: Ensures Home Assistant standards compliance

Run locally (if you have tools installed):
```bash
# HACS validation (requires HACS action)
# Hassfest validation (requires Home Assistant core)
```

## Git Workflow

### Branch Naming

- Feature branches: `claude/feature-name-{session_id}`
- Current branch: `claude/add-claude-documentation-zIdjj`
- **IMPORTANT**: Branch must start with `claude/` and end with matching session ID

### Commit Messages

Follow this format:
```
Brief summary of change (50 chars or less)

More detailed explanation if needed:
- What was changed
- Why it was changed
- Any important details

Fixes #123 (if applicable)
```

Examples:
```
Add error handling for invalid sensor values

- Added try/except blocks in sensor state listener
- Log warnings for invalid numeric values
- Set sensor to unavailable on calculation errors
```

### Commit Process

1. **Review Changes**: Use `git status` and `git diff`
2. **Stage Files**: `git add` relevant files
3. **Commit**: Create commit with descriptive message
4. **Push**: `git push -u origin <branch-name>`

**CRITICAL Git Rules**:
- NEVER run `git commit --amend` unless explicitly requested
- NEVER force push unless explicitly requested
- NEVER push to main/master directly
- Always push to the designated feature branch
- Use retry logic (up to 4 times with exponential backoff) for network errors

### Creating Pull Requests

When ready to create a PR:

1. **Review all commits**: Check `git log` for the branch
2. **Understand full changes**: Review `git diff main...HEAD`
3. **Draft PR summary**: Include all relevant commits, not just the latest
4. **Create PR**: Use `gh pr create` with proper format

Example:
```bash
gh pr create --title "Add comprehensive CLAUDE.md documentation" --body "$(cat <<'EOF'
## Summary
- Created comprehensive CLAUDE.md guide for AI assistants
- Documents codebase structure and conventions
- Includes development workflows and testing guidelines

## Test plan
- [x] Verified all file paths are correct
- [x] Checked code examples match actual implementation
- [x] Reviewed for accuracy against actual codebase
EOF
)"
```

## Home Assistant Integration Specifics

### Integration Type: "device"

This integration creates virtual devices with calculated sensors.

### IoT Class: "calculated"

The integration doesn't communicate with external services; it calculates values from existing sensors.

### Config Flow

The integration uses config_flow for UI-based setup:
- No YAML configuration required
- All configuration through UI
- Validates sensor existence
- Prevents duplicate configurations

### State Management

- **Event-driven**: Uses `async_track_state_change_event()`
- **No polling**: `_attr_should_poll = False`
- **Real-time updates**: Recalculates when either sensor changes

### Sensor Platform

The integration only provides sensors (no switches, binary sensors, etc.).

### Dependencies

- **External dependencies**: None (no PyPI packages required)
- **Home Assistant version**: 2023.1.0+
- **Python version**: 3.11+ (Home Assistant requirement)

## Common Tasks Reference

### Add a New Configuration Option

1. Add constant to `const.py`:
   ```python
   CONF_PRECISION = "precision"
   DEFAULT_PRECISION = 1
   ```

2. Update config flow in `config_flow.py`:
   ```python
   vol.Optional(
       CONF_PRECISION,
       default=DEFAULT_PRECISION
   ): vol.All(vol.Coerce(int), vol.Range(min=0, max=3))
   ```

3. Update translations in `strings.json` and `translations/en.json`:
   ```json
   "precision": "Decimal Precision"
   ```

4. Use in sensor implementation:
   ```python
   self._precision = config.get(CONF_PRECISION, DEFAULT_PRECISION)
   self._attr_native_value = round(dew_point, self._precision)
   ```

### Add a New Sensor Attribute

In `sensor.py`, update `extra_state_attributes`:
```python
@property
def extra_state_attributes(self) -> dict[str, any]:
    """Return additional state attributes."""
    return {
        "temperature_sensor": self._temperature_sensor,
        "humidity_sensor": self._humidity_sensor,
        "temperature_value": self._temperature_value,
        "humidity_value": self._humidity_value,
        "new_attribute": self._new_value,  # Add here
    }
```

### Change Calculation Method

In `sensor.py`, update `_calculate_dew_point()`:
```python
def _calculate_dew_point(self) -> None:
    """Calculate the dew point using the Magnus formula."""
    if self._temperature_value is None or self._humidity_value is None:
        self._attr_native_value = None
        return

    try:
        # Your new calculation here
        dew_point = your_calculation(self._temperature_value, self._humidity_value)
        self._attr_native_value = round(dew_point, 1)
    except (ValueError, ZeroDivisionError) as ex:
        _LOGGER.error("Error calculating dew point: %s", ex)
        self._attr_native_value = None
```

### Update Integration Version

1. Update `manifest.json`:
   ```json
   "version": "1.1.0"
   ```

2. Update `README.md` changelog section

3. Create git tag:
   ```bash
   git tag -a v1.1.0 -m "Version 1.1.0"
   git push origin v1.1.0
   ```

## Troubleshooting Common Issues

### Sensor Shows "Unavailable"

Check:
1. Both source sensors exist and are available
2. Source sensors provide numeric values
3. Calculation doesn't result in error (check logs)
4. Sensor state tracking is registered properly

### Configuration Flow Doesn't Show Sensors

Check:
1. Sensors exist in Home Assistant
2. Sensors have correct device_class set
3. Entity selector configuration in config_flow.py

### Values Don't Update

Check:
1. State change listener is registered (`async_track_state_change_event`)
2. Listener is tracking correct entity_ids
3. Callback doesn't have exceptions (check logs)

### Integration Won't Load

Check:
1. manifest.json is valid JSON
2. Domain matches DOMAIN constant
3. All required manifest fields are present
4. No syntax errors in Python files

## Security Considerations

### Input Validation

- Always validate sensor entity_ids exist
- Check sensor state values are numeric
- Handle "unknown" and "unavailable" states
- Prevent division by zero in calculations

### No External Dependencies

- No network calls
- No file system access beyond configuration
- No external API dependencies
- All calculations local

### Safe Defaults

- Use default values for optional configuration
- Fail safe by setting sensor unavailable
- Log errors but don't crash

## Resources

### Official Documentation

- [Home Assistant Developer Docs](https://developers.home-assistant.io/)
- [Config Entry Flow](https://developers.home-assistant.io/docs/config_entries_config_flow_handler/)
- [Entity Integration](https://developers.home-assistant.io/docs/core/entity/)
- [Sensor Platform](https://developers.home-assistant.io/docs/core/entity/sensor/)

### Project Links

- **Repository**: https://github.com/iret33/ha-dew-point-calculator
- **Issues**: https://github.com/iret33/ha-dew-point-calculator/issues
- **HACS**: Custom repository

### Related Files

- `README.md`: User-facing documentation
- `CONTRIBUTING.md`: Contribution guidelines
- `SETUP_GUIDE.md`: Detailed setup instructions
- `QUICKSTART.md`: Quick setup guide

## Quick Reference

### File Locations

```
Main code: custom_components/dew_point_calculator/
├── __init__.py          # Integration setup
├── config_flow.py       # UI configuration
├── const.py             # Constants
├── sensor.py            # Sensor implementation
└── manifest.json        # Metadata
```

### Key Functions

```python
# Integration setup
async_setup_entry(hass, entry) -> bool

# Sensor creation
async_setup_entry(hass, config_entry, async_add_entities) -> None

# Dew point calculation
_calculate_dew_point() -> None

# Config flow
async_step_user(user_input) -> FlowResult
```

### Key Patterns

```python
# State tracking
async_track_state_change_event(hass, entity_ids, callback)

# Availability
@property
def available(self) -> bool:
    return self._attr_native_value is not None

# Error handling
try:
    value = float(state.state)
except (ValueError, TypeError) as ex:
    _LOGGER.warning("Error: %s", ex)
```

---

## Notes for AI Assistants

When working on this codebase:

1. **Always read files before modifying** - Never guess at implementation details
2. **Use the Task tool for exploration** - For open-ended searches about code structure
3. **Follow Home Assistant patterns** - This is a Home Assistant integration, follow their conventions
4. **Test thoroughly** - Consider edge cases and error conditions
5. **Update documentation** - Keep README and other docs in sync with code changes
6. **Keep it simple** - Don't over-engineer solutions
7. **Security first** - Validate inputs, handle errors gracefully
8. **Version carefully** - Update manifest.json version when making changes
9. **Commit clean code** - Follow the git workflow and commit message guidelines
10. **Ask when unclear** - Use AskUserQuestion tool for clarification

This integration is production code used by real Home Assistant users. Changes should be carefully considered and thoroughly tested.

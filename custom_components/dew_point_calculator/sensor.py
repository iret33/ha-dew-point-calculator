"""Dew Point Calculator sensor platform."""
from __future__ import annotations

import logging
import math
from typing import Any

from homeassistant.components.sensor import (
    SensorDeviceClass,
    SensorEntity,
    SensorStateClass,
)
from homeassistant.config_entries import ConfigEntry
from homeassistant.const import UnitOfTemperature
from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers.entity_platform import AddEntitiesCallback
from homeassistant.helpers.event import async_track_state_change_event

from .const import (
    CONF_TEMPERATURE_SENSOR,
    CONF_HUMIDITY_SENSOR,
    CONF_DEW_POINT_NAME,
    DEFAULT_NAME,
    DOMAIN,
)

_LOGGER = logging.getLogger(__name__)


async def async_setup_entry(
    hass: HomeAssistant,
    config_entry: ConfigEntry,
    async_add_entities: AddEntitiesCallback,
) -> None:
    """Set up the Dew Point Calculator sensor."""
    config = config_entry.data
    
    temperature_sensor = config[CONF_TEMPERATURE_SENSOR]
    humidity_sensor = config[CONF_HUMIDITY_SENSOR]
    name = config.get(CONF_DEW_POINT_NAME, DEFAULT_NAME)

    async_add_entities(
        [DewPointSensor(hass, temperature_sensor, humidity_sensor, name, config_entry.entry_id)],
        True,
    )


class DewPointSensor(SensorEntity):
    """Representation of a Dew Point Sensor."""

    _attr_device_class = SensorDeviceClass.TEMPERATURE
    _attr_state_class = SensorStateClass.MEASUREMENT
    _attr_native_unit_of_measurement = UnitOfTemperature.CELSIUS
    _attr_should_poll = False

    def __init__(
        self,
        hass: HomeAssistant,
        temperature_sensor: str,
        humidity_sensor: str,
        name: str,
        entry_id: str,
    ) -> None:
        """Initialize the sensor."""
        self.hass = hass
        self._temperature_sensor = temperature_sensor
        self._humidity_sensor = humidity_sensor
        self._attr_name = name
        self._attr_unique_id = f"{entry_id}_dew_point"
        self._attr_native_value = None
        self._temperature_value = None
        self._humidity_value = None

    async def async_added_to_hass(self) -> None:
        """Register callbacks when entity is added."""
        
        @callback
        def sensor_state_listener(event):
            """Handle sensor state changes."""
            entity_id = event.data.get("entity_id")
            new_state = event.data.get("new_state")
            
            if new_state is None or new_state.state in ("unknown", "unavailable"):
                return

            try:
                if entity_id == self._temperature_sensor:
                    self._temperature_value = float(new_state.state)
                elif entity_id == self._humidity_sensor:
                    self._humidity_value = float(new_state.state)
                
                self._calculate_dew_point()
                self.async_write_ha_state()
            except (ValueError, TypeError) as ex:
                _LOGGER.warning(
                    "Unable to update sensor %s: %s", self.entity_id, ex
                )

        # Track both temperature and humidity sensor changes
        self.async_on_remove(
            async_track_state_change_event(
                self.hass,
                [self._temperature_sensor, self._humidity_sensor],
                sensor_state_listener,
            )
        )

        # Initialize with current values
        temp_state = self.hass.states.get(self._temperature_sensor)
        humidity_state = self.hass.states.get(self._humidity_sensor)

        if temp_state and temp_state.state not in ("unknown", "unavailable"):
            try:
                self._temperature_value = float(temp_state.state)
            except (ValueError, TypeError):
                pass

        if humidity_state and humidity_state.state not in ("unknown", "unavailable"):
            try:
                self._humidity_value = float(humidity_state.state)
            except (ValueError, TypeError):
                pass

        self._calculate_dew_point()

    def _calculate_dew_point(self) -> None:
        """Calculate the dew point using the Magnus formula."""
        if self._temperature_value is None or self._humidity_value is None:
            self._attr_native_value = None
            return

        try:
            # Magnus formula constants
            a = 17.27
            b = 237.7

            # Calculate alpha
            alpha = ((a * self._temperature_value) / (b + self._temperature_value)) + math.log(self._humidity_value / 100.0)

            # Calculate dew point
            dew_point = (b * alpha) / (a - alpha)

            # Round to 1 decimal place
            self._attr_native_value = round(dew_point, 1)

        except (ValueError, ZeroDivisionError) as ex:
            _LOGGER.error("Error calculating dew point: %s", ex)
            self._attr_native_value = None

    @property
    def extra_state_attributes(self) -> dict[str, Any]:
        """Return additional state attributes."""
        return {
            "temperature_sensor": self._temperature_sensor,
            "humidity_sensor": self._humidity_sensor,
            "temperature_value": self._temperature_value,
            "humidity_value": self._humidity_value,
        }

    @property
    def available(self) -> bool:
        """Return if entity is available."""
        return self._attr_native_value is not None

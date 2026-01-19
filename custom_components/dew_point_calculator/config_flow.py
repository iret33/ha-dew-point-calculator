"""Config flow for Dew Point Calculator integration."""
from __future__ import annotations

import logging
from typing import Any

import voluptuous as vol

from homeassistant import config_entries
from homeassistant.const import CONF_NAME
from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers import selector
import homeassistant.helpers.config_validation as cv

from .const import (
    CONF_TEMPERATURE_SENSOR,
    CONF_HUMIDITY_SENSOR,
    CONF_DEW_POINT_NAME,
    DEFAULT_NAME,
    DOMAIN,
)

_LOGGER = logging.getLogger(__name__)


class DewPointCalculatorConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    """Handle a config flow for Dew Point Calculator."""

    VERSION = 1

    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> config_entries.FlowResult:
        """Handle the initial step."""
        errors: dict[str, str] = {}

        if user_input is not None:
            # Validate that the selected sensors exist
            temp_sensor = user_input[CONF_TEMPERATURE_SENSOR]
            humidity_sensor = user_input[CONF_HUMIDITY_SENSOR]

            # Check if sensors exist
            if not self.hass.states.get(temp_sensor):
                errors[CONF_TEMPERATURE_SENSOR] = "sensor_not_found"
            if not self.hass.states.get(humidity_sensor):
                errors[CONF_HUMIDITY_SENSOR] = "sensor_not_found"

            if not errors:
                # Create a unique ID based on the sensors
                await self.async_set_unique_id(
                    f"{temp_sensor}_{humidity_sensor}"
                )
                self._abort_if_unique_id_configured()

                return self.async_create_entry(
                    title=user_input.get(CONF_DEW_POINT_NAME, DEFAULT_NAME),
                    data=user_input,
                )

        # Build the schema for the form
        data_schema = vol.Schema(
            {
                vol.Required(
                    CONF_TEMPERATURE_SENSOR,
                    default=user_input.get(CONF_TEMPERATURE_SENSOR) if user_input else None
                ): selector.EntitySelector(
                    selector.EntitySelectorConfig(
                        domain="sensor",
                        device_class="temperature",
                    )
                ),
                vol.Required(
                    CONF_HUMIDITY_SENSOR,
                    default=user_input.get(CONF_HUMIDITY_SENSOR) if user_input else None
                ): selector.EntitySelector(
                    selector.EntitySelectorConfig(
                        domain="sensor",
                        device_class="humidity",
                    )
                ),
                vol.Optional(
                    CONF_DEW_POINT_NAME,
                    default=user_input.get(CONF_DEW_POINT_NAME, DEFAULT_NAME) if user_input else DEFAULT_NAME
                ): cv.string,
            }
        )

        return self.async_show_form(
            step_id="user",
            data_schema=data_schema,
            errors=errors,
        )

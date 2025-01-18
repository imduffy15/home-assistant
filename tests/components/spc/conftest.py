"""Tests for Vanderbilt SPC component."""

from collections.abc import Generator
from unittest.mock import AsyncMock, patch

import pyspcwebgw
import pytest


@pytest.fixture
def mock_clients() -> Generator[tuple[AsyncMock, AsyncMock]]:
    """Mock the SPC client."""
    with (
        patch("homeassistant.components.spc.SpcWebGateway", autospec=True) as init_mock,
        patch(
            "homeassistant.components.spc.config_flow.SpcWebGateway", autospec=True
        ) as config_flow_mock,
    ):
        # Configure both mocks identically
        for mock_client in (init_mock, config_flow_mock):
            client = mock_client.return_value
            client.async_load_parameters.return_value = True
            mock_area = AsyncMock(spec=pyspcwebgw.area.Area)
            mock_area.id = "1"
            mock_area.mode = pyspcwebgw.const.AreaMode.FULL_SET
            mock_area.last_changed_by = "Sven"
            mock_area.name = "House"
            mock_area.verified_alarm = False
            client.info = {"sn": "111111", "type": "SPC4000", "version": "3.14.1"}
            client.ethernet = {"ip_address": "127.0.0.1"}
            client.areas = {"1": mock_area}

        yield (init_mock, config_flow_mock)

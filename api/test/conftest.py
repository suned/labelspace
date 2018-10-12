import pytest
import os
import json

from test.mock_dependencies import MockDependencies


@pytest.fixture
def event_reader():
    def read(event_name):
        file_path = os.path.abspath(__file__)
        path, _ = os.path.split(file_path)
        events_path = os.path.join(path, 'events', event_name)
        with open(events_path) as f:
            return json.load(f)
    yield read


@pytest.fixture
def mock_dependencies():
    yield MockDependencies()

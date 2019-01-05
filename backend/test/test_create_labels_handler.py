import json
from unittest.mock import call

import pytest
from faunadb import query as q

from backend.faunadb_data_source_handler import handle


def test_handler_creates_label(event_reader, mock_dependencies):
    event = event_reader('create_labels_event.json')
    label = event['arguments']['label']

    def test_labels_are_created():
        database_client = mock_dependencies.annotation_database(None).client
        database_client.query.assert_has_calls(
            [call(q.create(q.class_("DocumentLabel"), {'data': {'label': label}}))]
        )

        result = handle(event, {}, dependencies=mock_dependencies)
        test_labels_are_created()
        assert json.loads(result) == {
            'ref': '1234',
            'label': label
        }


def test_handler_fails_on_unrecognized_label(event_reader, mock_dependencies):
    event = event_reader('create_labels_event.json')
    event['arguments']['labelType'] = 'banana'
    with pytest.raises(Exception):
        handle(event, {}, dependencies=mock_dependencies)

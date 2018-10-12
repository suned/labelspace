import json
from unittest.mock import call
from faunadb import query as q

from api.create_labels_handler import handle


def test_handler_creates_label(event_reader, mock_dependencies):
    event = event_reader('create_labels_event.json')
    label = json.loads(event['body'])['label']

    def test_labels_are_created():
        database_client = mock_dependencies.annotation_database(None).client
        database_client.query.assert_has_calls(
            [call(q.create(q.class_("DocumentLabel"), {'data': {'label': label}}))]
        )

        response = handle(event, {}, dependencies=mock_dependencies)
        test_labels_are_created()
        assert response['statusCode'] == 200
        assert json.loads(response['body']) == {
            'ref': '1234',
            'label': label
        }


def test_handler_gives_404_on_unrecognized_label(event_reader, mock_dependencies):
    event = event_reader('create_labels_event.json')
    event['pathParameters']['labelType'] = 'banana'

    response = handle(event, {}, dependencies=mock_dependencies)
    assert response['statusCode'] == 404
    assert response['body'] == 'unrecognized label type: banana'


def test_handler_gives_400_on_malformed_request_body(event_reader, mock_dependencies):
    event = event_reader('create_labels_event.json')
    event['body'] = json.dumps({'someProperty': 'all wrong'})
    response = handle(event, {}, dependencies=mock_dependencies)
    assert response['statusCode'] == 400
    assert response['body'] == 'Could not find "label" in request body'

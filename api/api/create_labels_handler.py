import json
from typing import Union

from api.api_event_getters import get_organization_id
from api.dependencies import AWSDependencies
from lib.annotation_database import DocumentLabel, SpanLabel, \
    RelationLabel


def handle(event: dict,
           _,
           dependencies=AWSDependencies()):
    return CreateLabelsHandler(event, dependencies).handle()


class CreateLabelsHandler:
    def __init__(self, event, dependencies):
        organization_id = get_organization_id(event)
        organization = dependencies.database.get_organization(organization_id)
        self.annotation_database = dependencies.annotation_database(organization)
        self.event = event

    def is_recognized_label_type(self):
        return self.get_label_type() in ('document', 'span', 'relation')

    def create_label(self) -> Union[DocumentLabel, SpanLabel, RelationLabel]:
        label_type = self.get_label_type()
        label_value = self.get_label_value()
        if label_type == 'document':
            label = DocumentLabel(label=label_value)
        elif label_type == 'span':
            label = SpanLabel(label=label_value)
        else:
            label = RelationLabel(label=label_value)
        return self.annotation_database.create_label(label)

    def get_label_type(self) -> str:
        return self.event['pathParameters']['labelType']

    def get_label_value(self):
        body = self.event['body']
        return json.loads(body)['label']

    def handle(self):
        if not self.is_recognized_label_type():
            return {
                'statusCode': 404,
                'body': f'unrecognized label type: {self.get_label_type()}'
            }
        if not self.has_label_value():
            return {
                'statusCode': 400,
                'body': f'Could not find "label" in request body'
            }
        label = self.create_label()
        return {
            'statusCode': 200,
            'body': label.to_json()
        }

    def has_label_value(self):
        try:
            self.get_label_value()
        except KeyError:
            return False
        return True


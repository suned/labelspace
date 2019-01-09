import logging
from pprint import pformat

from backend.create_labels_handler import CreateLabelHandler
from backend.dependencies import AWSDependencies
from backend.get_documents_handler import GetDocumentsHandler
from backend.get_labels_handler import GetLabelsHandler
from backend.get_team_handler import GetTeamHandler

log = logging.getLogger('labelspace.faunadb_data_source_handler')


def handle(event: dict,
           _,
           dependencies=AWSDependencies()):
    log.info(f'invoked with event\n: {pformat(event)}')
    if event['field'] == 'createLabel':
        return CreateLabelHandler(event, dependencies).handle()
    if event['field'] == 'getTeam':
        return GetTeamHandler(event, dependencies).handle()
    if event['field'] == 'getLabels':
        return GetLabelsHandler(event, dependencies).handle()
    if event['field'] == 'getDocuments':
        return GetDocumentsHandler(event, dependencies).handle()
    raise Exception(f'Unknown field: {event["field"]}')

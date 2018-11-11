import logging
from pprint import pformat

from backend.create_labels_handler import CreateLabelHandler
from backend.dependencies import AWSDependencies

log = logging.getLogger('labelspace.data_source_handler')


def handle(event: dict,
           _,
           dependencies=AWSDependencies()):
    log.info(f'invoked with event\n: {pformat(event)}')
    if event['field'] == 'createLabel':
        return CreateLabelHandler(event, dependencies).handle()
    raise Exception(f'Unknown field: {event["field"]}')

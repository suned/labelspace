import logging

from backend.dependencies import AWSDependencies
from backend.get_document_link_handler import GetDocumentLinkHandler
from backend.get_s3_upload_post_handler import GetS3UploadPostHandler

log = logging.getLogger('labelspace.s3_data_source_handler')


def handle(event: dict,
           _,
           dependencies=AWSDependencies()):
    log.info(f'invoked with event {event}')
    field = event['field']
    if field == 'getS3UploadPost':
        return GetS3UploadPostHandler(event, dependencies).handle()
    if field == 'getDocumentLink':
        return GetDocumentLinkHandler(event, dependencies).handle()
    raise Exception(f'Unrecognized field {field}')


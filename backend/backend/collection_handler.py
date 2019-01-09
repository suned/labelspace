import os
import logging

from backend.dependencies import AWSDependencies
from backend.handler import Handler

log = logging.getLogger('labelspace.collection_handler')


class CollectionHandler(Handler):
    def handle(self):
        for record in self.event['Records']:
            key = record['s3']['object']['key']
            org_id, file_name = os.path.split(key)
            doc_id, _ = os.path.splitext(file_name)
            org = self.dependencies.database.get_organization(org_id)
            doc = self.dependencies.annotation_database(org).get_document(doc_id)
            doc = doc.clone(converted=True)
            # todo do this through appsync to let client know
            # todo that doc is ready
            log.info(f'updating document {doc}')
            self.dependencies.annotation_database(org).replace_document(doc)
            upload_key = f'{org_id}/{doc.original_name}'
            log.info(f'deleting old upload_key {upload_key}')
            self.dependencies.upload_bucket.Object(upload_key).delete()


def handle(event: dict, _, dependencies=AWSDependencies()):
    log.info(f'received event {event}')
    return CollectionHandler(event, dependencies).handle()

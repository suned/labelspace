import logging
import os
import urllib.parse

import cloudconvert
from lib.annotation_database import Document

from backend.dependencies import AWSDependencies
from backend.handler import Handler

log = logging.getLogger('labelspace.upload_handler')


def handle(event: dict, _, dependencies=AWSDependencies()):
    log.info(f'received event {event}')
    return UploadHandler(event, dependencies).handle()


class UploadHandler(Handler):
    def handle(self):
        secret = self.dependencies.get_secret("CLOUDCONVERT_API_KEY")
        api = cloudconvert.Api(secret)
        for record in self.event['Records']:
            key: str = record['s3']['object']['key']
            # remove percent encoding that's apparently
            # applied somewhere in the lambda pipeline
            key = urllib.parse.unquote(key)
            key = urllib.parse.unquote_plus(key)
            log.info(f'handling {key}')
            _, ext = os.path.splitext(key)
            ext = ext.replace('.', '')
            organization_id, *rest = os.path.split(key)
            original_name = os.path.join(*rest)
            organization = self.dependencies.database.get_organization(
                organization_id
            )
            document = self.dependencies.annotation_database(
                organization
            ).create_document(
                Document(original_name, converted=False)
            )
            collection_key = f'{organization_id}/{document.ref.id()}.html'
            log.info(f'converting and saving to {collection_key}')
            convert_config = {
                'inputformat': ext,
                'outputformat': 'html',
                'input': {
                    's3': {
                        "accesskeyid": os.environ['AWS_ACCESS_KEY_ID'],
                        "secretaccesskey": os.environ['AWS_SECRET_ACCESS_KEY'],
                        "sessiontoken": os.environ['AWS_SESSION_TOKEN'],
                        "bucket": self.dependencies.upload_bucket.name
                    }
                },
                'file': key,
                "output": {
                    "s3": {
                        "accesskeyid": os.environ['AWS_ACCESS_KEY_ID'],
                        "secretaccesskey": os.environ['AWS_SECRET_ACCESS_KEY'],
                        "sessiontoken": os.environ['AWS_SESSION_TOKEN'],
                        "bucket": self.dependencies.collection_bucket.name,
                        "path": collection_key
                    }
                }
            }
            api.convert(convert_config)

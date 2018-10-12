import io

from api.database import Organization
from lib.immutable import Immutable


class StorageManager(Immutable):
    def __init__(self, organization: Organization, upload_bucket, collection_bucket):
        self.organization = organization
        self.upload_bucket = upload_bucket
        self.collection_bucket = collection_bucket

    def _create_organization_folder(self, bucket):
        bucket.put_object(Key=self._path(''), Body=b'')

    def create_upload_folder(self):
        self._create_organization_folder(self.upload_bucket)

    def _path(self, name):
        return f'{self.organization.ref.id()}/{name}'

    def create_collection_folder(self):
        self._create_organization_folder(self.collection_bucket)

    def add_to_collection(self, document_id, html_bytes, txt_bytes):
        html_name = f'{document_id}.html'
        txt_name = f'{document_id}.txt'
        html_path = self._path(html_name)
        txt_path = self._path(txt_name)
        self.collection_bucket.put_object(html_path, html_bytes)
        self.collection_bucket.put_object(txt_path, txt_bytes)

    def read_from_upload(self, name) -> bytes:
        file = io.BytesIO()
        file_path = self._path(name)
        self.upload_bucket.download_fileobj(file_path, file)
        return file.read()

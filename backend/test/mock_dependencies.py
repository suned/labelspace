from unittest.mock import MagicMock, create_autospec

from faunadb.client import FaunaClient

from backend.database import Database, Organization
from backend.dependencies import Dependencies
from lib.annotation_database import AnnotationDatabase
from lib.fauna_database import Secret


class MockDependencies(Dependencies):
    def annotation_database(self, organization: Organization):
        return self._annotation_database

    @property
    def upload_bucket(self):
        return self._upload_bucket

    @property
    def collection_bucket(self):
        return self._collection_bucket

    @property
    def cognito_client(self):
        return self._cognito_client

    @property
    def database(self):
        return self._database

    def __init__(self):
        self._upload_bucket = MagicMock()
        self._collection_bucket = MagicMock()

        mock_database_client = create_autospec(FaunaClient, instance=True)
        mocked_database = Database(
            client_factory=lambda _: mock_database_client,
            secret=Secret('test-secret')
        )
        self._database = mocked_database

        mock_annotation_database_client = create_autospec(FaunaClient, instance=True)
        mocked_annotation_database = AnnotationDatabase(
            client_factory=lambda _: mock_annotation_database_client,
            secret=Secret('test-secret')
        )
        self._annotation_database = mocked_annotation_database

        self._cognito_client = MagicMock()

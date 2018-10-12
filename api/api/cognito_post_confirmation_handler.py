from typing import Optional

from api.dependencies import AWSDependencies
from lib.annotation_database import AnnotationDatabase
from api.storage_manager import StorageManager
from api.database import Database, Organization
from lib.immutable import Immutable


def handle(event,
           _,
           dependencies=AWSDependencies()
           ):
    PostConfirmationHandler(
        database=dependencies.database,
        upload_bucket=dependencies.upload_bucket,
        collection_bucket=dependencies.collection_bucket,
        cognito_client=dependencies.cognito_client,
        event=event
    ).handle()


class PostConfirmationHandler(Immutable):
    def __init__(self,
                 database: Database,
                 upload_bucket,
                 collection_bucket,
                 cognito_client,
                 event):
        self.database = database
        self.event = event
        self.cognito_client = cognito_client

        if self.organization_exists():
            self.organization = self.get_organization()
        else:
            self.organization = self.add_organization()

        self.storage_manager = StorageManager(
            organization=self.organization,
            upload_bucket=upload_bucket,
            collection_bucket=collection_bucket
        )

    def organization_exists(self):
        organization_id = self.get_organization_id()
        # TODO: necessary to check if database, buckets,
        # TODO: roles etc set up correctly?
        return organization_id is not None

    def get_organization_id(self) -> Optional[str]:
        organization_id = self.event['request']['userAttributes'].get(
            'custom:organizationId', None)
        if organization_id == '':
            return None
        return organization_id

    def get_organization(self):
        org_id = self.get_organization_id()
        return self.database.get_organization(org_id)

    def add_organization(self):
        return self.database.create_organization(Organization())

    def handle(self):
        if self.organization_exists():
            return self.add_user_to_organization()
        return self.create_organization()

    def add_user_to_organization(self):
        return self.event

    def update_user_attributes(self):
        self.cognito_client.admin_update_user_attributes(
            UserPoolId=self.event['userPoolId'],
            Username=self.event['userName'],
            UserAttributes=[
                {
                    'Name': 'custom:organizationId',
                    'Value': self.organization.ref.id()
                }
            ]
        )

    def create_organization(self):
        self.create_folders()
        annotation_database_secret = self.create_annotation_database()
        self.update_organization(annotation_database_secret)
        self.update_user_attributes()
        return self.event

    def create_folders(self):
        self.storage_manager.create_upload_folder()
        self.storage_manager.create_collection_folder()

    def create_annotation_database(self) -> str:
        name = f'{self.organization.ref.id()}-annotations'
        secret = self.database.create_database(
            name=name,
            database=AnnotationDatabase,
            key_type='server'
        )
        return secret

    def update_organization(self, annotation_database_secret: str) -> Organization:
        organization = self.organization.clone(secret=annotation_database_secret)
        return self.database.update_organization(organization)

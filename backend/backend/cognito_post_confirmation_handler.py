from typing import Optional
import logging

from backend.dependencies import AWSDependencies
from lib.annotation_database import AnnotationDatabase
from backend.storage_manager import StorageManager
from backend.database import Database, Organization, User
from lib.immutable import Immutable

log = logging.getLogger('labelspace.cognito_post_confirmation_handler')


def handle(event,
           _,
           dependencies=AWSDependencies()
           ):
    log.info(f'handling event {event}')
    return PostConfirmationHandler(
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
        self.organization = self.add_organization()
        self.storage_manager = StorageManager(
            organization=self.organization,
            upload_bucket=upload_bucket,
            collection_bucket=collection_bucket
        )

    def get_organization_id(self) -> Optional[str]:
        organization_id = self.event['request']['userAttributes'].get(
            'custom:organizationId', None)
        if organization_id == '':
            return None
        return organization_id

    def get_organization_name(self) -> str:
        return self.event['request']['userAttributes']['custom:organization']

    def get_organization(self):
        org_id = self.get_organization_id()
        return self.database.get_organization(org_id)

    def add_organization(self):
        organization_name = self.get_organization_name()
        organization = Organization(organization_name=organization_name)
        organization = self.database.create_organization(organization)
        log.info(f'Created organization with ref: {organization.ref}')
        return organization

    def handle(self):
        return self.create_organization()

    def add_user_to_organization(self):
        return self.event

    def create_organization(self):
        self.create_folders()
        annotation_database_secret = self.create_annotation_database()
        self.update_organization(annotation_database_secret)
        self.create_user()
        return self.event

    def create_folders(self):
        self.storage_manager.create_upload_folder()
        self.storage_manager.create_collection_folder()

    def create_annotation_database(self) -> str:
        name = f'{self.organization.ref.id()}-annotations'
        log.info(f'creating annotation database {name}')
        secret = self.database.create_database(
            name=name,
            database=AnnotationDatabase,
            key_type='server'
        )
        return secret

    def update_organization(self, annotation_database_secret: str) -> Organization:
        organization = self.organization.clone(secret=annotation_database_secret)
        return self.database.update_organization(organization)

    def get_sub(self):
        return self.event['request']['userAttributes']['sub']

    def get_email(self):
        return self.event['request']['userAttributes']['email']

    def create_user(self):
        user = User(
            sub=self.get_sub(),
            email=self.get_email(),
            organization=self.organization.ref
        )
        self.database.create_user(user)

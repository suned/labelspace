import os

import boto3

from api.database import Database, Organization
from lib.annotation_database import AnnotationDatabase
from lib.immutable import Immutable


class Dependencies(Immutable):
    @property
    def upload_bucket(self):
        raise NotImplementedError()

    @property
    def collection_bucket(self):
        raise NotImplementedError()

    @property
    def cognito_client(self):
        raise NotImplementedError()

    @property
    def database(self) -> Database:
        raise NotImplementedError()

    def annotation_database(self, organization: Organization):
        raise NotImplementedError()


class AWSDependencies(Dependencies):

    def annotation_database(self, organization: Organization):
        return AnnotationDatabase(secret=organization.secret)

    @property
    def upload_bucket(self):
        s3_client = boto3.resource(
            's3',
            region_name=os.environ['AWS_REGION']
        )
        return s3_client.Bucket(os.environ['UPLOAD_BUCKET'])

    @property
    def collection_bucket(self):
        s3_client = boto3.resource(
            's3',
            region_name=os.environ['AWS_REGION']
        )
        return s3_client.Bucket(os.environ['COLLECTION_BUCKET'])

    @property
    def cognito_client(self):
        return boto3.client(
            'cognito-idp',
            region_name=os.environ['AWS_REGION']
        )

    @property
    def database(self):
        return Database(secret=os.environ['DATABASE_SECRET'])

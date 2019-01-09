import base64
import json
import os

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

from backend.database import Database, Organization
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

    def annotation_database(self, organization: Organization) -> AnnotationDatabase:
        raise NotImplementedError()

    @property
    def s3_client(self):
        raise NotImplementedError()

    def get_secret(self, secret_name: str) -> str:
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

    def get_secret(self, secret_name: str):
        region_name = "eu-west-1"

        # Create a Secrets Manager client
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name
        )

        # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
        # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        # We rethrow the exception by default.

        try:
            get_secret_value_response = client.get_secret_value(
                SecretId=secret_name
            )
        except ClientError as e:
            if e.response['Error']['Code'] == 'DecryptionFailureException':
                # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
                # Deal with the exception here, and/or rethrow at your discretion.
                raise e
            elif e.response['Error'][
                'Code'] == 'InternalServiceErrorException':
                # An error occurred on the server side.
                # Deal with the exception here, and/or rethrow at your discretion.
                raise e
            elif e.response['Error']['Code'] == 'InvalidParameterException':
                # You provided an invalid value for a parameter.
                # Deal with the exception here, and/or rethrow at your discretion.
                raise e
            elif e.response['Error']['Code'] == 'InvalidRequestException':
                # You provided a parameter value that is not valid for the current state of the resource.
                # Deal with the exception here, and/or rethrow at your discretion.
                raise e
            elif e.response['Error']['Code'] == 'ResourceNotFoundException':
                # We can't find the resource that you asked for.
                # Deal with the exception here, and/or rethrow at your discretion.
                raise e
        else:
            # Decrypts secret using the associated KMS CMK.
            # Depending on whether the secret is a string or binary, one of these fields will be populated.
            if 'SecretString' in get_secret_value_response:
                secret = get_secret_value_response['SecretString']
                return json.loads(secret)[secret_name]
            else:
                return base64.b64decode(
                    get_secret_value_response['SecretBinary']
                )

    @property
    def database(self):
        return Database(secret=os.environ['DATABASE_SECRET'])

    @property
    def s3_client(self):
        return boto3.client(
            's3',
            region_name=os.environ['AWS_REGION'],
            config=Config(signature_version='s3v4')
        )

    @property
    def s3_client_sigv2(self):
        return boto3.client(
            's3',
            region_name=os.environ['AWS_REGION']
        )

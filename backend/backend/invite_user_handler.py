import os
import logging

from backend.database import User
from backend.handler import Handler
import json

log = logging.getLogger('labelspace.invite_user_handler')


class InviteUserHandler(Handler):
    def handle(self):
        log.info(f'handling event {self.event}')
        username = self.get_argument('email')
        organization_name = self.get_organization_name()
        log.info(
            f'creating new user {username}'
        )
        response = self.dependencies.cognito_client.admin_create_user(
            UserPoolId=os.environ['USERPOOL_ID'],
            Username=username
        )
        log.info(
            f'updating user attribute organization name {organization_name}'
        )
        self.dependencies.cognito_client.admin_update_user_attributes(
            UserPoolId=os.environ['USERPOOL_ID'],
            Username=username,
            UserAttributes=[
                {
                    'Name': 'custom:organization',
                    'Value': organization_name
                }
            ]
        )
        log.info('adding user to database')
        self.dependencies.database.create_user(
            User(
                email=self.get_argument('email'),
                sub=response['User']['Username'],
                organization=self.get_organization_ref()
            )
        )
        return json.dumps(
            {
                'email': self.get_argument('email'),
                'sub': response['User']['Username']
            }
        )

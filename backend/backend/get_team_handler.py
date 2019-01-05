from backend.handler import Handler
import json


class GetTeamHandler(Handler):
    def handle(self):
        organization_ref = self.get_organization_ref()
        users = self.dependencies.database.get_users_by_organization(
            organization_ref
        )
        return json.dumps(
            [
                {
                    'sub': user.sub,
                    'email': user.email
                }
                for user in users
            ]
        )

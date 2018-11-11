from backend.dependencies import Dependencies
from lib.immutable import Immutable


class Handler(Immutable):
    def __init__(self, event: dict, dependencies: Dependencies):
        self.event = event
        organization_id = self.get_organization_id()
        organization = dependencies.database.get_organization(organization_id)
        self.annotation_database = dependencies.annotation_database(organization)

    def get_organization_id(self):
        return self.event[
            'identity'
        ][
            'claims'
        ][
            'custom:organizationId'
        ]
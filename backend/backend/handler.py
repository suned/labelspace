from lib.annotation_database import AnnotationDatabase

from backend.dependencies import Dependencies
from lib.immutable import Immutable


class Handler(Immutable):
    def handle(self):
        raise NotImplementedError()

    def __init__(self, event: dict, dependencies: Dependencies):
        self.event = event
        self.dependencies = dependencies

    @property
    def annotation_database(self) -> AnnotationDatabase:
        organization_ref = self.get_organization_ref()
        organization = self.dependencies.database.get_organization(
            organization_ref
        )
        return self.dependencies.annotation_database(organization)

    def get_organization_ref(self):
        sub = self.event['identity']['claims']['sub']
        return (self
                .dependencies
                .database
                .get_user_by_sub(sub)
                .organization)

    def get_organization_name(self):
        return self.event[
            'identity'
        ][
            'claims'
        ][
            'custom:organization'
        ]

    def get_argument(self, name: str):
        return self.event['arguments'][name]

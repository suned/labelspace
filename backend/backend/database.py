from typing import List, Type
from faunadb.objects import Ref

from lib.fauna_database import FaunaDatabase, FaunaObject, T, FaunaIndex


class Organization(FaunaObject):
    def __init__(self,
                 secret: str = None,
                 ref: Ref = None):
        super().__init__(ref)
        self.secret = secret


class Database(FaunaDatabase):
    @staticmethod
    def classes() -> List[Type[T]]:
        return [Organization]

    @property
    def indices(self) -> List[FaunaIndex]:
        return []

    def create_organization(self, organization: Organization) -> Organization:
        return self._create(organization)

    def get_organization(self, ref: str) -> Organization:
        return self._get(Organization, ref)

    def update_organization(self, organization: Organization) -> Organization:
        return self._update(organization)

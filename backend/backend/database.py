from typing import List, Type, Tuple, Dict, Union
from faunadb.objects import Ref
from faunadb import query as q

from lib.fauna_database import FaunaDatabase, FaunaObject, T, FaunaIndex


class Organization(FaunaObject):
    def __init__(self,
                 organization_name: str,
                 secret: str = None,
                 ref: Ref = None,
                 ):
        super().__init__(ref)
        self.organization_name = organization_name
        self.secret = secret


class User(FaunaObject):
    def __init__(self, sub: str, email: str,  organization: Ref, ref: Ref = None):
        super().__init__(ref)
        self.sub = sub
        self.email = email
        self.organization = organization


class Database(FaunaDatabase):
    @staticmethod
    def classes() -> List[Type[T]]:
        return [Organization, User]

    @staticmethod
    def indices() -> Dict[str, FaunaIndex]:
        return {
            'users_by_sub': FaunaIndex(
                source=User,
                fields=['sub'],
                values=['organization', 'email'],
                unique=True
            ),
            'users_by_organization': FaunaIndex(
                source=User,
                fields=['organization'],
                values=['sub', 'email']
            )
        }

    def create_organization(self, organization: Organization) -> Organization:
        return self._create(organization)

    def get_organization(self, ref: Union[str, Ref]) -> Organization:
        if isinstance(ref, Ref):
            id_ = ref.id()
        else:
            id_ = ref
        return self._get(Organization, id_)

    def update_organization(self, organization: Organization) -> Organization:
        return self._update(organization)

    def create_user(self, user: User) -> User:
        return self._create(user)

    def get_user_by_sub(self, sub: str) -> User:
        return self._index_get('users_by_sub', sub)

    def get_users_by_organization(self, organization: Ref) -> List[User]:
        results = self.client.query(
            q.paginate(q.match(q.index('users_by_organization'), organization))
        )
        users = []
        for data in results['data']:
            users.append(User(
                sub=data[0],
                email=data[1],
                ref=data[2],
                organization=organization)
            )
        return users

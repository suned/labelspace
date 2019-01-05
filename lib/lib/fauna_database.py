import json
from typing import NewType, Dict, Any, TypeVar, Type, Tuple, List
import logging

from faunadb import query as q
from faunadb.client import FaunaClient
import stringcase

from faunadb.objects import Ref

from .immutable import Immutable

Secret = NewType('Secret', str)

log = logging.getLogger('labelspace.fauna_database')


class FaunaObject(Immutable):
    def __init__(self, ref: Ref = None):
        self.ref = ref

    @classmethod
    def name(cls) -> str:
        return cls.__name__

    def as_query(self) -> Dict[str, Any]:
        attrs = self.to_dict()
        attrs.pop('ref', None)
        for name, value in attrs.items():
            if isinstance(value, tuple):
                attrs[name] = list(value)
        return attrs

    def __repr__(self):
        cls = type(self)
        attrs = self.to_dict()
        attrs_fmt = [f'{name}={repr(value)}' for name, value in attrs.items()]
        return f'{cls.name()}({", ".join(attrs_fmt)})'

    def to_json(self):
        d = {}
        for name, value in self.to_dict().items():
            if isinstance(value, Ref):
                value = value.id()
            name = stringcase.camelcase(name)
            d[name] = value
        return json.dumps(d)

    def fields(self):
        d = self.to_dict()
        del d['ref']
        return list(d.keys())


T = TypeVar('T', bound=FaunaObject)


class ClientFactory:
    def __call__(self, secret: Secret) -> FaunaClient:
        return FaunaClient(secret)


class FaunaIndex(Immutable):
    def __init__(self, source: Type[T], fields=(), values=(), unique=False):
        self.source = source
        self.fields = fields
        self.values = values
        self.unique = unique


def _initialize_from_result(cls, result):
    data = result['data']
    for name, value in data.items():
        if isinstance(value, list):
            data[name] = tuple(value)
    return cls(ref=result['ref'], **data)


class FaunaDatabase(Immutable):

    @staticmethod
    def classes() -> List[Type[T]]:
        raise NotImplementedError()

    @staticmethod
    def indices() -> Dict[str, FaunaIndex]:
        raise NotImplementedError()

    def __init__(self,
                 secret: Secret,
                 client_factory=ClientFactory()):
        self.client_factory = client_factory
        self.client = self.client_factory(secret)

    def _get(self, cls: Type[T], ref: str) -> T:
        result = self.client.query(q.get(q.ref(q.class_(cls.name()), ref)))
        return _initialize_from_result(cls, result)

    def _create(self, instance: T) -> T:
        result = self.client.query(
            q.create(q.class_(instance.name()), {'data': instance.as_query()})
        )
        ref = result['ref']
        return instance.clone(ref=ref)

    def _update(self, instance: T) -> T:
        self.client.query(
            q.update(instance.ref, {'data': instance.as_query()})
        )
        return instance

    def _create_class(self, class_: Type[T]):
        self.client.query(
            q.create_class({'name': class_.name()})
        )

    def create_database(self,
                        name: str,
                        database: Type['FaunaDatabase'],
                        key_type: str) -> Secret:
        self.client.query(q.create_database({'name': name}))
        key = self.client.query(
            q.create_key(
                {'database': q.database(name), 'role': key_type}
            )
        )
        secret = Secret(key['secret'])
        database_instance = database(secret, self.client_factory)
        for class_ in database.classes():
            log.info(f'creating class {class_}')
            database_instance._create_class(class_)
        for name, index in database.indices().items():
            log.info(f'creating index {name}')
            database_instance.client.query(
                q.create_index(
                    {'name': name,
                     'source': q.class_(index.source.name()),
                     'terms': [
                         {'field': ['data', field]} for field in index.fields
                     ],
                     'values': [
                                   {
                                       'field': ["data", value]
                                   } for value in index.values
                               ] + [
                                   {'field': ['ref']}
                               ],
                     'unique': index.unique
                     }
                )
            )
        return Secret(secret)

    def _index_get(self, index_name: str, terms):
        index = self.indices()[index_name]
        result = self.client.query(q.get(q.match(q.index(index_name), terms)))
        return _initialize_from_result(index.source, result)

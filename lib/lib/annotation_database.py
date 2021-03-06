from faunadb import query as q
from typing import Tuple, Iterator, Type, Union, List


from faunadb.objects import Ref

from lib.fauna_database import T
from .fauna_database import FaunaDatabase, FaunaIndex
from .fauna_database import FaunaObject


class Label(FaunaObject):
    def __init__(self, label: str, label_type: str, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.label = label
        self.label_type = label_type


class Span(FaunaObject):
    def __init__(self,
                 start_index: int,
                 end_index: int,
                 html_start_index: int,
                 html_end_index: int,
                 label: Ref,
                 *args,
                 **kwargs):
        super().__init__(*args, **kwargs)
        self.start_index = start_index
        self.end_index = end_index
        self.html_start_index = html_start_index
        self.html_end_index = html_end_index
        self.label = label


class Relation(FaunaObject):
    def __init__(self,
                 first_span: Ref,
                 second_span: Ref,
                 label: Ref,
                 *args,
                 **kwargs):
        super().__init__(*args, **kwargs)
        self.first_span = first_span
        self.second_span = second_span
        self.label = label


class Document(FaunaObject):
    def __init__(self,
                 original_name: str,
                 converted: bool,
                 spans: Tuple[Ref] = (),
                 relations: Tuple[Ref] = (),
                 labels: Tuple[Ref] = (),
                 *args,
                 **kwargs):
        super().__init__(*args, **kwargs)
        self.original_name = original_name
        self.converted = converted
        self.spans = spans
        self.relations = relations
        self.labels = labels


class AnnotationDatabase(FaunaDatabase):
    @staticmethod
    def classes() -> List[Type[T]]:
        return [
            Label,
            Relation,
            Span,
            Document
        ]

    @staticmethod
    def indices():
        return {
            'documents': FaunaIndex(source=Document, values=('original_name', 'converted')),
            'labels': FaunaIndex(source=Label, values=('label', 'label_type'))
        }

    def create_document(self, document: Document) -> Document:
        return self._create(document)

    def replace_document(self, document: Document) -> Document:
        return self.client.query(
            q.replace(document.ref, {'data': document.as_query()})
        )

    def get_document(self, ref: str) -> Document:
        return self._get(Document, ref)

    def get_converted_documents(self) -> Iterator[Document]:
        results = self.client.query(
            q.filter_(
                q.lambda_(
                    ['original_name', 'converted', 'ref'],
                    q.var('converted')
                ),
                q.paginate(q.match(q.index('documents')))
            )
        )
        documents = []
        for data in results['data']:
            documents.append(
                Document(
                    original_name=data[0],
                    converted=data[1],
                    ref=data[2]
                )
            )
        return documents

    def create_label(self, label: Label) -> Label:
        return self._create(label)

    def get_labels(self):
        results = self.client.query(
            q.paginate(q.match(q.index('labels')))
        )
        labels = []
        for data in results['data']:
            labels.append(
                Label(
                    label=data[0],
                    label_type=data[1],
                    ref=data[2]
                )
            )
        return labels




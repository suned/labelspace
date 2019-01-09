from backend.handler import Handler
import json


class GetDocumentsHandler(Handler):
    def handle(self):
        documents = self.annotation_database.get_converted_documents()
        return json.dumps(
            [
                {
                    'ref': document.ref.id(),
                    'name': document.original_name
                } for document in documents
            ]
        )

from backend.handler import Handler
import json


class GetLabelsHandler(Handler):
    def handle(self):
        labels = self.annotation_database.get_labels()
        return json.dumps(
            [
                {
                    'label': label.label,
                    'labelType': label.label_type,
                    'ref': label.ref.id()
                }
                for label in labels
            ]
        )


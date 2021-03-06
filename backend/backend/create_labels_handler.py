import logging

from backend.handler import Handler
from lib.annotation_database import Label

log = logging.getLogger('labelspace.create_labels_handler')


class CreateLabelHandler(Handler):
    def is_recognized_label_type(self):
        return self.get_argument('labelType') in ('document', 'span', 'relation')

    def create_label(self) -> Label:
        label_type = self.get_argument('labelType')
        label_value = self.get_argument('label')
        label = Label(label=label_value, label_type=label_type)
        return self.annotation_database.create_label(label)

    def handle(self):
        if not self.is_recognized_label_type():
            raise Exception(
                f'unrecognized label type: {self.get_argument("labelType")}'
            )
        label = self.create_label()
        json = label.to_json()
        log.info(f'returning label:\n {json}')
        return json

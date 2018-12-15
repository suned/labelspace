import json

from lib.fauna_database import FaunaObject


class SomeObject(FaunaObject):
    def __init__(self, snake_cased_name: str, list_attribute: tuple, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.snake_cased_name = snake_cased_name
        self.list_attribute = list_attribute


def test_to_json():
    some_instance = SomeObject(snake_cased_name='value', list_attribute=('value',))
    assert json.loads(some_instance.to_json()) == {
        'ref': None,
        'snakeCasedName': 'value',
        'listAttribute': ['value']
    }

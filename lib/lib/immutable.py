import functools
from typing import TypeVar

T = TypeVar('T')


def _initialized_flag(cls):
    return f'_{cls.__name__}__initialized'


def _decorate_setattr(cls):
    __setattr__ = cls.__setattr__

    @functools.wraps(__setattr__)
    def decorator(self, name, value):
        initialized_flag = _initialized_flag(type(self))
        if getattr(self, initialized_flag, False):
            raise AttributeError(f'{self} is immutable')
        __setattr__(self, name, value)

    return decorator


def _decorate_init(cls):
    __init__ = cls.__init__
    initialized_flag = _initialized_flag(cls)

    @functools.wraps(__init__)
    def decorator(self, *args, **kwargs):
        __init__(self, *args, **kwargs)
        setattr(self, initialized_flag, True)

    return decorator


class Immutable:
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        cls.__setattr__ = _decorate_setattr(cls)
        cls.__init__ = _decorate_init(cls)
        return cls

    def to_dict(self):
        attrs = self.__dict__.copy()
        cls = type(self)
        super_classes = cls.mro()
        for super_class in super_classes:
            attrs.pop(_initialized_flag(super_class), None)
        return attrs

    def clone(self: T, **kwargs) -> T:
        attrs = self.to_dict()
        attrs.update(kwargs)
        return type(self)(**attrs)

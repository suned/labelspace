import argparse
import subprocess
from abc import abstractmethod, ABC


class Script(ABC):
    def __init_subclass__(cls, **kwargs):
        if cls.__module__ == '__main__':
            instance = cls()
            instance._run()

    @abstractmethod
    def parse_args(self) -> argparse.Namespace:
        pass

    @abstractmethod
    def run(self, *args, **kwargs):
        pass

    def _run(self):
        args = self.parse_args()
        self.run(**vars(args))

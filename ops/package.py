import argparse

from deploy_stack import create_deploy_package, package, default_stack_name

from script import Script


class Package(Script):
    def parse_args(self) -> argparse.Namespace:
        parser = argparse.ArgumentParser()
        parser.add_argument('--stack-name', default=default_stack_name())
        return parser.parse_args()

    def run(self, stack_name):
        create_deploy_package()
        package(stack_name)

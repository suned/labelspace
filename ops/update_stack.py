import argparse
import envparse

from ruamel.yaml import YAML

from deploy_stack import default_stack_name, output_template_name, \
    create_deploy_package, delete_deploy_package, validate, package, deploy
from script import Script


def get_bucket_name(file):
    with open(file) as f:
        yaml = YAML().load(f)
    # simply get one s3 path because they're all identical
    bucket = yaml[
        'Resources'
    ][
        'CognitoPostConfirmationTrigger'
    ][
        'Properties'
    ][
        'CodeUri'
    ]
    return bucket


def read_secret():
    env = envparse.Env()
    env.read_envfile('../backend/.env')
    return env('DATABASE_SECRET')


class Update(Script):
    def parse_args(self) -> argparse.Namespace:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            '--stack-name',
            default=default_stack_name()
        )
        return parser.parse_args(())

    def run(self, stack_name):
        validate()
        create_deploy_package()
        template = package(stack_name)
        delete_deploy_package()
        secret = read_secret()
        deploy(stack_name, template, secret)





import argparse
import os
import subprocess

from deploy_stack import default_stack_name
from script import Script


class DescribeStackEvents(Script):
    def parse_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            '--stack-name',
            default=default_stack_name()
        )
        return parser.parse_args()

    def run(self, stack_name: str):
        subprocess.check_call(
            [
                'aws',
                'cloudformation',
                'describe-stack-events',
                '--stack-name', stack_name,
                '--region', os.environ['AWS_REGION']
            ]
        )


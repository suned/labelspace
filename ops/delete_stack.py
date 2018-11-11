import argparse
import subprocess
import os

import boto3
from faunadb.client import FaunaClient
from faunadb import query as q

from deploy_stack import (
    output_template_name,
    default_stack_name,
    lambda_code_bucket
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--stack-name',
        default=default_stack_name()
    )
    return parser.parse_args()


def delete_template(stack_name):
    try:
        os.remove(output_template_name(stack_name))
    except:
        pass


def delete_lambda_code(stack_name):
    subprocess.check_call(
        [
            'aws',
            's3',
            'rm',
            f's3://{lambda_code_bucket()}/{stack_name}',
            '--recursive'
        ]
    )


def update_environment():
    try:
        os.remove('../client/.env.development')
    except:
        pass


def delete_database(stack_name):
    client = FaunaClient(secret=os.environ['FAUNADB_SECRET'])
    client.query(q.delete(q.database(stack_name)))


def delete_bucket_data(stack_name):
    upload_bucket_name = f'{stack_name}-labelspace-upload'
    collection_bucket_name = f'{stack_name}-labelspace-collection'
    s3 = boto3.resource('s3', region_name=os.environ['AWS_REGION'])
    try:
        upload_bucket = s3.Bucket(upload_bucket_name)
        upload_bucket.objects.all().delete()
        collection_bucket = s3.Bucket(collection_bucket_name)
        collection_bucket.objects.all().delete()
    except:
        pass


def run(stack_name):
    delete_stack(stack_name)
    delete_bucket_data(stack_name)
    delete_database(stack_name)
    delete_lambda_code(stack_name)
    delete_template(stack_name)
    update_environment()


def delete_stack(stack_name):
    subprocess.check_call(
        [
            'aws',
            'cloudformation',
            'delete-stack',
            '--stack-name', stack_name,
            '--region', os.environ['AWS_REGION']
        ]
    )


if __name__ == '__main__':
    args = parse_args()
    run(**vars(args))

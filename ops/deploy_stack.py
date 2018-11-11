import argparse
import os
import subprocess
import json
import sys

from faunadb.client import FaunaClient
from faunadb import query as q
import plumbum


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--stack-name',
        default=default_stack_name()
    )
    return parser.parse_args()


def default_stack_name():
    return f'{os.environ["AWS_USERNAME"].lower().replace(".", "-")}-development'


def package(stack_name):
    print_section('package')
    file = output_template_name(stack_name)
    subprocess.check_call(
        [
            'sam',
            'package',
            '--template-file', './template.yml',
            '--output-template-file', file,
            '--s3-bucket', lambda_code_bucket(),
            '--s3-prefix', stack_name
         ]
    )
    return file


def lambda_code_bucket():
    return 'labelspace-lambda-code'


def output_template_name(stack_name):
    return f'{stack_name}.template.output.yaml'


def validate():
    print_section('validate')
    subprocess.check_call(
        [
            'sam',
            'validate'
        ]
    )


def deploy(stack_name, template, secret):
    print_section('deploy')
    subprocess.check_call(
        [
            'sam',
            'deploy',
            '--stack-name', stack_name,
            '--template-file', template,
            '--parameter-overrides',
            f'StackName={stack_name}',
            f'Database={stack_name}',
            f'DatabaseSecret={secret}',
            '--capabilities', 'CAPABILITY_IAM',
            '--region', os.environ['AWS_REGION']
        ]
    )


def update_backend_environment(secret):
    with open('../backend/.env', 'w') as f:
        f.write(f'DATABASE_SECRET={secret}\n')


def update_local_environment(stack_name, secret):
    print_section('update env')
    update_client_environment(stack_name)
    update_backend_environment(secret)


def update_client_environment(stack_name):
    status = json.loads(
        subprocess.check_output(
            [
                'aws',
                'cloudformation',
                'describe-stacks',
                '--stack-name', stack_name,
                '--region', os.environ['AWS_REGION'],

            ]
        )
    )
    outputs = status['Stacks'][0]['Outputs']
    user_pool_client_id = next(output for output in outputs
                               if output['OutputKey'] == 'UserPoolClientId')
    user_pool_id = next(output for output in outputs
                        if output['OutputKey'] == 'UserPoolId')
    api_url = next(
        output for output in outputs if output['OutputKey'] == 'ApiUrl')
    with open('../client/.env.development', 'w') as f:
        f.write(
            f'''LS_COGNITO_USER_POOL_ID={user_pool_id['OutputValue']}
LS_COGNITO_CLIENT_ID={user_pool_client_id['OutputValue']}
LS_API_URL={api_url['OutputValue']}
'''
        )


def print_section(section: str):
    print()
    print(f'------------------------ {section.upper()} ------------------------')
    print()


def create_deploy_package():
    print_section('dependencies')
    with plumbum.local.cwd('../backend'):
        pipenv = plumbum.local['pipenv']
        requirements = pipenv['lock', '-r']
        install = pipenv[
            'run',
            'pip',
            'install',
            '-t', 'deploy_package',
            '-r', '/dev/stdin'
        ]
        install_requirements = requirements | install
        install_requirements(stdout=sys.stdout)
        plumbum.cmd.cp['-r', 'backend', 'deploy_package'](stdout=sys.stdout)


def create_database(stack_name):
    print_section('database')
    client = FaunaClient(secret=os.environ['FAUNADB_SECRET'])
    client.query(
        q.create_database(
            {'name': stack_name}
        )
    )
    key = client.query(
        q.create_key(
            {'database': q.database(stack_name), 'role': 'admin'}
        )
    )
    secret = key['secret']
    FaunaClient(secret=secret).query(q.create_class({'name': 'Organization'}))
    return key['secret']


def delete_deploy_package():
    plumbum.cmd.rm['-rf', '../backend/deploy_package']()


def run(stack_name: str):
    validate()
    create_deploy_package()
    template = package(stack_name)
    delete_deploy_package()
    secret = create_database(stack_name)
    deploy(stack_name, template, secret)
    update_local_environment(stack_name, secret)


if __name__ == "__main__":
    args = parse_args()
    run(**vars(args))

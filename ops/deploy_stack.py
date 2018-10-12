import argparse
import os
import subprocess
import json


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
    file = output_name(stack_name)
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


def output_name(stack_name):
    return f'{stack_name}.template.output.yaml'


def validate():
    print_section('validate')
    subprocess.check_call(
        [
            'sam',
            'validate'
        ]
    )


def deploy(stack_name, template):
    print_section('deploy')
    subprocess.check_call(
        [
            'sam',
            'deploy',
            '--stack-name', stack_name,
            '--template-file', template,
            '--parameter-overrides', f'StackName={stack_name}',
            '--capabilities', 'CAPABILITY_IAM',
            '--region', os.environ['AWS_REGION']
        ]
    )


def update_environment(stack_name):
    print_section('update env')
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
    with open('../client/.env.development', 'w') as f:
        f.write(
            f'''LS_COGNITO_USER_POOL_ID={user_pool_id['OutputValue']}
LS_COGNITO_CLIENT_ID={user_pool_client_id['OutputValue']}'''
        )


def print_section(section: str):
    print()
    print(f'------------------------ {section.upper()} ------------------------')
    print()


def compile_lambda_code():
    print_section('compile')
    cwd = os.getcwd()
    os.chdir('../backend')
    subprocess.check_call(
        [
            'sbt',
            'compile',
            'assembly'
        ]
    )
    os.chdir(cwd)


def run(stack_name: str):
    validate()
    compile_lambda_code()
    template = package(stack_name)
    deploy(stack_name, template)
    update_environment(stack_name)


if __name__ == "__main__":
    args = parse_args()
    run(**vars(args))

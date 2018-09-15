import argparse
import os


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--stack-name',
        default=f'{os.environ["AWS_ACCESS_KEY_ID"]}-DEV'
    )
    return parser.parse_args()


def run(stack_name: str):
    output_path = f'../client/.env.{stack_name}'


if __name__ == "__main__":
    args = parse_args()
    run(**vars(args))

# labelspace ops

## Dependencies

python 3.6
pipenv

## Install requirements

`pipenv install -d`

## Instructions

create a .env file in the root of the project with the following variables:

```
AWS_SECRET_ACCESS_KEY=[Your aws secret key]
AWS_ACCESS_KEY_ID=[your aws access key id]
AWS_REGION=eu-west-1
AWS_USERNAME=[your aws username]
FAUNADB_SECRET=[faunadb admin db key]
```

Then run

`pipenv run deploy-stack`

This will deploy a development stack on AWS using cloudformation, and provision
a faunadb database for this stack.

It will also create a `env.development` file in the `client` with
- The api url for your development appsync endpoint
- The cognito client id and user pool id

You can now run `yarn make && yarn serve:watch` in the client folder to serve a
client on localhost against your development stack.

After editing the code in `backend`, run

`pipenv run update-stack`

To update the lambda function code on AWS.

To delete the stack, run

`pipenv run delete-stack`

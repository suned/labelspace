from distutils.core import setup

setup(
    name='backend',
    version='1.0',
    description='labelspace backend library',
    author='Sune Debel',
    author_email='sune.debel@labelspace.ai',
    requires=['faunadb', 'stringcase', 'boto3'],
    packages=['backend']
)

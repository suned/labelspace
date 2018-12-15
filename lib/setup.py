from distutils.core import setup

setup(
    name='lib',
    version='1.0',
    description='labelspace shared library',
    author='Sune Debel',
    author_email='sune.debel@labelspace.ai',
    requires=['faunadb', 'stringcase'],
    packages=['lib']
)

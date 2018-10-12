from unittest.mock import call

from api.cognito_post_confirmation_handler import handle

from faunadb import query as q


def test_handler_creates_organization(event_reader, mock_dependencies):

    def test_buckets_are_created():
        mock_dependencies.upload_bucket.put_object.assert_called_with(Key='1234/', Body=b'')
        mock_dependencies.collection_bucket.put_object.assert_called_with(Key='1234/', Body=b'')

    def test_user_attributes_are_updated():
        mock_dependencies.cognito_client.admin_update_user_attributes.assert_called_with(
            UserPoolId='some-user-pool-id',
            Username='username',
            UserAttributes=[
                {
                    'Name': 'custom:organizationId',
                    'Value': '1234'
                }
            ]
        )

    def test_queries_are_made():
        # The client mock is used by both the
        # database and annotation database
        # so here we assert calls for both
        # could maybe be improved by changing the way databases are created?
        create_annotation_database_queries = [
            q.create_database({'name': '1234-annotations'}),
            q.create_key(
                {'database': q.database('1234-annotations'), 'role': 'server'}
            )
        ]
        mock_dependencies.database.client.query.assert_has_calls(
            [call(query) for query in create_annotation_database_queries]
        )
        setup_annotation_database_queries = [
            q.create_class({'name': 'SpanLabel'}),
            q.create_class({'name': 'DocumentLabel'}),
            q.create_class({'name': 'RelationLabel'}),
            q.create_class({'name': 'Relation'}),
            q.create_class({'name': 'Span'}),
            q.create_class({'name': 'Document'}),
            q.create_index(
                {'name': 'documents', 'source': q.class_('Document')}),
            q.create_index(
                {'name': 'span_labels', 'source': q.class_('SpanLabel')}
            ),
            q.create_index(
                {'name': 'relation_labels', 'source': q.class_('RelationLabel')}
            ),
            q.create_index(
                {'name': 'document_labels', 'source': q.class_('DocumentLabel')}
            )
        ]
        mock_dependencies.database.client.query.assert_has_calls(
            [call(query) for query in setup_annotation_database_queries]
        )

        event = event_reader('post_confirmation_event.json')
        handle(event, {}, dependencies=mock_dependencies)
        test_buckets_are_created()
        test_queries_are_made()
        test_user_attributes_are_updated()


def test_handler_adds_user_to_organization(event_reader):
    pass

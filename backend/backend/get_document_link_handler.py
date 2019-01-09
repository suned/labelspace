from backend.handler import Handler


class GetDocumentLinkHandler(Handler):
    def handle(self):
        document_id = self.get_argument('ref')
        organization_id = self.get_organization_ref().id()
        key = f'{organization_id}/{document_id}.html'
        return self.dependencies.s3_client_sigv2.generate_presigned_url(
            ClientMethod='get_object',
            Params={
                'Bucket': self.dependencies.collection_bucket.name,
                'Key': key
            }
        )

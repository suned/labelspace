import datetime
import os

from backend.handler import Handler


class GetS3UploadPostHandler(Handler):
    def handle(self):
        expiration_seconds = datetime.timedelta(days=1).total_seconds()
        key = self.get_organization_ref().id() + '/${filename}'
        post = self.dependencies.s3_client.generate_presigned_post(
            Bucket=os.environ['UPLOAD_BUCKET'],
            Key=key,
            ExpiresIn=expiration_seconds
        )
        return post

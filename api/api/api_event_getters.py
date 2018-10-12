def get_organization_id(event: dict):
    return event[
        'requestContext'
    ][
        'authorizer'
    ][
        'claims'
    ][
        'custom:organizationId'
    ]


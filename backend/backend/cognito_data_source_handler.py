from backend.dependencies import AWSDependencies
from backend.invite_user_handler import InviteUserHandler


def handle(event: dict, _, dependencies=AWSDependencies()):
    if event['field'] == 'inviteUser':
        return InviteUserHandler(event, dependencies).handle()
    raise Exception(f'Unknown field: {event["field"]}')

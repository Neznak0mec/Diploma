import psycopg2.extensions

from config import *
from database.collections.RecordTranscriptionCollection import RecordTranscriptionCollection
from database.collections.TasksCollection import TasksCollection


class DataBase:

    def __init__(self):
        connection: psycopg2.extensions.connection = psycopg2.connect(
            host=database_host,
            user=database_user,
            password=database_password,
            database="radio",
            port=database_port
        )

        self.RecordTranscription = RecordTranscriptionCollection(connection)
        self.Tasks = TasksCollection(connection)

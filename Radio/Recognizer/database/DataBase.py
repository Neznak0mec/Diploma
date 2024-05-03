import psycopg2.extensions

from database.collections.RecordTranscriptionCollection import RecordTranscriptionCollection
from database.collections.TasksCollection import TasksCollection


class DataBase:

    def __init__(self):
        connection: psycopg2.extensions.connection = psycopg2.connect(
            host="localhost",
            user="user",
            password="password",
            database="radio",
            port="5432"
        )

        self.RecordTranscription = RecordTranscriptionCollection(connection)
        self.Tasks = TasksCollection(connection)

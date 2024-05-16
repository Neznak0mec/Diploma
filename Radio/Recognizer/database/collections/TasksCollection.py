import psycopg2.extensions
from database.Models.TranscriptionTask import TranscriptionTaskStatus, Audio


class TasksCollection:
    def __init__(self, connection: psycopg2.extensions.connection):
        self.connection: psycopg2.extensions.connection = connection

    def get_task(self):
        cursor = self.connection.cursor()
        cursor.execute("""SELECT * FROM \"Audios\" WHERE status = %s""", (0,))
        result = cursor.fetchall()
        res = []
        for i in result:
            res.append(Audio(i[0], i[1], i[2], i[3], i[4], i[5]))
        cursor.close()
        return res

    def get_fingerprint_tasks(self):
        cursor = self.connection.cursor()
        cursor.execute("""SELECT * FROM \"Audios\" WHERE status = %s OR status = %s""", (10, 20,))
        result = cursor.fetchall()
        res = []
        for i in result:
            res.append(Audio(i[0], i[1], i[2], i[3], i[4], i[5]))
        cursor.close()
        return res

    def update_task(self, file_name: str, new_status: TranscriptionTaskStatus):
        cursor = self.connection.cursor()
        cursor.execute("""UPDATE \"Audios\" SET status = %s WHERE \"fileName\" = %s""",
                       (new_status.value, file_name))
        self.connection.commit()
        cursor.close()

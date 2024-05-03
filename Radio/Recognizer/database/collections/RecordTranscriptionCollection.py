import psycopg2.extensions

from database.Models.RecordTranscription import RecordTranscription, RadioSegment, News, TextSegment


class RecordTranscriptionCollection:
    def __init__(self, connection: psycopg2.extensions.connection):
        self.connection: psycopg2.extensions.connection = connection
        self.create_tables()

    def create_tables(self):

        with self.connection.cursor() as cursor:
            table_statements = [

                """
                CREATE TABLE IF NOT EXISTS radio_data (
                    id SERIAL PRIMARY KEY,
                    radio_name VARCHAR(255),
                    file_name VARCHAR(255),
                    start_time TIMESTAMP,
                    end_time TIMESTAMP
                )
                """,

                """
                CREATE TABLE IF NOT EXISTS segments (
                    id SERIAL PRIMARY KEY,
                    radio_data_id INT,
                    track_name VARCHAR(255),
                    start_time INT,
                    end_time INT,
                    text TEXT,
                    FOREIGN KEY (radio_data_id) REFERENCES radio_data(id) ON DELETE CASCADE
                )
                """,

                """
                CREATE TABLE IF NOT EXISTS text_segments (
                    id SERIAL PRIMARY KEY,
                    segment_id INT,
                    text TEXT,
                    start INT,
                    "end" INT,
                    FOREIGN KEY (segment_id) REFERENCES segments(id) ON DELETE CASCADE
                )
                """,

                """
                 CREATE TABLE IF NOT EXISTS news (
                    id SERIAL PRIMARY KEY,
                    radio_data_id INT,
                    start INT,
                    "end" INT,
                    FOREIGN KEY (radio_data_id) REFERENCES radio_data(id) ON DELETE CASCADE
                )
                """,

                """
                CREATE TABLE IF NOT EXISTS jingles (
                    id SERIAL PRIMARY KEY,
                    radio_data_id INT,
                    time INT,
                    FOREIGN KEY (radio_data_id) REFERENCES radio_data(id) ON DELETE CASCADE
                )
                """]

            for statement in table_statements:
                cursor.execute(statement)

            self.connection.commit()

    def insert(self, record_transcription: RecordTranscription) -> None:
        cursor = self.connection.cursor()

        radio_data_query = ("INSERT INTO radio_data (radio_name, file_name, start_time, end_time) "
                            "VALUES (%s, %s, %s, %s) RETURNING id")
        radio_data_values = (record_transcription.radioName, record_transcription.fileName,
                             record_transcription.startTime, record_transcription.endTime)
        cursor.execute(radio_data_query, radio_data_values)
        radio_data_id = cursor.fetchone()[0]

        for segment in record_transcription.segments:
            segment_query = ("INSERT INTO segments (radio_data_id, track_name, start_time, end_time, text) "
                             "VALUES (%s, %s, %s, %s, %s) RETURNING id")
            segment_values = (radio_data_id, segment.track_name, segment.start_time,
                              segment.end_time, segment.text)
            cursor.execute(segment_query, segment_values)
            segment_id = cursor.fetchone()[0]

            for text_segment in segment.text_segments:
                text_segment_query = ("INSERT INTO text_segments (segment_id, text, start, \"end\") "
                                      "VALUES (%s, %s, %s, %s)")
                text_segment_values = (segment_id, text_segment.text,
                                       text_segment.start, text_segment.end)
                cursor.execute(text_segment_query, text_segment_values)

        for news_item in record_transcription.news:
            news_query = ("INSERT INTO news (radio_data_id, start, \"end\") "
                          "VALUES (%s, %s, %s)")
            news_values = (radio_data_id, news_item.start, news_item.end)
            cursor.execute(news_query, news_values)

        for jingle_id in record_transcription.jingles:
            jingle_query = ("INSERT INTO jingles (radio_data_id, time) "
                            "VALUES (%s, %s)")
            jingle_values = (radio_data_id, jingle_id)
            cursor.execute(jingle_query, jingle_values)
        self.connection.commit()
        cursor.close()

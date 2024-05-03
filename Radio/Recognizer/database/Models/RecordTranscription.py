import datetime


class News:
    def __init__(self, start, end):
        self.start: int or None = start
        self.end: int or None = end


class TextSegment:
    def __init__(self, text: str, start: int, end: int):
        self.text: str = text
        self.start = start
        self.end = end


class RadioSegment:
    def __init__(self, track_name: str, start_time: int, end_time: int, text: str, text_segments: list[TextSegment]):
        self.track_name = track_name
        self.start_time = start_time
        self.end_time = end_time
        self.text = text
        self.text_segments: list[TextSegment] = text_segments


class RecordTranscription:

    def __init__(self, radioName: str, fileName: str, startTime: datetime.datetime, endTime: datetime.datetime,
                 segments: list[RadioSegment], news: list[News], jingles: list[int]):
        self.radioName: str = radioName
        self.fileName: str = fileName
        self.startTime: datetime.datetime = startTime
        self.endTime: datetime.datetime = endTime
        self.segments: list[RadioSegment] = segments
        self.news: list[News] = news
        self.jingles: list[int] = jingles

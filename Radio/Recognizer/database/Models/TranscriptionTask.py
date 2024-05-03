import datetime
from enum import Enum


class TranscriptionTaskStatus(Enum):
    queued_for_transcription = 0
    transcribed = 1

    queued_for_fingerprint = 10
    fingerprinted = 11


class Audio:

    def __init__(self):
        self.file_name: str
        self.folder: str
        self.radio_name: str
        self.start: datetime.datetime
        self.end: datetime.datetime

        self.status: TranscriptionTaskStatus

    def __init__(self, file_name: str, folder: str, radio_name: str,start, end, status: TranscriptionTaskStatus):
        self.file_name: str = file_name
        self.folder: str = folder
        self.radio_name: str = radio_name
        self.start: datetime.datetime = start
        self.end: datetime.datetime = end

        self.status: TranscriptionTaskStatus = status

import asyncio

from pydub import AudioSegment
from shazamio import Shazam

from config import *
from dejavu import Dejavu
from dejavu.logic.recognizer.segment_recognizer import SegmentRecognizer

config = {
    'database': {
        "host": database_host,
        "user": database_user,
        "password": database_password,
        "port": database_port,
        "database": "dejavu"},
    "database_type": "postgres"}


class NetworkMusicRecognizer:

    def __init__(self):
        self.shazam = Shazam()

    async def recognize(self, data: AudioSegment):
        out = await self.shazam.recognize_song(data)
        if out['matches']:
            return f"{out['track']['title']} - {out['track']['subtitle']}"
        else:
            return "Not Found"


class LocalMusicRecognizer:

    def __init__(self):
        self.djv = Dejavu(config)

    async def recognize(self, segment: AudioSegment, all_results=False, use_network=False) -> list[str] or str:
        song = self.djv.recognize(SegmentRecognizer, segment)

        if use_network and song['results'] == [] and not all_results:
            while (True):
                try:
                    result = await NetworkMusicRecognizer().recognize(segment)
                    if result != "Not Found":
                        return result + "(Online)"
                    return result
                except:
                    await asyncio.sleep(10)
                    continue

        result = ""

        if all_results:
            result = []
            for i in song['results']:
                result.append(str(i['song_name'], 'utf-8'))
        elif song['results']:
            return str(song['results'][0]['song_name'], 'utf-8')

        return result

    async def fingerprint_folder(self, folder_path: str, file_format: list[str] = ["mp3"], count_of_cores: int = 2):
        self.djv.fingerprint_directory(folder_path, file_format, count_of_cores)

    async def fingerprint_file(self, file_path: str, song_name: str):
        self.djv.fingerprint_file(file_path, song_name)

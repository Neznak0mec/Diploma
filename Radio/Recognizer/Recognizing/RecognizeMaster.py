import asyncio
import datetime
import json
from asyncio import Task

import requests
from pydub import AudioSegment

from Recognizing.FindMaster import FindMaster
from Recognizing.MusicRecognizer import LocalMusicRecognizer, NetworkMusicRecognizer
from Recognizing.TextRecognizer import TextRecognizer
from database.DataBase import DataBase
from database.Models.RecordTranscription import RecordTranscription, RadioSegment, TextSegment
from database.Models.TranscriptionTask import TranscriptionTaskStatus, Audio


class RecognizeMaster:
    search_in_internet = True
    transcribing = []

    def __init__(self):
        self.text_recognizer = TextRecognizer()
        self.local_sound_recognizer = LocalMusicRecognizer()
        self.network_sound_recognizer = NetworkMusicRecognizer()

        self.finder = FindMaster()

        self.db = DataBase()

    async def run(self):
        while True:
            tasks = self.db.Tasks.get_task()
            print(tasks)
            if tasks:
                to_transcribe = []
                for i in tasks:
                    if i.file_name not in self.transcribing:
                        to_transcribe.append(i)
                        self.transcribing.append(i.file_name)

                await asyncio.create_task(self.transcribe(to_transcribe))

            fingerprint_tasks = self.db.Tasks.get_fingerprint_tasks()
            if fingerprint_tasks:
                to_fingerprint = []
                for i in fingerprint_tasks:
                    if i.file_name not in self.transcribing:
                        to_fingerprint.append(i)
                        self.transcribing.append(i.file_name)
                await asyncio.create_task(self.fingerprint_songs(to_fingerprint))

            await asyncio.sleep(60)

    async def fingerprint_songs(self, fingerprint_tasks: list):
        i: Audio
        for i in fingerprint_tasks:
            path = f"../AudioCaptureServer/FingerPrint/{i.file_name}"
            await self.local_sound_recognizer.fingerprint_file(path, i.radio_name)
            self.db.Tasks.update_task(i.file_name, TranscriptionTaskStatus.fingerprinted)
            self.transcribing.remove(i.file_name)

    async def transcribe(self, tasks: list[Audio]):
        task: Audio
        for task in tasks:
            print(f"start recognizing {task.file_name}")
            audio_path = f"../AudioCaptureServer/records/{task.folder}/{task.file_name}"

            audio = AudioSegment.from_file(audio_path)

            available_songs = await self.local_sound_recognizer.recognize(audio, True)

            segment_duration = 60 * 1000
            current_time = 0
            segments = []
            news = []
            jingles = []
            while current_time < len(audio):
                print(f"Progress: {current_time / len(audio) * 100:.2f}%")
                segment = audio[current_time:current_time + segment_duration]

                tasks = [
                    Task(self.local_sound_recognizer.recognize(segment, use_network=self.search_in_internet)),
                    Task(self.text_recognizer.recognize_audio(segment))
                ]

                await asyncio.gather(*tasks)

                recognized_name = tasks[0].result()
                text = tasks[1].result()

                if recognized_name not in available_songs and not self.search_in_internet:
                    recognized_name = "not found"

                text_segments: list[TextSegment] = []
                for i in text['segments']:
                    tmp = TextSegment(
                        i['text'],
                        i['start'] + current_time / 1000,
                        i['end'] + current_time / 1000
                    )
                    text_segments.append(tmp)

                radio_segment = RadioSegment(
                    recognized_name,
                    int(current_time / 1000),
                    int((current_time + len(segment)) / 1000),
                    text['text'],
                    text_segments
                )

                if not segments:
                    segments.append(radio_segment)

                else:
                    previous_segment = segments[-1]

                    if previous_segment.track_name == radio_segment.track_name:
                        previous_segment.end_time = radio_segment.end_time
                        previous_segment.text += radio_segment.text
                        previous_segment.text_segments += radio_segment.text_segments
                    
                    else:
                        segments.append(radio_segment)

                jingles += (self.finder.find_jangles(radio_segment.text_segments))
                news += self.finder.find_news_segments(radio_segment.text_segments)

                current_time += segment_duration

            # with open(f"data-{filename}.json", "w") as final:
            #     json.dump(tracks_info, final, ensure_ascii=False)

            record = RecordTranscription(
                task.radio_name,
                task.file_name,
                task.start,
                task.end,
                segments,
                news,
                jingles
            )

            print(f"end recognizing {task.file_name}")
            self.db.RecordTranscription.insert(record)
            self.db.Tasks.update_task(record.fileName, TranscriptionTaskStatus.transcribed)
            self.transcribing.remove(record.fileName)

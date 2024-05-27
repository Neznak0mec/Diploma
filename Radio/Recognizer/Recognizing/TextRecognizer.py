import numpy as np
# import torch
import whisper
from pydub import AudioSegment


class TextRecognizer:
    def __init__(self):
        self.model = whisper.load_model("medium") #маленькая модель
        #self.model = whisper.load_model("large")#большие модели
        # self.model = whisper.load_model("large-v2")

    # Функция для распознавания аудиофайла
    async def recognize_audio(self, segment: AudioSegment):
        if segment.frame_rate != 16000:
            segment = segment.set_frame_rate(16000)
        if segment.sample_width != 2:
            segment = segment.set_sample_width(2)
        if segment.channels != 1:
            segment = segment.set_channels(1)
        arr = np.array(segment.get_array_of_samples())
        arr = arr.astype(np.float32) / 32768.0

        result = self.model.transcribe(arr, fp16=False)

        segments = []

        for i in result['segments']:
            seg = {
                'text': i['text'],
                'start': i['start'],
                'end': i['end']
            }
            segments.append(seg)

        result = {
            "text": result['text'],
            "segments": segments
        }

        return result

import uuid
from time import time
from typing import Dict

import numpy as np
from pydub import AudioSegment

from dejavu.base_classes.base_recognizer import BaseRecognizer
from dejavu.config.settings import (ALIGN_TIME, FINGERPRINT_TIME, QUERY_TIME,
                                    RESULTS, TOTAL_TIME)


class SegmentRecognizer(BaseRecognizer):
    def __init__(self, dejavu):
        super().__init__(dejavu)

    def recognize_segment(self, segment: AudioSegment) -> Dict[str, any]:
        channels, self.Fs, _ = self.decode(segment)

        t = time()
        matches, fingerprint_time, query_time, align_time = self._recognize(*channels)
        t = time() - t

        results = {
            TOTAL_TIME: t,
            FINGERPRINT_TIME: fingerprint_time,
            QUERY_TIME: query_time,
            ALIGN_TIME: align_time,
            RESULTS: matches
        }

        return results

    def decode(self,segment: AudioSegment):
        data = np.fromstring(segment.raw_data, np.int16)

        channels = []
        for chn in range(segment.channels):
            channels.append(data[chn::segment.channels])

        return channels, segment.frame_rate, uuid.uuid4().__str__()

    def recognize(self, segment: AudioSegment) -> Dict[str, any]:
        return self.recognize_segment(segment)
import re

from database.Models.RecordTranscription import News, TextSegment


class FindMaster:

    def find_news_segments(self, segments: list[TextSegment]) -> list[News]:
        news_pattern = re.compile(r'(новост\w*)',
                                  re.IGNORECASE)

        news_segments = [segment for segment in segments if re.search(news_pattern, segment.text.lower())]

        normal_segments = news_segments
        reversed_segments = news_segments[::-1]

        news = []

        skip_to = None
        for i in normal_segments:
            if skip_to is None:
                pass
            else:
                if i != skip_to:
                    continue
                else:
                    skip_to = None
                    continue

            text = i.text
            if re.search(news_pattern, text):
                for j in reversed_segments:
                    if i == j:
                        if i.start < 600:
                            news.append(News(None, i.end))
                            break

                        if segments[-1].end - i.end < 600:
                            news.append(News(i.start, None))
                            break

                    if re.search(news_pattern, j.text):
                        if j.start - i.start > 600:
                            continue

                        else:
                            news.append(News(i.start, j.end))
                            skip_to = j
                            break

        return news

    def find_jangles(self, segments: list[TextSegment], radio_name: str) -> list[int]:
        name = radio_name.split()
        if len(name) == 1:
            start_pattern = re.compile(r"(" + name[0][4:] + r"\w*)",
                                       re.IGNORECASE)
            end_part = None
        else:
            start_pattern = re.compile(r"(" + name[0][4:] + r"\w*)",
                                       re.IGNORECASE)
            end_part = re.compile(r"(" + name[1][4:] + r"\w*)",
                                  re.IGNORECASE)


        time_of_jangles = []

        for i, seg in enumerate(segments):
            text = seg.text.lower()

            if re.search(start_pattern, text):
                if end_part is not None:
                    if re.search(end_part, text):
                        time_of_jangles.append(seg.start)
                    if i + 1 >= len(segments):
                        continue
                    if re.search(end_part, segments[i + 1].text):
                        time_of_jangles.append(seg.start)
                else:
                    time_of_jangles.append(seg.start)

        return time_of_jangles

using System;
using System.Collections.Generic;
namespace AudioCaptureServer.DataBase.Models;

public class News
{
    public int? Start { get; set; }
    public int? End { get; set; }
}

public class TextSegment
{
    public string Text { get; set; }
    public int Start { get; set; }
    public int End { get; set; }
}

public class RadioSegment
{
    public string TrackName { get; set; }
    public int StartTime { get; set; }
    public int EndTime { get; set; }
    public string Text { get; set; }
    public List<TextSegment> TextSegments { get; set; }
}

public class RecordTranscription
{
    public string RadioName { get; set; }
    public string FileName { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public List<RadioSegment> Segments { get; set; }
    public List<News> News { get; set; }
    public List<int> Jingles { get; set; }
}

using Microsoft.EntityFrameworkCore;

namespace AudioCaptureServer.DataBase.Models;

[PrimaryKey("fileName")]
public class Audio
{
    public string? radioName { get; init; }
    public string fileName { get; init; }
    public string folderName { get; init; }
    public DateTime startRecording { get; init; }
    public DateTime endRecording { get; init; }
    
    public int status { get; init; }

    public Audio(string? radioName, string fileName, string folderName, DateTime startRecording, DateTime endRecording,int status)
    {
        this.radioName = radioName;
        this.fileName = fileName;
        this.folderName = folderName;
        this.startRecording = startRecording;
        this.endRecording = endRecording;
        this.status = status;
    }
}
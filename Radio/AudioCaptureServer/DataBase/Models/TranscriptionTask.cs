namespace AudioCaptureServer.DataBase.Models;

public class TranscriptionTask
{
    public string fileName { get; set; }
    public string folder { get; set; }
    public string radioName { get; set; }
    public DateTime start { get; set; }
    public DateTime end { get; set; }
    
    public TranscriptionTaskStatus status { get; set; }
}

public enum TranscriptionTaskStatus
{
    queuedForTranscription = 0,
    transcribed = 1,
    transcribing = 2,
        
    queuedForFingerprint = 10,
    fingerprinted = 11,
    fingerprinting = 12
}
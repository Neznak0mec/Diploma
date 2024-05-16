using System.Net;
using AudioCaptureServer.DataBase.Models;
using Serilog;

namespace AudioCaptureServer.AudioCapture;

public class RadioCapture
{
    private readonly Radio _radio;
    private readonly DataBase.MyDataBase _myDataBase;
    private bool _isRecording;

    public RadioCapture(Radio radio, DataBase.MyDataBase myDataBase)
    {
        _radio = radio;
        _myDataBase = myDataBase;
        _isRecording = false;
    }


    public async Task StartCapture()
    {
        Log.Information("RadioCapture {RadioName} start recording audio", _radio.name);
        _isRecording = true;
        CheckFolder();
        
        await Task.Run(async () => { await RecordAudio(); });
        
        Log.Information("RadioCapture {RadioName} started recording audio", _radio.name);
    }

    private async Task RecordAudio()
    {
        int recordingDurationInSeconds = 5 * 60;
        byte[] buffer = new byte[4096];
        int bytesRead;
        int totalBytesRead = 0;

        try
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(_radio.url);
            using HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            await using Stream stream = response.GetResponseStream();

            string fileType = "mp3";

            CheckFolder();

            try
            {
                while (true)
                {
                    while (_isRecording)
                    {
                        string fileName = $"{_radio.name}-{DateTime.Now:yyyy-MM-dd-HH-mm-ss}.{fileType}";

                        string outputFilePath =
                            $"records/{_radio.name}/{fileName}";

                        Log.Information($"start recording {fileName}");

                        DateTime startTime = DateTime.Now;
                        await using (FileStream outputFileStream = new FileStream(outputFilePath, FileMode.Create))
                        {
                            while ((bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length)) > 0)
                            {
                                await outputFileStream.WriteAsync(buffer, 0, bytesRead);
                                totalBytesRead += bytesRead;

                                TimeSpan elapsedTime = DateTime.Now - startTime;
                                if (elapsedTime.TotalSeconds >= recordingDurationInSeconds)
                                {
                                    break;
                                }
                            }
                        }

                        Log.Information("Recording {RadioName} completed. Total bytes read: {TotalBytesRead}", _radio.name,
                            totalBytesRead);

                        totalBytesRead = 0;

                        Audio audio = new Audio(_radio.name, fileName, _radio.name, startTime, DateTime.Now, 0);
                        _myDataBase.audioCollection.Insert(audio);
                    }

                    Thread.Sleep(100);
                }
                
            }
            catch (Exception ex)
            {
                Log.Error("An error occurred with radio {RadioName}: {ExMessage}", _radio.name, ex.Message);
            }
        }
        catch (Exception ex)
        {
            Log.Error("An error occurred with radio {RadioName}: {ExMessage}", _radio.name, ex.Message);
        }
    }

    private void CheckFolder()
    {
        string directory = $"records/{_radio.name}";
        if (!Directory.Exists(directory))
            Directory.CreateDirectory(directory);
    }
    
    public void ContinueCapture()
    {
        Log.Information("RadioCapture {RadioName} continue recording audio", _radio.name);
        _isRecording = true;
    }

    public void PauseCapture()
    {
        Log.Information("RadioCapture {RadioName} stop recording audio", _radio.name);
        _isRecording = false;
    }
    
    public bool IsRecording()
    {
        return _isRecording;
    }
}
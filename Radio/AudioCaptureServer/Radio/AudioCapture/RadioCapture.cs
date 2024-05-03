using System.Net;
using AudioCaptureServer.DataBase.Models;
using Serilog;

namespace AudioCaptureServer.AudioCapture;

public class RadioCapture
{
    private readonly Radio _radio;
    private readonly DataBase.MyDataBase _myDataBase;

    public RadioCapture(Radio radio, DataBase.MyDataBase myDataBase)
    {
        _radio = radio;
        _myDataBase = myDataBase;
    }


    public async Task StartCapture()
    {
        int recordingDurationInSeconds = 5 * 60;

        byte[] buffer = new byte[4096];
        int bytesRead;
        int totalBytesRead = 0;

        try
        {
            // connect to url and get stream
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(_radio.url);
            using HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            await using Stream stream = response.GetResponseStream();

            string fileType = "mp3";

            CheckFolder();

            try
            {
                // record stream
                while (true)
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
                    // _myDataBase.audioCollection.Insert(new Audio("-", _radio.name, "-", DateTime.Now, DateTime.Now,
                        // (int)TranscriptionTaskStatus.queuedForFingerprint));
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
}
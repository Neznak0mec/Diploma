using AudioCaptureServer.DataBase.Models;

namespace AudioCaptureServer.DataBase.Collections;

public class AudioCollection
{
    private string tableName;
    private MyDataBase connection;


    public AudioCollection(MyDataBase cs)
    {
        connection = cs;
    }

    public void Insert(Audio audio)
    {
        connection.Audios.Add(audio);
        connection.SaveChanges();
    }

    public List<Audio> GetAll(string? radioName = null)
    { 
        connection.Reload(connection.Audios);
        return connection.Audios.Where(x => x.radioName == radioName).ToList();
    }


    public Audio? GetLast(string radioName)
    {
        connection.Reload(connection.Audios);
        return connection.Audios.Where(x => x.radioName == radioName).MaxBy(x => x.endRecording);
    }

    
    public Audio? GetByName(string fileName)
    {
        connection.Reload(connection.Audios);
        return connection.Audios.Where(x => x.fileName == fileName).ToList().FirstOrDefault();
    }
    
}
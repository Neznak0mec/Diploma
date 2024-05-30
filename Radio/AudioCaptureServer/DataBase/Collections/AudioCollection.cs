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

    public List<Audio> GetAll(string? radioName = null,bool fingerptint = false)
    { 

        if (fingerptint)
            return connection.GetAudios().Where(x =>
                x.status == 10 ||
                x.status == 11 ||
                x.status == 20 ||
                x.status == 21).ToList();

        if (radioName == null)
            return connection.GetAudios().ToList();
        return connection.GetAudios().Where(x => x.radioName == radioName).ToList();
    }


    public Audio? GetLast(string radioName)
    {
        return connection.GetAudios().Where(x => x.radioName == radioName).MaxBy(x => x.endRecording);
    }

    
    public Audio? GetByName(string fileName)
    {
        return connection.GetAudios().Where(x => x.fileName == fileName).ToList().FirstOrDefault();
    }
    
}
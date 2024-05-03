using AudioCaptureServer.DataBase.Models;

namespace AudioCaptureServer.DataBase.Collections;

public class RadioCollection
{
    private readonly MyDataBase _db;
    
    public RadioCollection(MyDataBase cs)
    {
        _db = cs;
    }

    public void Insert(Radio radio)
    {
        _db.Radios.Add(radio);
        _db.SaveChanges();
    }

    public List<Radio> GetAll()
    {
        _db.Reload(_db.Radios);
        return _db.Radios.ToList();
    }

    public Radio? Get(string? name = null, string? url = null)
    {
        Radio? result;
        var radios = GetAll();

        IEnumerable<Radio>? temp = null;
        if (name != null)
        {
            temp = radios.Where(x => x.name == name);
        }

        if (url != null)
        {
            temp = temp != null ? 
                temp.Where(x => x.url == url) : radios.Where(x => x.url == url);
        }


        return temp?.ToList().FirstOrDefault();
    }
    
    public void Delete(string name)
    {
        Radio? radio = Get(name);
        if (radio == null) return;
        _db.Radios.Remove(radio);
        _db.SaveChanges();

    }
}
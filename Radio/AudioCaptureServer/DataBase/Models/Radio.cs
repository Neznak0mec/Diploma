using Microsoft.EntityFrameworkCore;

namespace AudioCaptureServer.DataBase.Models;

[PrimaryKey("name")]
public class Radio
{
    public string name { get; set; }
    
    public string url { get; init; }

    public Radio(string name, string url)
    {
        this.name = name;
        this.url = url;
    }
}
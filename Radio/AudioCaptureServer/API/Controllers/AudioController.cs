using AudioCaptureServer.DataBase;
using AudioCaptureServer.DataBase.Models;
using Microsoft.AspNetCore.Mvc;

namespace AudioCaptureServer.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AudioController : ControllerBase
{
    
    [ProducesResponseType(typeof(Audio),200)]
    [HttpGet("last/{radioName}")]
    public IActionResult GetLast(string radioName, [FromServices] DataBase.MyDataBase myDataBase)
    {
        Audio? audio = myDataBase.audioCollection.GetLast(radioName);

        if (audio == null)
        {
            return NotFound("Audio not found");
        }

        var filePath = $"records/{audio.folderName}/{audio.fileName}";

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound("File not found");
        }

        var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);

        return File(fileStream, "application/octet-stream", audio.fileName);
    }


    [ProducesResponseType(typeof(List<Audio>),200)]
    [HttpGet("all/{radioName?}/{limit:int?}")]
    // [HttpGet("all/{radioName}")]
    public IActionResult GetAll([FromServices] MyDataBase myDataBase, int? limit = null, string radioName = null)
    {
        var audios = myDataBase.audioCollection.GetAll(radioName);

        audios.Sort((x, y) => y.endRecording.CompareTo(x.endRecording));


        if (limit == null) return Ok(audios);

        if (audios.Count > limit)
        {
            audios = audios.GetRange(0, (int)limit);
        }

        return Ok(audios);
    }

    [ProducesResponseType(typeof(File),200)]
    [HttpGet("file/{fileName}")]
    public IActionResult GetFile(string fileName, [FromServices] DataBase.MyDataBase myDataBase)
    {
        var audio = myDataBase.audioCollection.GetByName(fileName);

        if (audio == null)
            return NotFound("File not found");

        var filePath = $"records/{audio.folderName}/{audio.fileName}";

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound("File not found");
        }

        var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);

        return File(fileStream, "application/octet-stream", audio.fileName);
    }
}
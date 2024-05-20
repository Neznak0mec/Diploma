using AudioCaptureServer.AudioCapture;
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
    
    
    [ProducesResponseType(200)]
    [HttpPost("pause/{radioName?}")]
    public IActionResult Pause([FromServices] RadioMaster radioMaster, string? radioName = null)
    {
        if (radioName == null)
        {
            radioMaster.PauseRadioCapture();
        }
        else
        {
            radioMaster.PauseRadioCapture(radioName);
        }

        return Ok();
    }

    [ProducesResponseType(200)]
    [HttpPost("continue/{radioName?}")]
    public IActionResult Continue([FromServices] RadioMaster radioMaster, string? radioName = null)
    {
        if (radioName == null)
        {
            radioMaster.ResumeRadioCapture();
        }
        else
        {
            radioMaster.ResumeRadioCapture(radioName);
        }

        return Ok();
    }
    
    [ProducesResponseType(typeof(Dictionary<string, bool>),200)]
    [HttpGet("status")]
    public IActionResult GetStatus([FromServices] RadioMaster radioMaster)
    {
        return Ok(radioMaster.GetStatus());
    }
    
    [ProducesResponseType(typeof(List<Audio>),200)]
    [HttpGet("search")]
    public IActionResult Search([FromServices] MyDataBase myDataBase, [FromQuery] string? radioName = null, [FromQuery] string? musicName = null, [FromQuery] string? text = null, [FromQuery] DateTime? startDate = null)
    {
        var audios = myDataBase.audioCollection.GetAll(radioName);

        if (startDate != null)
        {
            audios = audios.FindAll(x => x.startRecording.Date == startDate.Value.Date);
        }
        
        if (musicName != null)
        {
            var musics = myDataBase.recordTranscriptionCollection.GetByMusicName(musicName);
            audios = audios.SelectMany(x => musics.Contains(x.fileName) ? new List<Audio> {x} : new List<Audio>()).ToList();
        }
        
        if (text != null)
        {
            var texts = myDataBase.recordTranscriptionCollection.GetByText(text);
            audios = audios.SelectMany(x => texts.Contains(x.fileName) ? new List<Audio> {x} : new List<Audio>()).ToList();
        }
        
        return Ok(audios);
    }
    
    [ProducesResponseType(typeof(List<String>),200)]
    [HttpGet("musics")]
    public IActionResult GetMusics([FromServices] MyDataBase myDataBase)
    {
        return Ok(myDataBase.recordTranscriptionCollection.GetAllMusicNames());
    }
}
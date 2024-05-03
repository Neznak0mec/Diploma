using AudioCaptureServer.DataBase.Models;
using Microsoft.AspNetCore.Mvc;

namespace AudioCaptureServer.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TranscriptionController : ControllerBase
{
    [ProducesResponseType(typeof(RecordTranscription),200)]
    [HttpGet("{fileName}")]
    public IActionResult GetLast(string fileName, [FromServices] DataBase.MyDataBase myDataBase)
    {
        var audio = myDataBase.recordTranscriptionCollection.Get(fileName);

        if (audio == null)
        {
            return NotFound("Audio not found");
        }
        
        return Ok(audio);
    }
    
    [ProducesResponseType(typeof(TranscriptionTask),200)]
    [HttpGet("status/{fileName}")]
    public IActionResult Status(string fileName, [FromServices] DataBase.MyDataBase myDataBase)
    {
        var audio = myDataBase.audioCollection.GetByName(fileName);

        if (audio == null)
        {
            return NotFound("File not found");
        }
        
        return Ok(audio);
    }
}
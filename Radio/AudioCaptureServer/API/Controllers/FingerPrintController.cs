using AudioCaptureServer.DataBase.Models;
using Microsoft.AspNetCore.Mvc;

namespace AudioCaptureServer.API.Controllers;


[ApiController]
[Route("api/[controller]")]
public class FingerPrintController : ControllerBase {
    
    [ProducesResponseType(typeof(List<Audio>),200)]
    [HttpGet("all")]
    public IActionResult  GetAll([FromServices] DataBase.MyDataBase myDataBase)
    {
        var res =  myDataBase.audioCollection.GetAll(null);
        return Ok(res);
    }
    
    [ProducesResponseType(typeof(File),200)]
    [HttpGet("file/{fileName}")]
    public IActionResult GetFile(string fileName, [FromServices] DataBase.MyDataBase myDataBase)
    {
        var audio = myDataBase.audioCollection.GetByName(fileName);

        if (audio == null)
            return NotFound("File not found");

        var filePath = $"{audio.folderName}/{audio.fileName}";

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound("File not found");
        }

        var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);

        return File(fileStream, "application/octet-stream", audio.fileName);
    }
    
    [HttpPost]
    public async Task<ActionResult> PostFile(IFormFile file,string name,[FromServices] DataBase.MyDataBase myDataBase)
    {
        try
        {
            await WriteFile(file);

            Audio task = new(null,file.FileName,"FingerPrint",
                DateTime.Now,DateTime.Now,10);
            myDataBase.audioCollection.Insert(task);
            
            return Ok();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }
    
    private async Task WriteFile(IFormFile file)
    {
        try
        {
            var fileName = file.FileName;
            var fileFolder = Path.Combine(Directory.GetCurrentDirectory(),"FingerPrint");
            
            if(!Directory.Exists(fileFolder))
                Directory.CreateDirectory(fileFolder);
            
            var filePath = Path.Combine(fileFolder ,fileName);
            await using var stream = new FileStream(filePath, FileMode.Create);
            await file.CopyToAsync(stream);

        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }
}
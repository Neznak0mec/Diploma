using AudioCaptureServer.AudioCapture;
using AudioCaptureServer.DataBase.Models;
using Microsoft.AspNetCore.Mvc;

namespace AudioCaptureServer.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RadioController : ControllerBase
{

    [ProducesResponseType(typeof(Radio),200)]
    [HttpGet("{name?}")]
    public IActionResult Get([FromServices] DataBase.MyDataBase myDataBase,string? name = null)
    {
        if (name == null)
            return Ok(myDataBase.radioCollection.GetAll());
        
        var radio = myDataBase.radioCollection.Get(name: name);
        if (radio == null)
        {
            return NotFound();
        }
        return Ok(radio);
    }

    [HttpPost]
    public IActionResult AddRadio(Radio newRadio, [FromServices] DataBase.MyDataBase myDataBase, [FromServices] RadioMaster radioMaster)
    {
        myDataBase.radioCollection.Insert(newRadio);
        radioMaster.AddRadio(newRadio);
        
        return Ok();
    }
    
    [HttpDelete]
    public IActionResult Delete(string name, [FromServices] DataBase.MyDataBase myDataBase, [FromServices] RadioMaster radioMaster)
    {
        myDataBase.radioCollection.Delete(name);

        return Ok();
    }
}

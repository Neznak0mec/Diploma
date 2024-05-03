using AudioCaptureServer.DataBase.Models;
using Serilog;

namespace AudioCaptureServer.AudioCapture;

public class RadioMaster
{
    private List<Radio> _radios;
    private  DataBase.MyDataBase _myDataBase;
    
    public RadioMaster(DataBase.MyDataBase myDataBase)
    {
        Log.Information("RadioMaster created");

        _radios = new List<Radio>();
        this._myDataBase = myDataBase;
        LoadRadios();
    }

    public void Start()
    {
        Log.Information("RadioMaster start recording audio");
        StartAllRadios();
        Log.Information("RadioMaster started recording audio");
    }

    
    private void LoadRadios()
    {
        _radios = _myDataBase.radioCollection.GetAll();
    }

    private void StartAllRadios()
    {
        foreach (var radio in _radios)
        {
            StartRadioCapture(radio);
        }
    }

    public void AddRadio(Radio radio)
    {
        _radios.Add(radio);
        StartRadioCapture(radio);
        Log.Information("Recording {RadioRadioName} started", radio.name);
    }
    
    private void StartRadioCapture(Radio radio) => _ = Task.Run(async () =>
    {
         await new RadioCapture(radio, _myDataBase).StartCapture();
    });
}
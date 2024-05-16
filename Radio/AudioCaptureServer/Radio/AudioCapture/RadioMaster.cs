using AudioCaptureServer.DataBase.Models;
using Serilog;

namespace AudioCaptureServer.AudioCapture;

public class RadioMaster
{
    private List<Radio> _radios;
    private DataBase.MyDataBase _myDataBase;

    private Dictionary<string, RadioCapture> _radioCaptures;

    public RadioMaster(DataBase.MyDataBase myDataBase)
    {
        Log.Information("RadioMaster created");

        _radios = new List<Radio>();
        _radioCaptures = new Dictionary<string, RadioCapture>();
        _myDataBase = myDataBase;
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

    private void StartRadioCapture(Radio radio)
    {
        var radioCapture = new RadioCapture(radio, _myDataBase);
        _ = radioCapture.StartCapture();
        _radioCaptures[radio.name] = radioCapture;
    }

    public void PauseRadioCapture(string? radioName = null)
    {
        if (radioName == null)
        {
            foreach (var radioCapture in _radioCaptures)
            {
                radioCapture.Value.PauseCapture();
            }
        }
        else
        {
            if (_radioCaptures.ContainsKey(radioName))
            {
                _radioCaptures[radioName].PauseCapture();
            }
        }
    }
    
    
    public void ResumeRadioCapture(string? radioName = null)
    {
        if (radioName == null)
        {
            foreach (var radioCapture in _radioCaptures)
            {
                radioCapture.Value.ContinueCapture();
            }
        }
        else
        {
            if (_radioCaptures.ContainsKey(radioName))
            {
                _radioCaptures[radioName].ContinueCapture();
            }
        }
    }
    
    //get recording status
    public Dictionary<string, bool> GetStatus()
    {
        Dictionary<string, bool> status = new Dictionary<string, bool>();
        foreach (var radioCapture in _radioCaptures)
        {
            status[radioCapture.Key] = radioCapture.Value.IsRecording();
        }

        return status;
    }
    
}
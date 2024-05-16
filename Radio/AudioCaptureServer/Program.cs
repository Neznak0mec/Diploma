using AudioCaptureServer.AudioCapture;
using Serilog;

namespace AudioCaptureServer;

class Programm
{
    public static async Task Main(string[] args)
    {
        DataBase.MyDataBase myDataBase = new DataBase.MyDataBase();
        RadioMaster radioMaster = new RadioMaster(myDataBase);
        SetUpLogger();

        Task radioTask = Task.Run(() => RunRadio(myDataBase, radioMaster));
        Task apiTask = Task.Run(() => RunAPI(myDataBase, radioMaster));

        await Task.WhenAll(radioTask, apiTask);
    }

    static void RunRadio(DataBase.MyDataBase myDataBase, RadioMaster radioMaster)
    {
        //todo
          radioMaster.Start();
    }

    static void RunAPI(DataBase.MyDataBase myDataBase, RadioMaster radioMaster)
    {
        var builder = WebApplication.CreateBuilder();

        builder.Services.AddSingleton<DataBase.MyDataBase>(myDataBase);
        builder.Services.AddSingleton<RadioMaster>(radioMaster);

        builder.Logging.ClearProviders();
        builder.Logging.AddSerilog();

        builder.Services.AddRouting(options => options.LowercaseUrls = true);
        builder.Services.AddControllers();
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();

        var app = builder.Build();

        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        // app.UseHttpsRedirection();
        // app.UseAuthorization();

        app.MapControllers();

        app.Run();
    }

    static void SetUpLogger()
    {
        Log.Logger = new LoggerConfiguration()
            .MinimumLevel.Information()
            .Enrich.FromLogContext()
            .WriteTo.Console()
            .CreateLogger();
    }
}
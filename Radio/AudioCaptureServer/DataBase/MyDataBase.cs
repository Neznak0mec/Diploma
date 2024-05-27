using AudioCaptureServer.DataBase.Collections;
using AudioCaptureServer.DataBase.Models;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Serilog;

namespace AudioCaptureServer.DataBase;

public sealed class MyDataBase : DbContext
{
    public RadioCollection radioCollection { get; init; }
    public AudioCollection audioCollection { get; init; }

    public RecordTranscriptionCollection recordTranscriptionCollection { get; init; }

    public DbSet<Audio> Audios { get; set; } = null!;
    public DbSet<Radio> Radios { get; set; } = null!;

    public void Reload<T>(T entity) where T : class
    {
        try
        {
            Entry(entity).Reload();
        }
        catch (Exception e)
        {
            Log.Error(e.Message);
        }
    }

    public MyDataBase()
    {
        Database.EnsureCreated();

        radioCollection = new RadioCollection(this);
        audioCollection = new AudioCollection(this);


        NpgsqlConnection connection;
        try
        {
            connection =
                new NpgsqlConnection("Host=postgres;Port=5432;Database=radio;Username=user;Password=password");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }

        connection.Open();
        recordTranscriptionCollection = new RecordTranscriptionCollection(connection);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Audio>().ToTable("Audios");
        modelBuilder.Entity<Radio>().ToTable("Radios");
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
        optionsBuilder.UseNpgsql("Host=postgres;Port=5432;Database=radio;Username=user;Password=password");
    }
}

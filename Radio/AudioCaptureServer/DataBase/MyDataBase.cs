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

    public DbSet<Audio> Audios { get; set; } 
    public DbSet<Radio> Radios { get; set; } 

    private const string ConnectionString = "Host=89.110.91.74;Port=5432;Database=radio;Username=megaUserToNotBeHacked;Password=thisPasswordIsNeverGoingToBeHacked";

    public MyDataBase()
    {
        Database.EnsureCreated();

        radioCollection = new RadioCollection(this);
        audioCollection = new AudioCollection(this);

        NpgsqlConnection connection;
        try
        {
            connection = new NpgsqlConnection(ConnectionString);
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
        optionsBuilder.UseNpgsql(ConnectionString);
    }

    public IQueryable<Audio> GetAudios()
    {
        return Audios.AsNoTracking();
    }

    public IQueryable<Radio> GetRadios()
    {
        return Radios.AsNoTracking();
    }
}
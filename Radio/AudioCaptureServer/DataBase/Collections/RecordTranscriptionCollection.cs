using AudioCaptureServer.DataBase.Models;
using Npgsql;

namespace AudioCaptureServer.DataBase.Collections;

public class RecordTranscriptionCollection
{
    private readonly NpgsqlConnection _connection;

    public RecordTranscriptionCollection(NpgsqlConnection connection)
    {
        _connection = connection;
    }

    public void Dispose()
    {
        _connection.Close();
    }


    public RecordTranscription? Get(string filename)
    {
        RecordTranscription recordTranscription;
        int recordId;
        using (var command = _connection.CreateCommand())
        {
            command.CommandText = $"SELECT * FROM radio_data WHERE file_name = @filename LIMIT 1;";
            command.Parameters.AddWithValue("filename", filename);

            using (var results = command.ExecuteReader())
            {
                if (!results.Read()) return null;
                recordId = (int)results["id"];
                recordTranscription = new RecordTranscription
                {
                    RadioName = (string)results["radio_name"],
                    FileName = (string)results["file_name"],
                    StartTime = (DateTime)results["start_time"],
                    EndTime = (DateTime)results["end_time"],
                    Segments = new List<RadioSegment>(),
                    News = new List<News>(),
                    Jingles = new List<int>()
                };
            }
        }


        Dictionary<int, RadioSegment> radioSegmentsDictionary = new Dictionary<int, RadioSegment>();
        using (var cursor = _connection.CreateCommand())
        {
            // Get the segments for this record
            cursor.CommandText = $"SELECT * FROM segments WHERE radio_data_id = @recordId";
            cursor.Parameters.AddWithValue("recordId", recordId);
            NpgsqlDataReader results = cursor.ExecuteReader();
            while (results.Read())
            {
                var segment = new RadioSegment
                {
                    Text = (string)results["text"],
                    TrackName = (string)results["track_name"],
                    StartTime = (int)results["start_time"],
                    EndTime = (int)results["end_time"],
                    TextSegments = new List<TextSegment>()
                };
                radioSegmentsDictionary.Add((int)results["id"], segment);
            }

            results.Close();
        }

        foreach (var s in radioSegmentsDictionary)
        {
            using (var cursor = _connection.CreateCommand())
            {
                RadioSegment segment = s.Value;
                cursor.CommandText = $"SELECT * FROM text_segments WHERE segment_id = @Key;";
                cursor.Parameters.AddWithValue("Key", s.Key);

                NpgsqlDataReader results = cursor.ExecuteReader();
                while (results.Read())
                {
                    segment.TextSegments.Add(new TextSegment()
                    {
                        Text = (string)results["text"],
                        Start = (int)results["start"],
                        End = (int)results["end"]
                    });
                }

                recordTranscription.Segments.Add(segment);
                results.Close();
            }
        }


        using (var cursor = _connection.CreateCommand())
        {
            cursor.CommandText = $"SELECT * FROM news WHERE radio_data_id = @recordId;";
            cursor.Parameters.AddWithValue("recordId", recordId);
            NpgsqlDataReader results = cursor.ExecuteReader();
            while (results.Read())
            {
                int? start, end;
                try
                {
                    start = (int)results["start"];
                }
                catch (Exception)
                {
                    start = null;
                }
                try
                {
                    end = (int)results["end"];
                }
                catch (Exception)
                {
                    end = null;
                }
                recordTranscription.News.Add(new News()
                {
                    Start = start,
                    End = end
                });
            }

            results.Close();
        }

        using (var cursor = _connection.CreateCommand())
        {
            // Get the jingle IDs for this record
            cursor.CommandText = $"SELECT time FROM jingles WHERE radio_data_id = @recordId;";
            cursor.Parameters.AddWithValue("recordId", recordId);
            NpgsqlDataReader results = cursor.ExecuteReader();
            while (results.Read())
            {
                recordTranscription.Jingles.Add((int)results["time"]);
            }

            results.Close();
        }

        return recordTranscription;
    }

    public List<string> GetByMusicName(string musicName)
    {
        List<string> result = new List<string>();
        List<int> segments_ids = new List<int>(); 
        using (var command = _connection.CreateCommand())
        {
            command.CommandText = $"SELECT id FROM segments WHERE lower(track_name) LIKE '%' || lower(@musicName) || '%';";
            command.Parameters.AddWithValue("musicName", musicName);
            
            using (var results = command.ExecuteReader())
            {
                while (results.Read())
                {
                    segments_ids.Add((int)results["id"]);
                }
            }; 
        }
        
        foreach (var id in segments_ids)
        {
            using (var command = _connection.CreateCommand())
            {
                command.CommandText = $"SELECT file_name FROM radio_data WHERE id = @id;";
                command.Parameters.AddWithValue("id", id);
                
                using (var results = command.ExecuteReader())
                {
                    while (results.Read())
                    {
                        result.Add((string)results["file_name"]);
                    }
                }
            }
        }
        return result;
    }
    
    public List<string> GetByText(string text)
    {
        List<string> result = new List<string>();
        List<int> segments_ids = new List<int>(); 
        using (var command = _connection.CreateCommand())
        {
            command.CommandText = $"SELECT id FROM segments WHERE lower(text) LIKE '%' || lower(@text) || '%';";
            command.Parameters.AddWithValue("text", text);
            
            using (var results = command.ExecuteReader())
            {
                while (results.Read())
                {
                    segments_ids.Add((int)results["id"]);
                }
            }; 
        }
        
        foreach (var id in segments_ids)
        {
            using (var command = _connection.CreateCommand())
            {
                command.CommandText = $"SELECT file_name FROM radio_data WHERE id = @id;";
                command.Parameters.AddWithValue("id", id);
                
                using (var results = command.ExecuteReader())
                {
                    while (results.Read())
                    {
                        result.Add((string)results["file_name"]);
                    }
                }
            }
        }
        return result;
    }
    
    public List<string> GetAllMusicNames()
    {
        List<string> result = new List<string>();
        using (var command = _connection.CreateCommand())
        {
            command.CommandText = $"SELECT track_name FROM segments;";
            
            using (var results = command.ExecuteReader())
            {
                while (results.Read())
                {
                    result.Add((string)results["track_name"]);
                }
            }; 
        }
        
        result = result.Distinct().ToList();
        
        return result;
    }
}
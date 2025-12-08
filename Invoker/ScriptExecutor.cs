using System.Diagnostics;
using Google.Protobuf;
using Steffen70.Invoker.Common;

namespace Steffen70.Invoker;

public class ScriptExecutor(ILogger<ScriptExecutor> logger)
{
    private readonly string _scriptRootPath = Path.Combine(AppContext.BaseDirectory, "script_root");

    public async Task<DemoScriptResult> ExecuteAsync(string scriptName, DemoScriptContext context)
    {
        var contextFile = Path.Combine(Path.GetTempPath(), $"ctx_{Guid.NewGuid()}.pb");
        var responseFile = Path.Combine(Path.GetTempPath(), $"resp_{Guid.NewGuid()}.pb");

        try
        {
            // Write context to temp file
            var contextBytes = context.ToByteArray();
            await File.WriteAllBytesAsync(contextFile, contextBytes);

            // Spawn process with pipenv
            var psi = new ProcessStartInfo
            {
                FileName = "pipenv",
                Arguments = $"run python {scriptName} --context {contextFile} --response {responseFile}",
                WorkingDirectory = _scriptRootPath,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            logger.LogInformation($"Executing script: {scriptName}");
            using var process = Process.Start(psi) ?? throw new("Failed to start process");

            // Wait for process with timeout
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
            try
            {
                await process.WaitForExitAsync(cts.Token);
            }
            catch (OperationCanceledException)
            {
                process.Kill();
                throw new TimeoutException("Script execution exceeded 30s timeout");
            }

            // Check exit code
            if (process.ExitCode != 0)
            {
                var stderr = await process.StandardError.ReadToEndAsync(cts.Token);
                throw new($"Script failed with exit code {process.ExitCode}: {stderr}");
            }

            // Read response from file
            if (!File.Exists(responseFile))
                throw new("Script did not produce response file");

            var responseBytes = await File.ReadAllBytesAsync(responseFile, cts.Token);
            var result = DemoScriptResult.Parser.ParseFrom(responseBytes);

            return result;
        }
        catch (Exception ex)
        {
            logger.LogError(ex, $"Error executing script {scriptName}");
            return new() { Exception = ex.Message };
        }
        finally
        {
            // Clean up temp files
            try
            {
                File.Delete(contextFile);
            }
            catch
            {
                // ignored
            }

            try
            {
                File.Delete(responseFile);
            }
            catch
            {
                // ignored
            }
        }
    }
}

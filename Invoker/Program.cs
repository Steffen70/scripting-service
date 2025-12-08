using System.Security.Cryptography.X509Certificates;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Steffen70.Invoker.Extensions;

namespace Steffen70.Invoker;

public class Program
{
    private const string ApiPortEnvironmentVariable = "API_PORT";

    private const string CorsPolicyName = "ClientPolicy";

    public static void Main(string[] args)
    {
        // Working directory is not always the same as the executable directory - base directory is more reliable
        var basePath = Path.Combine(AppContext.BaseDirectory, "cert");

        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddLogging(loggingBuilder =>
        {
            loggingBuilder.AddConsole();
            // loggingBuilder.AddFilter("Microsoft.AspNetCore", LogLevel.Warning);
        });

#if RELEASE
        // Get the API port from the environment variable
        var apiPort = int.Parse(Environment.GetEnvironmentVariable(ApiPortEnvironmentVariable) ?? throw new InvalidOperationException($"'{ApiPortEnvironmentVariable}' environment variable not set."));
#elif DEBUG
        // Don't require the API_PORT environment variable in DEBUG mode
        const int apiPort = 8445;
#endif

        // Configure the Kestrel server with the certificate and the API port
        builder.WebHost.ConfigureKestrel(options => options.ListenLocalhost(apiPort, listenOptions =>
        {
            var pfxFile = Path.Combine(basePath, "localhost.pfx");
            var logger = listenOptions.ApplicationServices.GetRequiredService<ILogger<Program>>();
            logger.LogInformation($"Using certificate from '{pfxFile}'.");

            listenOptions.UseHttps(new X509Certificate2(pfxFile, ""));
            // Enable HTTP/2 and HTTP/1.1 for gRPC-Web compatibility
            // listenOptions.Protocols = HttpProtocols.Http1AndHttp2;
            listenOptions.Protocols = HttpProtocols.Http2;
        }));

        // Allow all origins
        builder.Services.AddCors(o => o.AddPolicy(CorsPolicyName, policyBuilder =>
        {
            policyBuilder
                // Allow all ports on localhost
                .SetIsOriginAllowed(origin => new Uri(origin).Host == "localhost")
                // Allow all methods and headers
                .AllowAnyMethod()
                .AllowAnyHeader();
            // Expose the gRPC-Web headers
            // .WithExposedHeaders("Grpc-Status", "Grpc-Message", "Grpc-Encoding", "Grpc-Accept-Encoding");
        }));

        builder.Services.AddGrpc();

        var app = builder.Build();

        // Configure the HTTP request pipeline.

        // Enable the HTTPS redirection - only use HTTPS
        app.UseHttpsRedirection();

        // Enable CORS - allow all origins and add gRPC-Web headers
        app.UseCors(CorsPolicyName);

        // Enable gRPC-Web for all services
        // app.UseGrpcWeb(new() { DefaultEnabled = true });

        // Add all services in the GrpcServices namespace
        app.MapGrpcServices();

        app.Run();
    }
}

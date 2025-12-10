using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Steffen70.Invoker.Common;

namespace Steffen70.Invoker.GrpcServices;

public class InvokerService(ScriptExecutor executor, ILogger<InvokerService> logger) : Invoker.InvokerBase
{
    public override Task<Empty> Ping(Empty request, ServerCallContext context) => Task.FromResult(new Empty());

    public override async Task<DemoScriptResult> InvokeScript(InvokeRequest request, ServerCallContext context)
    {
        var result = await executor.ExecuteAsync(request.ScriptName, request.Context);

        if (!string.IsNullOrEmpty(result.Exception))
        {
            logger.LogError($"Script error: {result.Exception}");
        }

        return result;
    }
}

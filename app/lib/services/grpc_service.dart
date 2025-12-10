import "dart:convert";

import "package:app/app.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:grpc/grpc.dart";
import "package:protobuf/well_known_types/google/protobuf/empty.pb.dart";

class GrpcService {
  late InvokerClient _invokerStub;
  late ClientChannel _channel;
  bool _initialized = false;

  Future<void> initialize({final String host = "localhost", final int port = 8445}) async {
    if (_initialized) return;

    try {
      // Load root CA certificate
      final certPem = await rootBundle.loadString("assets/cert/root_ca.crt");

      // Convert PEM string to bytes
      final certificateBytes = utf8.encode(certPem);

      // Create TLS credentials with custom cert
      // Certificate validation is strict - mismatched certs will throw
      final credentials = ChannelCredentials.secure(certificates: certificateBytes);

      // Create gRPC channel
      _channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(credentials: credentials),
      );

      // Create service stub
      _invokerStub = InvokerClient(_channel);
      _initialized = true;

      Get.log("gRPC initialized: $host:$port");
    } catch (e) {
      Get.log("gRPC initialization failed: $e");
      rethrow;
    }
  }

  /// Performs a ping to check server connectivity
  /// Returns true if server is reachable, false otherwise
  Future<bool> ping() async {
    if (!_initialized) {
      Get.log("gRPC not initialized. Call initialize() first.");

      return false;
    }

    try {
      // Call ping with proper CallOptions
      await _invokerStub.ping(Empty(), options: CallOptions(timeout: const Duration(seconds: 5)));

      return true;
    } on GrpcError catch (e) {
      Get.log("gRPC ping error (${e.code}): ${e.message}");

      return false;
    } catch (e) {
      Get.log("gRPC ping failed: $e");

      return false;
    }
  }

  Future<DemoScriptResult> invokeScript(final String scriptName, final String inputData) async {
    if (!_initialized) {
      throw Exception("gRPC not initialized. Call initialize() first.");
    }

    try {
      final request = InvokeRequest(
        scriptName: scriptName,
        context: DemoScriptContext(inputData: inputData),
      );

      final response = await _invokerStub.invokeScript(request);
      return response;
    } on GrpcError catch (e) {
      throw Exception("gRPC error (${e.code}): ${e.message}");
    } catch (e) {
      throw Exception("Failed to invoke script: $e");
    }
  }

  void dispose() {
    _channel.terminate();
    _initialized = false;
  }
}

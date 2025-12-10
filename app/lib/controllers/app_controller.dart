import "dart:async";

import "package:app/app.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class AppController extends GetxController with WidgetsBindingObserver {
  final grpcService = GrpcService();

  // Reactive state
  final inputData = "".obs;
  final outputData = "".obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;
  final isConnected = false.obs;

  // Track if we need to ping (only on resume, not on init)
  bool _shouldPingOnResume = false;
  Timer? _pingTimer;

  @override
  void onInit() {
    super.onInit();

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize gRPC
    _initializeGrpc();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App came to foreground - perform ping
      if (_shouldPingOnResume) {
        Get.log("App resumed - performing ping");
        _performPing();
      }

      _shouldPingOnResume = true;
    } else if (state == AppLifecycleState.paused) {
      // App went to background - stop pinging
      Get.log("App paused - stopping ping timer");
      _pingTimer?.cancel();
      _shouldPingOnResume = true;
    }
  }

  Future<void> _initializeGrpc() async {
    try {
      await grpcService.initialize(host: "localhost", port: 8445);
      Get.log("gRPC connection initialized");

      // First ping after init
      await _performPing();
    } catch (e) {
      Get.log("gRPC initialization failed: $e");
      isConnected.value = false;
      errorMessage.value = '${'error_initialization'.tr}$e';
    }
  }

  /// Performs a single ping and updates connection status
  Future<void> _performPing() async {
    try {
      final isReachable = await grpcService.ping();

      isConnected.value = isReachable;

      if (isReachable) {
        Get.log("Ping successful - server connected");
        errorMessage.value = "";
      } else {
        Get.log("Ping failed - server unreachable");
        errorMessage.value = "error_connection_refused".tr;
      }
    } catch (e) {
      Get.log("Ping exception: $e");
      isConnected.value = false;
      errorMessage.value = '${'error_prefix'.tr}$e';
    }
  }

  /// Manually refresh connection status
  Future<void> refreshConnection() async {
    Get.log("Manual refresh triggered");
    await _performPing();
  }

  Future<void> invokeScript() async {
    if (!isConnected.value) {
      errorMessage.value = "error_not_connected".tr;
      return;
    }

    if (inputData.isEmpty) {
      errorMessage.value = "error_empty_input".tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";
    outputData.value = "";

    try {
      final result = await grpcService.invokeScript("test_script.py", inputData.value);

      if (result.exception.isNotEmpty) {
        errorMessage.value = '${'error_script_failed'.tr}\n${result.exception}';
        outputData.value = "";
      } else {
        outputData.value = result.outputData;
        errorMessage.value = "";
      }
    } catch (e) {
      errorMessage.value = '${'error_prefix'.tr}$e';
      outputData.value = "";
    } finally {
      isLoading.value = false;
    }
  }

  void clearAll() {
    inputData.value = "";
    outputData.value = "";
    errorMessage.value = "";
  }

  @override
  void onClose() {
    _pingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    grpcService.dispose();
    super.onClose();
  }
}

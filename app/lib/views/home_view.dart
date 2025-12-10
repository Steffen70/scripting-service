import "package:app/app.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late TextEditingController _inputController;
  late AppController _appController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _appController = Get.put(AppController());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleClearAll() {
    _inputController.clear();
    _appController.clearAll();
  }

  @override
  Widget build(final BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final maxWidth = isMobile ? double.infinity : 600.0;

    return Scaffold(
      appBar: AppBar(title: Text("app_title".tr), centerTitle: true, elevation: 2, actions: [_LanguageSwitcher(), const SizedBox(width: 16)]),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text("app_subtitle".tr, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Connection status card
                Obx(() => _ConnectionStatusCard(isConnected: _appController.isConnected.value, onRefresh: _appController.refreshConnection)),

                const SizedBox(height: 24),

                // Input label
                Text("input_label".tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),

                const SizedBox(height: 8),

                // Input field
                Obx(
                  () => TextField(
                    enabled: _appController.isConnected.value && !_appController.isLoading.value,
                    controller: _inputController,
                    onChanged: (final value) => _appController.inputData.value = value,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "input_hint".tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons row (Invoke + Clear)
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _appController.isConnected.value && !_appController.isLoading.value ? _appController.invokeScript : null,
                          icon: _appController.isLoading.value
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                              : const Icon(Icons.send),
                          label: Text(_appController.isLoading.value ? "invoking".tr : "invoke_script".tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: !_appController.isLoading.value ? _handleClearAll : null,
                        icon: const Icon(Icons.delete_outline),
                        label: Text("clear_all".tr),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black87),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Error message
                Obx(
                  () => _appController.errorMessage.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_appController.errorMessage.value, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Output label
                Text("output_label".tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),

                const SizedBox(height: 8),

                // Output display
                Obx(
                  () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: _appController.outputData.isEmpty ? Colors.grey[300]! : Theme.of(context).primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Text(_appController.outputData.isEmpty ? "output_placeholder".tr : _appController.outputData.value, style: const TextStyle(fontFamily: "monospace", fontSize: 12)),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onRefresh;

  const _ConnectionStatusCard({required this.isConnected, required this.onRefresh});

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[50] : Colors.red[50],
        border: Border.all(color: isConnected ? Colors.green[300]! : Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(isConnected ? Icons.check_circle : Icons.error_outline, color: isConnected ? Colors.green[700] : Colors.red[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? "connected".tr : "disconnected".tr,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isConnected ? Colors.green[700] : Colors.red[700]),
                ),
                if (!isConnected) Text("error_connection_refused".tr, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, size: 16), padding: const EdgeInsets.all(4), constraints: const BoxConstraints(), tooltip: "refresh_connection".tr),
        ],
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (final String lang) {
        if (lang == "de") {
          Get.updateLocale(const Locale("de", "DE"));
        } else {
          Get.updateLocale(const Locale("en", "US"));
        }
      },
      itemBuilder: (final BuildContext context) => [PopupMenuItem<String>(value: "en", child: const Text("English")), PopupMenuItem<String>(value: "de", child: const Text("Deutsch"))],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.language, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

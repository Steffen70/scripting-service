import "package:get/get.dart";

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "en_US": {
      // App title and general
      "app_title": "Scripting Demo",
      "app_subtitle": "Invoke Python Script",

      // Connection status
      "connected": "Connected to localhost:8445",
      "connecting": "Connecting to server...",
      "disconnected": "Disconnected from server",

      // Form labels
      "input_label": "Input Data",
      "input_hint": "Enter input data for the script",
      "output_label": "Output",
      "output_placeholder": "No result yet",

      // Buttons
      "invoke_script": "Invoke Script",
      "invoking": "Invoking...",
      "clear_all": "Clear All",
      "refresh": "Refresh",

      // Error messages
      "error_title": "Error",
      "error_not_connected": "Not connected to server",
      "error_empty_input": "Please enter input data",
      "error_script_failed": "Script Error:",
      "error_prefix": "Error: ",
      "error_initialization": "Failed to initialize: ",
      "error_connection_refused": "Connection refused. Is the server running?",

      // Success messages
      "success_executed": "Script executed successfully",
    },
    "de_DE": {
      // App title and general
      "app_title": "Scripting-Demo",
      "app_subtitle": "Python-Skript ausführen",

      // Connection status
      "connected": "Mit localhost:8445 verbunden",
      "connecting": "Verbindung zum Server wird hergestellt...",
      "disconnected": "Vom Server getrennt",

      // Form labels
      "input_label": "Eingabedaten",
      "input_hint": "Eingabedaten für das Skript eingeben",
      "output_label": "Ausgabe",
      "output_placeholder": "Noch kein Ergebnis",

      // Buttons
      "invoke_script": "Skript ausführen",
      "invoking": "Wird ausgeführt...",
      "clear_all": "Alle löschen",
      "refresh": "Aktualisieren",

      // Error messages
      "error_title": "Fehler",
      "error_not_connected": "Nicht mit dem Server verbunden",
      "error_empty_input": "Bitte Eingabedaten eingeben",
      "error_script_failed": "Skriptfehler:",
      "error_prefix": "Fehler: ",
      "error_initialization": "Initialisierung fehlgeschlagen: ",
      "error_connection_refused": "Verbindung abgelehnt. Läuft der Server?",

      // Success messages
      "success_executed": "Skript erfolgreich ausgeführt",
    },
  };
}

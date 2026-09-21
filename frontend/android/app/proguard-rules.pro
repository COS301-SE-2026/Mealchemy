# Preserve generic signatures used when scheduled notifications are restored.
-keepattributes Signature

# Gson creates these adapters reflectively for persisted notification details.
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Scheduled notification receivers are invoked by Android, not directly by Dart.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

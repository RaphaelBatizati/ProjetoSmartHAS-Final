
# Notificações Locais

Este projeto inclui scaffold para **flutter_local_notifications**.
Passos resumidos (Android):
1. No `AndroidManifest.xml`, certifique permissões conforme docs do plugin.
2. Inicialize o plugin em `main.dart` (já incluído).
3. Teste `scheduleDailyReminder()` no app.

iOS:
- Configure permissões no `Info.plist`.
- Solicite autorização de notificações na inicialização (já incluído o stub).

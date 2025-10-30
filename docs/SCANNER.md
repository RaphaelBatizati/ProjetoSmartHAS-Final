
# Leitor de Barras (mobile_scanner)

Este projeto usa `mobile_scanner` para ler códigos de barras/QR.

## Android
- Normalmente, o plugin já injeta a permissão de câmera. Se necessário, adicione manualmente em `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.CAMERA"/>
  ```

## iOS
- Adicione as chaves no `Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Precisamos usar a câmera para ler códigos de barras.</string>
  ```

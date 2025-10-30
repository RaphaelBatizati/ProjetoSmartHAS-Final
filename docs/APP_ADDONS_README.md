
# Add-ons do App: Chat (WhatsApp-like) + Perfil de Dieta

## Backend (Spring)
1. Aplique o SQL:
   - `db/sql/08_user_profile.sql`
2. Novos endpoints:
   - `POST /api/profile/upsert` — cria/atualiza perfil
   - `GET  /api/profile/{userId}` — busca perfil
   - `POST /api/diet/calc` — cálculo estimado de BMR (kcal/dia)

## Mobile (Flutter)
- Adicione os arquivos em `mobile/flutter/lib/`:
  - `services/api_client.dart`
  - `widgets/whatsapp_chat_button.dart`
  - `screens/chat_screen.dart`
  - `screens/profile_screen.dart`
  - (opcional) `main_sample.dart` para testar rotas e FAB
- Configure `ApiClient.baseUrl` para apontar ao seu backend.

O botão flutuante verde simula o ícone WhatsApp e abre o chat interno (conectado ao `/api/ai/chat`). 
Você pode também adicionar um "deep link" para WhatsApp real, se tiver integração via webhook.

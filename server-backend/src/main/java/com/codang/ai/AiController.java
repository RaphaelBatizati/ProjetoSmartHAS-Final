package com.codang.ai;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    @Value("${openai.api.key:}")
    private String openAiKey;

    private final ObjectMapper mapper = new ObjectMapper();

    @PostMapping(path = "/chat", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> chat(@RequestBody Map<String, Object> payload) {
        String prompt = String.valueOf(payload.getOrDefault("prompt", "Explique o objetivo do Smart HAS."));
        try {
            if (openAiKey == null || openAiKey.isBlank()) {
                // Fallback simulado
                return ResponseEntity.ok(Map.of(
                        "model", "simulado",
                        "answer", "Resposta simulada: " + prompt + " [sem chave OPENAI_API_KEY configurada]."
                ));
            }
            // Exemplo usando OpenAI Chat Completions (compatível)
            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(20)).build();
            String body = mapper.writeValueAsString(Map.of(
                    "model", "gpt-4o-mini",
                    "messages", new Object[]{
                        Map.of("role", "system", "content", "Você é um assistente do Smart HAS."),
                        Map.of("role", "user", "content", prompt)
                    }
            ));
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                    .header("Authorization", "Bearer " + openAiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            return ResponseEntity.ok(mapper.readValue(resp.body(), Map.class));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        } catch (java.io.IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping(path = "/report/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> generateReport(@PathVariable("userId") Long userId) {
        // Exemplo de geração de relatório em linguagem natural
        String summary = String.format(
                "Relatório automático para usuário %d: consumo médio dos últimos 7 dias, "
                + "alertas críticos reduzidos em 12%%, recomendações: ajustar limites de temperatura e revisar picos de potência entre 18h-22h.",
                userId
        );
        return ResponseEntity.ok(Map.of("userId", userId, "report", summary));
    }
}

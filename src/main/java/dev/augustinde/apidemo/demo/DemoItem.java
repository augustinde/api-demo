package dev.augustinde.apidemo.demo;

import java.time.OffsetDateTime;

/**
 * Ligne de la table {@code demo}, créée par le seed CloudNativePG du cluster k3s :
 * {@code id bigserial, label text, created_at timestamptz}.
 */
public record DemoItem(Long id, String label, OffsetDateTime createdAt) {
}

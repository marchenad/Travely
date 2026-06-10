package com.example.travely.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseMigrationRunner implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(ApplicationArguments args) {
        // Drop old columns that no longer exist in the entity (from the original schema)
        applyIfExists("ALTER TABLE trips DROP COLUMN IF EXISTS price",          "trips: drop old price column");
        applyIfExists("ALTER TABLE trips DROP COLUMN IF EXISTS destination_id", "trips: drop old destination_id FK");
        applyIfExists("DROP TABLE IF EXISTS destinations",                      "drop orphaned destinations table");

        // Make nullable columns that were NOT NULL in the old schema
        applyIfExists("ALTER TABLE trips ALTER COLUMN end_date DROP NOT NULL",   "trips.end_date → nullable");
        applyIfExists("ALTER TABLE trips ALTER COLUMN start_date DROP NOT NULL", "trips.start_date → nullable");

        // Add navigationVersion column for invite deduplication
        applyIfExists(
            "ALTER TABLE trips ADD COLUMN IF NOT EXISTS navigation_version INT NOT NULL DEFAULT 0",
            "trips: add navigation_version column"
        );

        // Create chat_messages table
        applyIfExists(
            "CREATE TABLE IF NOT EXISTS chat_messages (" +
            "  id         BIGSERIAL PRIMARY KEY," +
            "  trip_id    BIGINT NOT NULL REFERENCES trips(id) ON DELETE CASCADE," +
            "  sender_id  BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE," +
            "  content    VARCHAR(500) NOT NULL," +
            "  sent_at    TIMESTAMP NOT NULL" +
            ")",
            "create chat_messages table"
        );
        applyIfExists(
            "CREATE INDEX IF NOT EXISTS idx_cm_trip_sent_at ON chat_messages(trip_id, sent_at)",
            "chat_messages: index on trip_id, sent_at"
        );

        // Add NAVIGATING to the status check constraint
        applyIfExists(
            "ALTER TABLE trips DROP CONSTRAINT IF EXISTS trips_status_check",
            "trips: drop old status check constraint"
        );
        applyIfExists(
            "ALTER TABLE trips ADD CONSTRAINT trips_status_check CHECK (status IN ('PLANNED','ACTIVE','NAVIGATING','COMPLETED','CANCELLED'))",
            "trips: add NAVIGATING to status check constraint"
        );
    }

    private void applyIfExists(String sql, String description) {
        try {
            jdbcTemplate.execute(sql);
            log.info("Schema fix applied: {}", description);
        } catch (Exception e) {
            log.debug("Schema fix skipped (already applied or not needed): {}", description);
        }
    }
}

package dev.augustinde.apidemo.demo;

import java.time.OffsetDateTime;
import java.util.List;

import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

@Repository
public class DemoRepository {

    private final JdbcClient jdbcClient;

    public DemoRepository(JdbcClient jdbcClient) {
        this.jdbcClient = jdbcClient;
    }

    public List<DemoItem> findAll() {
        return jdbcClient.sql("SELECT id, label, created_at FROM demo ORDER BY id")
                .query((rs, rowNum) -> new DemoItem(
                        rs.getLong("id"),
                        rs.getString("label"),
                        rs.getObject("created_at", OffsetDateTime.class)))
                .list();
    }
}

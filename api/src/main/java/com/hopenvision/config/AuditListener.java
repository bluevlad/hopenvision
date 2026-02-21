package com.hopenvision.config;

import jakarta.persistence.*;
import lombok.extern.slf4j.Slf4j;

/**
 * JPA Entity 감사 로깅 리스너
 * Entity CRUD 이벤트를 감지하여 로깅합니다.
 */
@Slf4j
public class AuditListener {

    @PostPersist
    public void onPostPersist(Object entity) {
        log.info("[AUDIT] CREATE entity={} id={}", entity.getClass().getSimpleName(), getEntityId(entity));
    }

    @PostUpdate
    public void onPostUpdate(Object entity) {
        log.info("[AUDIT] UPDATE entity={} id={}", entity.getClass().getSimpleName(), getEntityId(entity));
    }

    @PostRemove
    public void onPostRemove(Object entity) {
        log.info("[AUDIT] DELETE entity={} id={}", entity.getClass().getSimpleName(), getEntityId(entity));
    }

    private String getEntityId(Object entity) {
        try {
            var idField = findIdField(entity.getClass());
            if (idField != null) {
                idField.setAccessible(true);
                Object id = idField.get(entity);
                return id != null ? id.toString() : "null";
            }
        } catch (Exception e) {
            // ignore
        }
        return "unknown";
    }

    private java.lang.reflect.Field findIdField(Class<?> clazz) {
        for (var field : clazz.getDeclaredFields()) {
            if (field.isAnnotationPresent(Id.class) || field.isAnnotationPresent(EmbeddedId.class)) {
                return field;
            }
        }
        if (clazz.getSuperclass() != null) {
            return findIdField(clazz.getSuperclass());
        }
        return null;
    }
}

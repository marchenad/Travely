package com.example.travely.repository;

import com.example.travely.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    @Query("SELECT m FROM ChatMessage m JOIN FETCH m.sender WHERE m.trip.id = :tripId ORDER BY m.sentAt ASC")
    List<ChatMessage> findByTripIdOrderBySentAtAsc(@Param("tripId") Long tripId);
}

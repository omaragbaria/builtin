package com.builtin.controller;

import com.builtin.dto.AgentRequest;
import com.builtin.dto.AgentResponse;
import com.builtin.service.AgentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/agent")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;

    @PostMapping("/calculate")
    public ResponseEntity<AgentResponse> calculate(@Valid @RequestBody AgentRequest request) {
        return ResponseEntity.ok(agentService.calculate(request));
    }
}

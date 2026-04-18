package com.builtin.service;

import com.builtin.dto.AgentRequest;
import com.builtin.dto.AgentResponse;

public interface AgentService {
    AgentResponse calculate(AgentRequest request);
}

AgentManager.registered_agents.each do |agent_type|
  agent_type[:model].include(GenerateLocalAgentIdentifier)
end


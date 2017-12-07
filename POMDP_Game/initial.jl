immutable GameInitialBelief
  agent_init::Grid
  target_init::Grid
end

sampletype(::Type{GameInitialBelief}) = GameState
iterator(b::GameInitialBelief) = collect(GameState(b.agent_init, b.target_init, int, false) for int in [:pursue, :evade])

function rand(rng::AbstractRNG, b::GameInitialBelief)
  intent = rand([:pursue, :evade])
  return GameState(b.agent_init, b.target_init, intent, false)
end

function pdf(b::GameInitialBelief, s::GameState)
  if !s.terminal && s.agent==b.agent_init && s.target==b.target_init
    return 0.5
  else
    return 0.0
  end
end

# initial belief
initial_state_distribution(pomdp::GamePOMDP) = GameInitialBelief(pomdp.init_agent, pomdp.init_target)

function initialize_belief(up::BayesianUpdater, d::GameInitialBelief)

    init_state_dist = initial_state_distribution(up.model)

    return GameTypeBelief(init_state_dist.agent_init, init_state_dist.target_init, 1, 1, 0.5, false)
end

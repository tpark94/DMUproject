
# observation output distribution
#   - binary (intention)
immutable GameObsDist
    terminal::Bool
    intent_pd::SVector{2, Float64} # [pursue evade]
end

function rand(rng::AbstractRNG, d::GameObsDist)

    if d.terminal
        return GameState(d.apos, d.tpos_prev, d.intention, true)
    end

    # sample for intention
    i = sample(rng, Weights(d.intent_pd, 1.0))
    if i == 1 # pursue - true
        intent = true
    elseif i == 2
        intent = false
    end

# return the entire observation space
observations(pomdp::GamePOMDP) = [:pursue, :evade]

function observation(pomdp::GamePOMDP, sp::GameState)

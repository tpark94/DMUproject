# updater

struct GameTypeBelief
    agent::Grid
    target::Grid
    # Pseudocounts
    pursue::Int64
    evade::Int64
end

struct BayesianUpdater <: Updater
    model::GamePOMDP
end


# sample from belief distribution -- output GameState
function rand(rng::AbstractRNG, b::GameTypeBelief)

    # Beta distribution
    # P(pursue) = Beta(pursue, evade)
    dist = Beta(b.pursue, b.evade)

    # p = P(pursue) -- 0 < p < 1
    p = rand(dist)

    if rand() <= p
        return GameState(b.agent, b.target, :pursue, false)
    else
        return GameState(b.agent, b.target, :evade, false)
    end
end

iterator(b::GameTypeBelief) = b
#=
Base.start(b::GameTypeBelief) = 1
Base.done(b::GameTypeBelief, i::Int) = i > 2
function Base.next(b::GameTypeBelief, i::Int)



    if d.terminal
        return (GameState(d.apos, d.tpos_prev, d.gametype, true), i+1)
    else
        return (GameState(d.apos, d.tpos_prev+ACTION_DIR[i], d.gametype, false), i+1)
    end

end
=#

# pdf of pulling state (s) from distribution (b)
# Beta(pursue, evade) = p(pursue)
function pdf(b::GameTypeBelief, s::GameState)

    if s.terminal
        return 1.0
    end

    if b.agent != s.agent || b.target != s.target
        return 0.0
    end

    dist = Beta(b.pursue, b.evade)
    pp = rand(dist)

    if s.gametype == :pursue
        return pp
    else
        return 1-pp
    end

end

# find distance btw two agents
function find_distance(a1, a2)

    dist = sqrt((a1[1]-a2[1])^2 + (a1[2]-a2[2])^2)
    return dist
end

# update belief -- output belief distribution
function update(up::BayesianUpdater, b::GameTypeBelief, a::Symbol, o::Grid)

    apos_prev = b.agent
    tpos_prev = b.target
    tpos_new  = o

    dist_prev = find_distance(apos_prev, tpos_prev)
    dist_new  = find_distance(apos_prev, tpos_new)

    if dist_new < dist_prev
        # distance decreased, game is evade
        return GameTypeBelief(apos_prev, tpos_new, b.pursue, b.evade+1)
    else
        return GameTypeBelief(apos_prev, tpos_new, b.pursue+1, b.evade)
    end

end

function initialize_belief(up::BayesianUpdater, d::GameInitialBelief)

    init_state_dist = initial_state_distribution(up.model)

    return GameTypeBelief(init_state_dist.agent_init, init_state_dist.target_init, 1, 1)
end

# updater

struct GameTypeBelief
    agent::Grid
    target::Grid
    # Pseudocounts
    pursue::Int64
    evade::Int64
    p_pursue::Float64
    terminal::Bool
end

struct BayesianUpdater <: Updater
    model::GamePOMDP
end


# sample from belief distribution -- output GameState
function rand(rng::AbstractRNG, b::GameTypeBelief)

    if b.terminal
        return GameState(b.agent, b.target, :pursue, true)
    end

    p = rand(rng)
    if p <= b.p_pursue
        return GameState(b.agent, b.target, :pursue, false)
    else
        return GameState(b.agent, b.target, :evade, false)
    end
end

# pdf of pulling state (s) from distribution (b)
# Beta(pursue, evade) = p(pursue)
function pdf(b::GameTypeBelief, s::GameState)

    if b.terminal
        return s.terminal ? 1.0 : 0.0
    elseif s.terminal || b.agent != s.agent || b.target != s.target
        return 0.0
    else
        if s.gametype == :pursue
            return b.p_pursue
        else
            return 1-b.p_pursue
        end
    end

end

iterator(b::GameTypeBelief) = b
Base.start(b::GameTypeBelief) = 1
Base.done(b::GameTypeBelief, i::Int) = i > 2 ||  b.terminal && i > 1
function Base.next(b::GameTypeBelief, i::Int)

    if b.terminal
        return (GameState(b.agent, b.target, :pursue, true), i+1)
    else
        if i == 1
            return (GameState(b.agent, b.target, :pursue, false), i+1)
        elseif i == 2
            return (GameState(b.agent, b.target, :evade, false), i+1)
        end
    end
end

# find distance btw two agents
function find_distance(a1, a2)

    dist = sqrt((a1[1]-a2[1])^2 + (a1[2]-a2[2])^2)
    return dist
end

# update belief -- output belief distribution
function update(up::BayesianUpdater, b::GameTypeBelief, a::Symbol, o::Grid)
    if b.terminal
        return GameTypeBelief(b.agent, b.target, b.pursue, b.evade, b.p_pursue, true)
    end

    apos_prev = b.agent
    tpos_prev = b.target
    tpos_new  = o

    dist_prev = find_distance(apos_prev, tpos_prev)
    dist_new  = find_distance(apos_prev, tpos_new)

    if dist_new < dist_prev
        # distance decreased, game is evade
        p_new = b.pursue
        e_new = b.evade + 1
    else
        p_new = b.pursue + 1
        e_new = b.evade
    end
    dist = Beta(p_new, e_new)
    p_pursue = rand(dist)

    apos_new = apos_prev + ACTION_DIR[(action_index(up.model, a))]
    return GameTypeBelief(apos_new, tpos_new, p_new, e_new, p_pursue, false)

end


# transiton model distribution .....
immutable EvadeTransDist
    terminal::Bool
    apos::Grid
    tpos_prev::Grid
    pd::SVector{5, Float64}
end
EvadeTransDist(apos::Grid, tpos_prev::Grid, pd::AbstractVector) = EvadeTransDist(false, apos, tpos_prev, pd)

# returns random state after target moved
function rand(rng::AbstractRNG, d::EvadeTransDist)
    if d.terminal
        return EvadeState(d.apos, d.tpos_prev, true)
    end

    i = sample(rng, Weights(d.pd, 1.0))
    if i < 5
        tpos = d.tpos_prev + ACTION_DIR[i]
    else
        tpos = d.tpos_prev
    end
    return EvadeState(d.apos, tpos, false)
end

function pdf(d::EvadeTransDist, s::EvadeState)::Float64
    if d.terminal
        return s.terminal ? true : false
    elseif s.terminal || s.agent != d.apos || sum(abs, s.target-d.tpos_prev) > 1
        return 0.0
    elseif s.target == d.tpos_prev
        return d.pd[5]
    else
        dir = s.target-d.tpos_prev
        if dir[1] == 0
            if dir[2] == 1
                return d.pd[1]
            else
                return d.pd[3]
            end
        elseif dir[1] == 1
            return d.pd[2]
        else
            return d.pd[4]
        end
        # return d.probs[findfirst(CARDINALS, dir)]
    end
end

iterator(d::EvadeTransDist) = d

Base.start(d::EvadeTransDist) = 1
Base.done(d::EvadeTransDist, i::Int) = i > 5 || d.terminal && i > 1
function Base.next(d::EvadeTransDist, i::Int)
    if d.terminal
        return (EvadeState(d.apos, d.tpos_prev, true), i+1)
    else
        return (EvadeState(d.apos, d.tpos_prev+ACTION_DIR[i], false), i+1)
    end
end

# TRANSITION MODEL (T)
function transition(mdp::EvadeMDP, s::EvadeState, a::Symbol)

    if s.terminal || s.agent == s.target
       return EvadeTransDist(true, s.agent, s.target, SVector(1., 0., 0., 0., 0.))
    end

    pd = fill!(MVector{5, Float64}(), 0.0)

    target = s.target
    agent = s.agent
    w = mdp.world

    # transition probabilities (pd) of the target
    if target[1] == agent[1] # above or below
        if target[2] < agent[2]
            pd[1] += 0.8
        elseif target[2] > agent[2]
            pd[3] += 0.8
        end
    elseif target[1] < agent[1] # target on right
        if target[2] < agent[2]
            pd[1] += 0.4
            pd[2] += 0.4
        elseif target[2] > agent[2]
            pd[2] += 0.4
            pd[3] += 0.4
        else
            pd[2] += 0.8
        end
    elseif target[1] > agent[1] # target on left
        if target[2] < agent[2]
            pd[1] += 0.4
            pd[4] += 0.4
        elseif target[2] > agent[2]
            pd[3] += 0.4
            pd[4] += 0.4
        else
            pd[4] += 0.8
        end
    end

    pd[5] = 1.0 - sum(pd)


    # move the agent
    a_ind = action_index(mdp, a)
    if inside(w, agent + ACTION_DIR[a_ind])
       apos_next = agent + ACTION_DIR[a_ind]
    else
       apos_next = agent
    end

    return EvadeTransDist(apos_next, target, pd)
end


# transiton model distribution .....
immutable PursueTransDist
    terminal::Bool
    apos::Grid
    tpos_prev::Grid
    pd::SVector{5, Float64}
end
PursueTransDist(apos::Grid, tpos_prev::Grid, pd::AbstractVector) = PursueTransDist(false, apos, tpos_prev, pd)

# returns random state after target moved
function rand(rng::AbstractRNG, d::PursueTransDist)
    if d.terminal
        return PursueState(d.apos, d.tpos_prev, true)
    end

    i = sample(rng, Weights(d.pd, 1.0))
    if i < 5
        tpos = d.tpos_prev + ACTION_DIR[i]
    else
        tpos = d.tpos_prev
    end
    return PursueState(d.apos, tpos, false)
end

function pdf(d::PursueTransDist, s::PursueState)::Float64
    if d.terminal
        return s.terminal ? 1.0 : 0.0
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

iterator(d::PursueTransDist) = d

Base.start(d::PursueTransDist) = 1
Base.done(d::PursueTransDist, i::Int) = i > 5 || d.terminal && i > 1
function Base.next(d::PursueTransDist, i::Int)
    if d.terminal
        return (PursueState(d.apos, d.tpos_prev, true), i+1)
    else
        return (PursueState(d.apos, d.tpos_prev+ACTION_DIR[i], false), i+1)
    end
end

# TRANSITION MODEL (T)
function transition(mdp::PursueMDP, s::PursueState, a::Symbol)
    if s.terminal || a == :catch && s.agent == s.target
       return PursueTransDist(true, s.agent, s.target, SVector(1., 0., 0., 0., 0.))
    end

    pd = fill!(MVector{5, Float64}(), 0.0)

    target = s.target
    agent = s.agent
    w = mdp.world

    # opponent behavior (see base_tag.cpp line 576)
    # 0.4 chance of moving in x direction
    if target[1] == agent[1]
       if inside(w, target + Grid(1,0))
           pd[2] += 0.2
       end
       if inside(w, target + Grid(-1,0))
           pd[4] += 0.2
       end
    elseif target[1] > agent[1] && inside(w, target + Grid(1,0))
       pd[2] += 0.4
    elseif target[1] < agent[1] && inside(w, target + Grid(-1,0))
       pd[4] += 0.4
    end

    # 0.4 chance of moving in y direction
    if target[2] == agent[2]
       if inside(w, target + Grid(0,1))
           pd[1] += 0.2
       end
       if inside(w, target + Grid(0,-1))
           pd[3] += 0.2
       end
    elseif target[2] > agent[2] && inside(w, target + Grid(0,1))
       pd[1] += 0.4
    elseif target[2] < agent[2] && inside(w, target + Grid(0,-1))
       pd[3] += 0.4
    end

    # 0.2 + all out of bounds mass chance staying the same
    pd[5] = 1.0 - sum(pd)

    a_ind = action_index(mdp, a)
    if inside(w, agent + ACTION_DIR[a_ind])
       apos_next = agent + ACTION_DIR[a_ind]
    else
       apos_next = agent
    end

    return PursueTransDist(apos_next, target, pd)
end

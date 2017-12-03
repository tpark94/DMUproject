# Distribution model for both transition and observation
immutable GameTransDist
    terminal::Bool
    apos::Grid
    tpos_prev::Grid
    #intention::Bool # mirrors GameState's tar_intent
    pd::SVector{5, Float64} # movement prob. dist. of TARGET
end
GameTransDist(apos::Grid, tpos_prev::Grid, pd::AbstractVector) =
                        GameTransDist(false, apos, tpos_prev, pd)

# sample from distribution
function rand(rng::AbstractRNG, d::GameTransDist)
    if d.terminal
        return GameState(d.apos, d.tpos_prev, true)
    end

    # sample for target movement
    i = sample(rng, Weights(d.pd, 1.0))
    if i < 5
        tpos = d.tpos_prev + ACTION_DIR[i]
    else
        tpos = d.tpos_prev
    end

    return GameState(d.apos, tpos, false)
end

# prob. distribution function of distribution
function pdf(d::GameTransDist, s::GameState)::Float64
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
    end
end

iterator(d::GameTransDist) = d

Base.start(d::GameTransDist) = 1
Base.done(d::GameTransDist, i::Int) = i > 5 || d.terminal && i > 1
function Base.next(d::GameTransDist, i::Int)
    if d.terminal
        return (GameState(d.apos, d.tpos_prev, true), i+1)
    else
        return (GameState(d.apos, d.tpos_prev+ACTION_DIR[i], false), i+1)
    end
end

# TRANSITION MODEL (T) - return distribution
function transition(pomdp::GamePOMDP, s::GameState, a::Symbol)

    if s.terminal || a == :stay && s.agent == s.target
       return GameTransDist(true, s.agent, s.target, SVector(1., 0., 0., 0., 0.))
    end

    pd = fill!(MVector{5, Float64}(), 0.0)

    target = s.target
    agent = s.agent
    w = pomdp.world

    # Target's movement depends on its true intention
    if target_true_intention # if pursuing target -- target moves randomly
        cnt = 0
        iswall = falses(1,5)
        for i in 1:4
            if !inside(w, target + ACTION_DIR[i])
                cnt = cnt + 1
                iswall[i] = true
            end
        end
        rate = 1.0/(5-cnt)
        for i in 1:5
            if !iswall[i]
                pd[i] = rate
            end
        end
    else # if evading target -- target comes after you!
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
    end

    # transition is deterministic
    #   given action (a), sp has no uncertainty
    #   s.tar_intent isn't affected by transition
    a_ind = action_index(pomdp, a)
    if inside(w, agent + ACTION_DIR[a_ind])
       apos_next = agent + ACTION_DIR[a_ind]
    else
       apos_next = agent
    end

    return GameTransDist(apos_next, target, pd)
end

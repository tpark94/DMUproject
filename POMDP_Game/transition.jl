# Distribution model for both transition and observation
immutable GameTransDist
    terminal::Bool
    apos::Grid
    tpos_prev::Grid
    gametype::Symbol # mirrors GameState's tar_intent
    pd::SVector{5, Float64} # movement prob. dist. of TARGET
end
GameTransDist(apos::Grid, tpos_prev::Grid, gametype::Symbol, pd::AbstractVector) =
                        GameTransDist(false, apos, tpos_prev, gametype, pd)

# sample from transition distribution
function rand(rng::AbstractRNG, d::GameTransDist)
    if d.terminal
        return GameState(d.apos, d.tpos_prev, d.gametype, true)
    end

    # sample for target movement
    i = sample(rng, Weights(d.pd, 1.0))
    if i < 5
        tpos = d.tpos_prev + ACTION_DIR[i]
    else
        tpos = d.tpos_prev
    end

    return GameState(d.apos, tpos, d.gametype, false)
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
        return (GameState(d.apos, d.tpos_prev, d.gametype, true), i+1)
    else
        return (GameState(d.apos, d.tpos_prev+ACTION_DIR[i], d.gametype, false), i+1)
    end
end

# TRANSITION MODEL (T) - return distribution
function transition(pomdp::GamePOMDP, s::GameState, a::Symbol)

    if s.terminal || s.agent == s.target
       return GameTransDist(true, s.agent, s.target, s.gametype, SVector(1., 0., 0., 0., 0.))
    end

    pd = fill!(MVector{5, Float64}(), 0.0)

    target = s.target
    agent = s.agent
    w = pomdp.world

    # Target's movement depends on its true intention
    if pomdp.true_gametype == :pursue # if pursuing target -- target moves randomly
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
                pd[1] += 2*pomdp.tp
            elseif target[2] > agent[2]
                pd[3] += 2*pomdp.tp
            end
        elseif target[1] < agent[1] # target on right
            if target[2] < agent[2]
                pd[1] += pomdp.tp
                pd[2] += pomdp.tp
            elseif target[2] > agent[2]
                pd[2] += pomdp.tp
                pd[3] += pomdp.tp
            else
                pd[2] += 2*pomdp.tp
            end
        elseif target[1] > agent[1] # target on left
            if target[2] < agent[2]
                pd[1] += pomdp.tp
                pd[4] += pomdp.tp
            elseif target[2] > agent[2]
                pd[3] += pomdp.tp
                pd[4] += pomdp.tp
            else
                pd[4] += 2*pomdp.tp
            end
        end

        pd[5] = 1.0 - sum(pd)

    end

    # transition is deterministic
    #   given action (a), sp has no uncertainty
    #   s.gametype isn't affected by transition
    a_ind = action_index(pomdp, a)
    if inside(w, agent + ACTION_DIR[a_ind])
       apos_next = agent + ACTION_DIR[a_ind]
    else
       apos_next = agent
    end

    return GameTransDist(apos_next, target, s.gametype, pd)
end


# transiton model distribution .....
immutable PursueTransDist
    terminal::bool
    apos::grid
    tpos_prev::grid
    pd::SVector{5, Float64}
end
PursueTransDist(apos::Coord, tpos_prev::Coord, pd::AbstractVector) = PursueTransDist(false, apos, tpos_prev, pd)

# returns random state after target moved
function rand(rng::AbstractRNG, d::PursueTransDist)
    if d.terminal
        return PursueState(d.apos, d.tpos_prev, true)
    end

    # update target position based on its transition model
    i = sample(rng, Weights(d.pd, 1.0))
    tpos = d.tpos_prev + ACTION_DIRS[i]

    return PursueState(d.apos, tpos, false)
end


# TRANSITION MODEL (T)
function transition(mdp::PursueMDP, s::PursueState, a::Symbol)

    if s.terminal
        return PursueTransDist(true, s.agent, s.target, SVector{0., 0., 0., 0., 1.})
    end

    d = PursueTransDist(s.agent, s.target, )
    d.pd = [0.2 0.2 0.2 0.2 0.2] # uniform when agent is pursuing

end

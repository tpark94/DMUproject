
# observation output distribution
#   - binary (intention)
immutable GameObsDist
    apos::Grid
    tpos::Grid
    dist_prev::Float64
    intent_pd::SVector{Float64, 2} # [pursue evade]
end

# sampling from observation distribution - return GameState
#   with same physical state + new intention
function rand(rng::AbstractRNG, d::GameObsDist)

    # sample for intention
    i = sample(rng, Weights(d.intent_pd, 1.0))
    if i == 1 # pursue - true
        intent = true
    elseif i == 2
        intent = false
    end
    return GameState(d.apos, d.tpos, intent, false)
end

# prob. distribution function of observation
function pdf(d::GameObsDist, s::GameState)::Float64

    return s.tar_intent ? d.intend_pd[1] : d.intent_pd[2]

end

#=
# return observation distribution ....
function observation(pomdp::GamePOMDP, sp::GameState)


    newdist = find_distance(sp.agent, sp.target)
    # pd : updated prob. dist. of intention
    if newdist >= prev_dist # moved away - probably evading
        p_pur = Beta(cnt_p, cnt_e+1)
    else
        p_pur = Beta(cnt_p+1, cnt_e)
    end

    pd = [p_pur, 1-p_pur]

    return GameObsDist(sp.agent, sp.target, newdist, pd)
end
=#
observation(pomdp::GamePOMDP, sp::GameState)

# (Z) - observation space
#observations(pomdp::GamePOMDP) = [:pursue, :evade]
#n_observations(pomdp::GamePOMDP) = 2

# observation output distribution
#   - binary (intention)
immutable GameObsDist
    #apos::Grid
    tpos::Grid
    # intent_pd::SVector{2, Float64} # [pursue evade]
end

# sampling from observation distribution - return (Grid, Grid)
#   with same physical state + new intention
function rand(rng::AbstractRNG, d::GameObsDist)
    #=
    # sample for intention
    i = sample(rng, Weights(d.intent_pd, 1.0))
    if i == 1 # pursue - true
        intent = :pursue
    elseif i == 2
        intent = :evade
    end
    return intent
    =#
    return d.tpos
end

# prob. distribution function of observation
function pdf(d::GameObsDist, o::Grid)

    #=
    if o==:pursue
        return d.intent_pd[1]
    else
        return d.intent_pd[2]
    end
    =#
    return 1.0

end

# return observation distribution ....
function observation(pomdp::GamePOMDP, a::Symbol, sp::GameState)

    #=
    #olddist = find_distance(s)
    olddist = pomdp.dist_prev
    newdist = find_distance(sp)
    pomdp.dist_prev = newdist

    # pd : updated prob. dist. of intention
    if newdist < olddist # approaching agent, this is "evade" game
        temp = pomdp.evade + 1
        pomdp.evade = temp
    else
        temp = pomdp.pursue + 1
        pomdp.pursue = temp
    end
    beta = Beta(pomdp.pursue, pomdp.evade)

    # prob. of game being 'pursue'
    pp = rand(beta)

    # prob. dist. of game type
    pd = [pp, 1-pp] # [pursue evade]

    return GameObsDist(sp.agent, sp.target, pd)
    =#
    return GameObsDist(sp.target)
end

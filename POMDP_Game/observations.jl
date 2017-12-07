# (Z) - observation space

# observation output distribution
#   - binary (intention)
immutable GameObsDist
    tpos::Grid
end

# sampling from observation distribution - return (Grid, Grid)
#   with same physical state + new intention
function rand(rng::AbstractRNG, d::GameObsDist)

    return d.tpos
end

# prob. distribution function of observation
function pdf(d::GameObsDist, o::Grid)

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

# (Z) - observation space
observations(pomdp::GamePOMDP) = [:pursue, :evade]
n_observations(pomdp::GamePOMDP) = 2

# observation output distribution
#   - binary (intention)
immutable GameObsDist
    apos::Grid
    tpos::Grid
    #dist_prev::Float64
    intent_pd::SVector{2, Float64} # [pursue evade]
end

# sampling from observation distribution - return GameState
#   with same physical state + new intention
function rand(rng::AbstractRNG, d::GameObsDist)

    # sample for intention
    i = sample(rng, Weights(d.intent_pd, 1.0))
    if i == 1 # pursue - true
        intent = :pursue
    elseif i == 2
        intent = :evade
    end
    return intent
end

# prob. distribution function of observation
function pdf(d::GameObsDist, o::Symbol)

    if o==:pursue
        return d.intent_pd[1]
    else
        return d.intent_pd[2]
    end

end

mutable struct BetaParam
    pursue::Int64
    evade::Int64
end
param = BetaParam(1, 1)

mutable struct Dist
     dist::Float64
end
dist_prev  = Dist(sqrt(7^2 + 8^2))

# return observation distribution ....
function observation(pomdp::GamePOMDP, a::Symbol, sp::GameState)
    return observation(pomdp, sp)
end

function observation(pomdp::GamePOMDP, sp::GameState)

    #olddist = find_distance(s)
    olddist = dist_prev.dist
    newdist = find_distance(sp)
    dist_prev.dist = newdist

    # pd : updated prob. dist. of intention
    if newdist < olddist # approaching agent, this is "evade" game
        temp = param.evade + 1
        param.evade = temp
    else
        temp = param.pursue + 1
        param.pursue = temp
    end
    beta = Beta(param.pursue, param.evade)

    # prob. of game being 'pursue'
    pp = rand(beta)

    pd = [pp, 1-pp] # [pursue evade]

    return GameObsDist(sp.agent, sp.target, pd)
end

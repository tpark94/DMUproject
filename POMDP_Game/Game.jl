__precompile__()

module Game

# Many parts of this implementation is inspired & taken from
# https://github.com/zsunberg/LaserTag.jl.git

# install the POMDPs.jl interface
#Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
#Pkg.clone("https://github.com/JuliaArrays/StaticArrays.jl")
#Pkg.add("Parameters")
#Pkg.add("Distributions")
#Pkg.add("AutoHashEquals")
#Pkg.add("StatsBase")

using StaticArrays
using Parameters
using Distributions
using AutoHashEquals
using StatsBase

importall POMDPs

export
    Grid,
    GameState,
    GamePOMDP,

    GameVis

#####################################################
const Grid = SVector{2, Int64} # {col, row}

# true - pursue target
# false - evade target
const target_true_intention = true # TRUE - we pursue

cnt_p = 1
cnt_e = 1

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable GameState
    agent::Grid
    target::Grid
    #tar_intent::Bool # true - pursue, false - evade
    terminal::Bool
end
# tar_intent of GameState is NOT target's true intention, but rather
# modeled based on a history of observations

# grid world
immutable World
    nrows::Int64
    ncols::Int64
end

# find distance btw two agents
function find_distance(s::GameState)
    a1 = s.agent
    a2 = s.target
    dist = sqrt((a1[1]-a2[1])^2 + (a1[2]-a2[2])^2)
    return dist
end

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.ncols && 0 < c[2] <= w.nrows

# POMDP{state, action, observation}
@with_kw immutable GamePOMDP <: MDP{GameState, Symbol}
    r_move::Float64       = -0.1 # reward for moving
    r_capture::Float64    = 100.0   # reward for capturing target
    r_caught::Float64     = -100.0
    discount::Float64     = 0.95 # gamma
    world::World          = World(15, 15)
    true_intent::Bool     = target_true_intention
end

trueint(pomdp::GamePOMDP) = pomdp.true_intent
ncols(pomdp::GamePOMDP) = pomdp.world.ncols
nrows(pomdp::GamePOMDP) = pomdp.world.nrows

isterminal(pomdp::GamePOMDP, s::GameState) = s.terminal
discount(pomdp::GamePOMDP) = pomdp.discount

###################################################
# What's needed for POMDP solver
include("states.jl")
include("actions.jl")
include("transition.jl")

observation(pomdp::GamePOMDP, sp::GameState) = sp

function reward(pomdp::GamePOMDP, s::GameState, a::Symbol, sp::GameState)

    old_dist = find_distance(s)
    new_dist = find_distance(sp)

    if new_dist >= old_dist # moved away - we must pursue
        global cnt_p += 1
    else
        global cnt_e += 1
    end

    prob_pursue = rand(Beta(cnt_p, cnt_e))
    pd = [prob_pursue, 1-prob_pursue]
    intention = [true false]
    pursue = sample(intention, Weights(pd, 1.0))

    if pursue # pursue
        if a==:stay && s.agent == s.target
            #@assert sp.terminal
            return pomdp.r_capture
        elseif action_index(pomdp, a) <= 4
            return pomdp.r_move
        else
            return 0.
        end
    else # evade
        if s.agent == s.target
            #@assert sp.terminal
            return pomdp.r_caught
        end
        if action_index(pomdp, a) <= 4
            return pomdp.r_move
        else
            return 0.
        end
    end
end

initial_state(pomdp::GamePOMDP, rng::AbstractRNG) = GameState((1,2), (10,8), false)

include("GameVis.jl")

#######################################

end

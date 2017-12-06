# STATES (S)
states(pomdp::GamePOMDP) = states(pomdp.world)

npos(w::World) = (w.nrows * w.ncols) # num. of positions of an anget

# STATE (S) space
function states(w::World)
    vec = Array{GameState}(2*npos(w)^2+1)

    # iterate thru agent position, target position, target intention
    for i in 1:w.ncols, j in 1:w.nrows, k in 1:w.ncols, l in 1:w.nrows, m in [:pursue, :evade]
        s = GameState(Grid(i,j), Grid(k,l), m, false)
        vec[state_index(w, s)] = s
    end
    vec[end] = GameState(Grid(1,1), Grid(1,1), :pursue, true)
    return vec
end

state_index(pomdp::GamePOMDP, s::GameState) = state_index(pomdp.world, s)

function state_index(w::World, s::GameState)
    r = w.nrows
    c = w.ncols
    if s.terminal
       return 2*npos(w)^2 + 1
    else
       a = s.agent
       t = s.target
       if s.gametype == :pursue
           int = 1
       else
           int = 2
       end
       return sub2ind((c,r,c,r,2), a[1], a[2], t[1], t[2], int)
    end
end

n_states(pomdp::GamePOMDP) = 2*npos(pomdp.world)^2 + 1

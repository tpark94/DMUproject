# STATES (S)
states(pomdp::GamePOMDP) = states(pomdp.world)

npos(w::World) = (w.nrows * w.ncols) # num. of positions of an anget

function states(w::World)
    vec = Array{GameState}(npos(w)^2+1)

    for i in 1:w.ncols, j in 1:w.nrows, k in 1:w.ncols, l in 1:w.nrows
        s = GameState(Grid(i,j), Grid(k,l), false)
        vec[state_index(w, s)] = s
    end
    vec[end] = GameState(Grid(1,1), Grid(1,1), true)
    return vec
end

state_index(pomdp::GamePOMDP, s::GameState) = state_index(pomdp.world, s)

function state_index(w::World, s::GameState)
    r = w.nrows
    c = w.ncols
    if s.terminal
       return npos(w)^2 + 1
    else
       a = s.agent
       t = s.target
       return sub2ind((c,r,c,r), a[1], a[2], t[1], t[2])
    end
end

n_states(pomdp::GamePOMDP) = npos(pomdp.world)^2 + 1

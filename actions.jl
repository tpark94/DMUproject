# Action space
const ACTION_NAMES = SVector("up", "down", "right", "left", "catch")
const ACTION_DIRS  = SVector(Grid(0,1), Grid(0,-1), Grid(1,0), Grid(-1,0), Grid(0,0))

# ACTION (A)
n_actions(mdp::PursueMDP) = 5;
actions(mdp::PursueMDP) = 1:n_actions(mdp);
# function action_index(mdp::PursueMDP, a::Symbol)

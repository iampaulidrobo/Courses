MC Prediction
    learns V(s)

MC Control
    learns Q(s,a)

TD(0)
    learns V(s)

SARSA
    learns Q(s,a)

Q-Learning
    learns Q(s,a)


    

Create Environment

Create Random Agent

Create Value Table V

Repeat Forever:

    Start New Episode

    Reset Environment

    EpisodeStates = []

    While Game Not Finished:

        Observe Current State

        Store State

        Get Legal Actions

        Randomly Select Action

        Execute Action

        Observe:
            Next State
            Reward
            Done

        Move To Next State

    Monte Carlo Update

    Save Learned Values

First-Visit Monte Carlo State-Value Estimationimplementation is essentially doing:
    Play a completely random game
            ↓
    Remember every state visited
            ↓
    Observe final outcome
            ↓
    Assign that outcome to all visited states
            ↓
    Average over many games

Episode 1

Random game:

State S1
↓
State S2
↓
State S3
↓
X Wins

Reward:

+1
returns[S1] = [1]
returns[S2] = [1]
returns[S3] = [1]
Episode 2

Another random game:

State S1
↓
State S4
↓
State S5
↓
Draw
Reward:
0
returns[S1] = [1,0]
returns[S4] = [0]
returns[S5] = [0]

Now:

V[S1]
=
average([1,0])
=
0.5


Monte Carlo Control pseudocode
Repeat Forever:

    Wait For SPACE

    Start New Episode

    Play Game

    Update Q Table

    Save Learning Data

    Show Results
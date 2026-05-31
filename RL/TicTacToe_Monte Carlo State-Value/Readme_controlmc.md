High-Level Goal

Learn:

Q(s,a)

Meaning:

How good is taking action a
when I'm in state s?
Initialization
Create Environment

Create Q Table

Create Returns Table

Create Monte Carlo Agent

Wait for User Input
Main Program Loop
Repeat Forever:

    Wait For SPACE

    Start New Episode

    Play Game

    Update Q Table

    Save Learning Data

    Show Results
Wait For SPACE
Display Board

Display Statistics

Display:
    Press SPACE

If SPACE:
    Start Episode

If ESC:
    Quit Program
Start New Episode
Reset Environment

Get Initial State

Create Empty Episode Memory

done = False
Play Episode
While Game Not Finished:

    Observe Current State

    Get Legal Moves

    Agent Selects Action

    Store:
        (state, action)

    Execute Action

    Receive:
        next_state
        reward
        done
        winner

    Render Board

    Move To Next State
Agent Logic (ε-Greedy)
If random number < epsilon:

    Explore

    Choose Random Action

Else:

    Exploit

    Choose Action With
    Highest Q(s,a)
Episode Memory

During one game:

Store:

(state1, action1)

(state2, action2)

(state3, action3)

...

Example:

(EmptyBoard, 4)

(Board2, 0)

(Board3, 8)

(Board4, 3)
Game Ends

Example:

Winner = X

Reward = +1

Episode trajectory:

(S1,4)

(S2,0)

(S3,8)

(S4,3)


Monte Carlo Control Update

For every unique:

(state, action)

in the episode:

returns[(state,action)]
    append(final_reward)

Then:

Q(state,action)
=
Average(
    returns[(state,action)]
)
Episode 1

Agent starts with:

All Q values = 0

Game trajectory:

(S1,4)
(S2,0)
(S3,8)

Final result:

X wins

Reward = +1

Update:

returns[(S1,4)] = [1]
returns[(S2,0)] = [1]
returns[(S3,8)] = [1]

Then:

Q(S1,4) = average([1]) = 1.0

Q(S2,0) = average([1]) = 1.0

Q(S3,8) = average([1]) = 1.0
Episode 2

Later another game occurs.

Trajectory:

(S1,4)
(S5,3)
(S6,1)

Final result:

Draw

Reward = 0

Now:

returns[(S1,4)]

becomes:

[1, 0]

So:

Q(S1,4)
=
average([1,0])
=
0.5
Episode 3

Another game.

Trajectory:

(S1,4)
(S7,2)

Final result:

Loss

Reward = -1

Now:

returns[(S1,4)]
=
[1,0,-1]

Therefore:

Q(S1,4)
=
(1+0-1)/3
=
0

Complete RL Flow
State
   ↓
ε-Greedy Action Selection
   ↓
Action
   ↓
Environment
   ↓
Next State
   ↓
...
   ↓
Terminal Reward
   ↓
Monte Carlo Update
   ↓
Q(s,a)
   ↓
Improved Future Decisions
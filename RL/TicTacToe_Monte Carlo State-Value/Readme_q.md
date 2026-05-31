Initialize:

    Environment

    Agent (ε-greedy)

    Q Table

    Statistics


WHILE Program Running

    Wait For SPACE

    Start New Episode

    state = Initial State


    WHILE Episode Not Finished

        Choose Action

        Execute Action

        Receive:

            next_state
            reward
            done


        Update Q-Learning

            Q(state, action)

            using

            reward

            +

            gamma * Best Future Action Value


        state = next_state


    Save Q Table

    Update Statistics

    Display Final Board
-------------------Suppose:

Current State = S1

Action Taken = A4

You arrive at:

Next State = S2

And in S2:

Action 0 -> 0.2

Action 4 -> 0.9

Action 8 -> 0.1

Q-Learning says:

The best future value available
from S2 is 0.9

So it updates:

Q(S1,A4)

using:

reward

+

gamma * 0.9

Visually:

S1
↓
A4
↓
S2
↓
max Q(S2,*)

Then:

Update Q(S1,A4)
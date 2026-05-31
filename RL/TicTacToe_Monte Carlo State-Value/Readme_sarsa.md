Initialize:

    Environment

    SARSA Agent

    Q Table


WHILE Program Running

    Wait For SPACE

    Reset Environment

    state = Initial State

    action = ε-Greedy Action


    WHILE Episode Not Finished

        Execute Action

        Receive:

            next_state
            reward
            done

        IF not done

            next_action =
                ε-Greedy Action

        Update:

            Q(state, action)

            using

            reward
            next_state
            next_action

        state = next_state

        action = next_action


    Save Q Table

    Update Statistics

    Show Final Board


---------------------------

Example

Suppose:

Current:

State S1

Choose Action 4

Current Q:

Q(S1,4)

=

0.2

Move.

Reach:

State S2

Agent chooses:

Action 7

Current:

Q(S2,7)

=

0.8

Reward:

0

Target:

0

+

0.9 * 0.8

=

0.72

Error:

0.72 - 0.2

=

0.52

Update:

Q(S1,4)

=

0.2

+

0.1 * 0.52

=

0.252
What's Being Learned?

SARSA learns:

How good was

Action 4

when I was in

State S1

TD(0) learns:

How good was

State S1


-------------

TD(0):

V(s)

learns from

V(s')

SARSA:

Q(s,a)

learns from

Q(s',a')

That's it.
----

TD(0):

V(s)

learns from

V(s')

SARSA:

Q(s,a)

learns from

Q(s',a')

That's it.
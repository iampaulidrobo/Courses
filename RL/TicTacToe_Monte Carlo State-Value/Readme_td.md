V(s)=V(s)+α[r+γV(s′)−V(s)]
                 

Example

Suppose:

V(S1)=0.2

V(S2)=0.8

reward=0

gamma=0.9

Target:

0 + 0.9*0.8
=
0.72

Current estimate:

0.2

Error:

0.72 - 0.2
=
0.52

Meaning:

S1 was undervalued.

Increase it.

Update

Suppose:

alpha=0.1

Update:

V(S1)

=

0.2

+

0.1*(0.52)

=

0.252

Compare MC vs TD
Monte Carlo
Need:
State trajectory

Wait until episode ends
TD(0)
Need:
State
Reward
Next State

Update immediately


INITIALIZATION

Create Pygame Window

Create Environment

Create Random Agent

Initialize:
    Episode Counter
    Win Statistics
    V(s)

Set:
    Winner Text = "Press SPACE"


==================================================
MAIN LOOP
==================================================

WHILE program running

    ------------------------------------------------
    WAIT FOR SPACE
    ------------------------------------------------

    Display:
        Empty Board
        Statistics
        Winner Text

    WAIT until:
        SPACE pressed
        OR
        ESC / Window Close

    IF Quit
        Exit Program


    ------------------------------------------------
    START NEW EPISODE
    ------------------------------------------------

    episode_count += 1

    Reset Environment

    state = Initial State

    done = False


    ------------------------------------------------
    PLAY GAME
    ------------------------------------------------

    WHILE episode not finished

        Handle Quit Events

        legal_moves =
            available moves

        action =
            Random Agent Action

        Execute Action

        Receive:

            next_state
            reward
            done
            winner


        --------------------------------------------
        TD(0) UPDATE
        --------------------------------------------

        Update:

            V(state)

        using:

            reward
            next_state
            done


        Render Board

        state = next_state


    ------------------------------------------------
    SAVE LEARNING
    ------------------------------------------------

    Save:

        V(s)

    to:

        data/td0/V.json


    ------------------------------------------------
    UPDATE STATISTICS
    ------------------------------------------------

    IF winner == X

        xwins += 1

    ELSE IF winner == O

        owins += 1

    ELSE

        draws += 1

    Print:

        Episode Count

        Winner

        Reward

        Total States Learned


    ------------------------------------------------
    SHOW FINAL BOARD
    ------------------------------------------------

    Display:

        Final Board

        Winner

        Statistics

    Wait For Next SPACE


==================================================
PROGRAM END
==================================================

Close Pygame




from collections import defaultdict


# =====================================
# STATE VALUE TABLE
# V[state]
# =====================================

V = defaultdict(float)


# =====================================
# TD PARAMETERS
# =====================================

ALPHA = 0.1

GAMMA = 0.9


# =====================================
# TD(0) UPDATE
# =====================================

def update_td(
    state,
    reward,
    next_state,
    done
):

    if done:

        td_target = reward

    else:

        td_target = (
            reward
            +
            GAMMA * V[next_state]
        )

    td_error = (
        td_target
        -
        V[state]
    )

    V[state] += (
        ALPHA
        *
        td_error
    )


# =====================================
# DEBUG
# =====================================

def total_states():

    return len(V)


def print_values(
    max_states=5
):

    print("\n========================")
    print("TD VALUE TABLE")
    print("========================")

    count = 0

    for state, value in V.items():

        print("\nState:")

        for i in range(
            0,
            9,
            3
        ):
            print(
                state[i:i+3]
            )

        print(
            f"\nValue: {value:.3f}"
        )

        count += 1

        if count >= max_states:
            break

    print(
        "\n========================\n"
    )
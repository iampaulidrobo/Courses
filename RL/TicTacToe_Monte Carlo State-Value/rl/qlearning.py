from collections import defaultdict


# =====================================
# Q TABLE
# Q[state][action]
# =====================================

Q = defaultdict(
    lambda: defaultdict(float)
)


# =====================================
# PARAMETERS
# =====================================

ALPHA = 0.1

GAMMA = 0.9


# =====================================
# Q-LEARNING UPDATE
# =====================================

def update_qlearning(
    state,
    action,
    reward,
    next_state,
    done
):

    current_q = Q[state][action]

    if done:

        target = reward

    else:

        max_next_q = 0.0

        if len(Q[next_state]) > 0:

            max_next_q = max(
                Q[next_state].values()
            )

        target = (
            reward
            +
            GAMMA * max_next_q
        )

    td_error = (
        target
        -
        current_q
    )

    Q[state][action] += (
        ALPHA
        *
        td_error
    )


# =====================================
# DEBUG HELPERS
# =====================================

def total_states():

    return len(Q)


def total_state_actions():

    count = 0

    for state in Q:

        count += len(
            Q[state]
        )

    return count


def print_q_table(
    max_states=5
):

    print("\n========================")
    print("Q LEARNING TABLE")
    print("========================")

    shown = 0

    for state in Q:

        print("\nState:")

        for i in range(
            0,
            9,
            3
        ):

            print(
                state[i:i+3]
            )

        print("\nActions:")

        for action, value in (
            Q[state].items()
        ):

            print(
                f"Action {action}"
                f" -> "
                f"{value:.3f}"
            )

        shown += 1

        if shown >= max_states:

            break

    print(
        "\n========================\n"
    )
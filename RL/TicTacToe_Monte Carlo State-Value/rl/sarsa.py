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
# SARSA UPDATE
# =====================================

def update_sarsa(
    state,
    action,
    reward,
    next_state,
    next_action,
    done
):

    current_q = (
        Q[state][action]
    )

    if done:

        target = reward

    else:

        target = (
            reward
            +
            GAMMA *
            Q[next_state][next_action]
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
# DEBUG
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
    print("SARSA Q TABLE")
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

        for action, value in Q[state].items():

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
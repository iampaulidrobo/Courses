from collections import defaultdict


# -----------------------------------
# Q Table
# Q[state][action]
# -----------------------------------

Q = defaultdict(
    lambda: defaultdict(float)
)


# -----------------------------------
# Returns Table
# returns[(state, action)]
# -----------------------------------

returns = defaultdict(list)


# -----------------------------------
# First Visit Monte Carlo Control
# -----------------------------------

def update_mc_control(
    state_actions,
    reward
):

    visited = set()

    for state, action in state_actions:

        sa = (
            state,
            action
        )

        # First Visit MC
        if sa in visited:
            continue

        returns[sa].append(
            reward
        )

        Q[state][action] = (
            sum(
                returns[sa]
            )
            /
            len(
                returns[sa]
            )
        )

        visited.add(sa)


# -----------------------------------
# Debug Print
# -----------------------------------

def print_q_table():

    print("\n========================")
    print("Q TABLE")
    print("========================")

    state_count = 0

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
                f"Action {action} -> "
                f"{value:.3f}"
            )

        state_count += 1

        if state_count >= 5:
            break

    print("========================\n")


# -----------------------------------
# Stats
# -----------------------------------

def total_state_actions():

    count = 0

    for state in Q:

        count += len(
            Q[state]
        )

    return count
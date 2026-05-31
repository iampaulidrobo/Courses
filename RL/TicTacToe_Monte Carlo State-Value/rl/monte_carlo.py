from collections import defaultdict

returns = defaultdict(list)

V = defaultdict(float)


def update_mc(
    episode_states,
    reward
):

    visited = set()

    for state in episode_states:

        if state not in visited:

            returns[state].append(
                reward
            )

            V[state] = (
                sum(returns[state]) /
                len(returns[state])
            )

            visited.add(state)

    return visited
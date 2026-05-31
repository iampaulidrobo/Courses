import random


class MCAgent:

    def __init__(
        self,
        Q,
        epsilon=0.1
    ):

        self.Q = Q

        self.epsilon = epsilon

    def select_action(
        self,
        state,
        legal_moves
    ):

        # Exploration
        if random.random() < self.epsilon:

            return random.choice(
                legal_moves
            )

        # Exploitation
        best_action = None
        best_value = float("-inf")

        for action in legal_moves:

            value = self.Q[state][action]

            if value > best_value:

                best_value = value
                best_action = action

        return best_action


# What it does

# Suppose:

# Q[state][3] = 0.2
# Q[state][5] = 0.9
# Q[state][7] = 0.1

# and

# epsilon = 0.1

# Then:

# 10% of the time
# random.choice(
#     legal_moves
# )

# Explore.

# 90% of the time

# Choose:

# action = 5

# because:

# Q[state][5]

# is largest.
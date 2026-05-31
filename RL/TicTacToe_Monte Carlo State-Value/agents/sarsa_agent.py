import random


class SARSAAgent:

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
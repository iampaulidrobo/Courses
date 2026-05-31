import random

class RandomAgent:

    def select_action(self, state, legal_moves):

        return random.choice(
            legal_moves
        )
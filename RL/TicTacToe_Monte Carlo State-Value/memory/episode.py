class Episode:

    def __init__(self):

        self.states = []
        self.actions = []
        self.rewards = []

    def add(
        self,
        state,
        action=None,
        reward=None
    ):

        self.states.append(state)

        if action is not None:
            self.actions.append(action)

        if reward is not None:
            self.rewards.append(reward)

    def clear(self):

        self.states.clear()
        self.actions.clear()
        self.rewards.clear()
class Episode:

    def __init__(self):

        # Stores:
        # [
        #   (state, action),
        #   (state, action),
        #   ...
        # ]
        self.state_actions = []

    def add(
        self,
        state,
        action
    ):

        self.state_actions.append(
            (state, action)
        )

    def clear(self):

        self.state_actions.clear()

    def __len__(self):

        return len(
            self.state_actions
        )

    def __getitem__(
        self,
        index
    ):

        return self.state_actions[
            index
        ]
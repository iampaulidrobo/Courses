class TicTacToeEnv:

    def __init__(self):
        self.reset()

    def reset(self):

        self.board = [' '] * 9
        self.current_player = 'X'

        return self.get_state()

    def get_state(self):
        return tuple(self.board)

    def available_moves(self):

        return [
            i for i in range(9)
            if self.board[i] == ' '
        ]

    def switch_player(self):

        self.current_player = (
            'O'
            if self.current_player == 'X'
            else 'X'
        )

    def check_winner(self):

        wins = [
            [0,1,2],
            [3,4,5],
            [6,7,8],
            [0,3,6],
            [1,4,7],
            [2,5,8],
            [0,4,8],
            [2,4,6]
        ]

        for combo in wins:

            a,b,c = combo

            if (
                self.board[a] ==
                self.board[b] ==
                self.board[c] != ' '
            ):
                return self.board[a]

        if ' ' not in self.board:
            return "Draw"

        return None

    def step(self, action):

        self.board[action] = self.current_player

        winner = self.check_winner()

        done = winner is not None

        reward = 0

        if done:

            if winner == 'X':
                reward = 1

            elif winner == 'O':
                reward = -1

            else:
                reward = 0

        next_state = self.get_state()

        if not done:
            self.switch_player()

        return next_state, reward, done, winner
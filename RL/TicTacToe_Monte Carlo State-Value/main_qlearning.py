import pygame

from config import *

from environment.tictactoe_env import TicTacToeEnv

from agents.sarsa_agent import SARSAAgent

from rl.qlearning import (
    update_qlearning,
    Q,
    total_state_actions
)

from utils.qlearning_storage import (
    save_learning_data
)

from ui.renderer import (
    draw_grid,
    draw_board,
    draw_info
)

pygame.init()

screen = pygame.display.set_mode(
    (WIDTH, HEIGHT)
)

pygame.display.set_caption(
    "Q-Learning"
)

clock = pygame.time.Clock()

env = TicTacToeEnv()

agent = SARSAAgent(
    Q,
    epsilon=0.1
)
episode_count = 0

xwins = 0
owins = 0
draws = 0

running = True

winner_text = "Press SPACE"

while running:

    # =====================================
    # WAIT FOR SPACE
    # =====================================

    waiting = True

    while waiting and running:

        screen.fill(WHITE)

        draw_grid(screen)

        draw_info(
            screen,
            episode_count,
            "WAITING",
            winner_text,
            xwins,
            owins,
            draws
        )

        pygame.display.update()

        for event in pygame.event.get():

            if event.type == pygame.QUIT:

                running = False
                waiting = False

            elif event.type == pygame.KEYDOWN:

                if event.key == pygame.K_SPACE:

                    waiting = False

                elif event.key == pygame.K_ESCAPE:

                    running = False
                    waiting = False

        clock.tick(30)

    if not running:
        break

    # =====================================
    # START EPISODE
    # =====================================

    episode_count += 1

    state = env.reset()

    done = False

    winner = None

    # =====================================
    # PLAY EPISODE
    # =====================================

    while not done and running:

        for event in pygame.event.get():

            if event.type == pygame.QUIT:

                running = False

            elif (
                event.type == pygame.KEYDOWN
                and event.key == pygame.K_ESCAPE
            ):

                running = False

        if not running:
            break

        legal_moves = env.available_moves()

        action = agent.select_action(
            state,
            legal_moves
        )

        next_state, reward, done, winner = (
            env.step(action)
        )

        # =====================================
        # Q-LEARNING UPDATE
        # =====================================

        update_qlearning(
            state,
            action,
            reward,
            next_state,
            done
        )

        screen.fill(WHITE)

        draw_grid(screen)

        draw_board(
            screen,
            env.board
        )

        draw_info(
            screen,
            episode_count,
            env.current_player,
            "Playing",
            xwins,
            owins,
            draws
        )

        pygame.display.update()

        clock.tick(FPS)

        state = next_state

    if not running:
        break

    # =====================================
    # SAVE LEARNING
    # =====================================

    save_learning_data(
        Q
    )

    # =====================================
    # UPDATE STATS
    # =====================================

    if winner == "X":

        xwins += 1

        winner_text = "Winner: X"

    elif winner == "O":

        owins += 1

        winner_text = "Winner: O"

    else:

        draws += 1

        winner_text = "Draw"

    print("\n========================")
    print("Episode :", episode_count)
    print("Winner  :", winner)
    print("Reward  :", reward)
    print(
        "State-Action Pairs:",
        total_state_actions()
    )
    print("========================\n")

    # =====================================
    # FINAL BOARD
    # =====================================

    screen.fill(WHITE)

    draw_grid(screen)

    draw_board(
        screen,
        env.board
    )

    draw_info(
        screen,
        episode_count,
        "DONE",
        winner_text,
        xwins,
        owins,
        draws
    )

    pygame.display.update()

pygame.quit()
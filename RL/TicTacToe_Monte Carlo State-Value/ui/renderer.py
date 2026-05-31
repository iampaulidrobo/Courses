import pygame

from config import *

pygame.init()

font = pygame.font.SysFont(
    None,
    80
)

small_font = pygame.font.SysFont(
    None,
    28
)


def draw_grid(screen):

    for i in range(1, GRID_SIZE):

        pygame.draw.line(
            screen,
            BLACK,
            (0, i * CELL_SIZE),
            (WIDTH, i * CELL_SIZE),
            4
        )

        pygame.draw.line(
            screen,
            BLACK,
            (i * CELL_SIZE, 0),
            (i * CELL_SIZE, WIDTH),
            4
        )


def draw_board(
    screen,
    board
):

    for idx, value in enumerate(board):

        row = idx // 3
        col = idx % 3

        x = (
            col * CELL_SIZE +
            CELL_SIZE // 2
        )

        y = (
            row * CELL_SIZE +
            CELL_SIZE // 2
        )

        if value == 'X':

            text = font.render(
                'X',
                True,
                RED
            )

            rect = text.get_rect(
                center=(x, y)
            )

            screen.blit(
                text,
                rect
            )

        elif value == 'O':

            text = font.render(
                'O',
                True,
                BLUE
            )

            rect = text.get_rect(
                center=(x, y)
            )

            screen.blit(
                text,
                rect
            )


def draw_info(
    screen,
    episode,
    player,
    result,
    xwins,
    owins,
    draws
):

    pygame.draw.rect(
        screen,
        GRAY,
        (0, WIDTH, WIDTH, 120)
    )

    texts = [
        f"Episode: {episode}",
        f"Player: {player}",
        f"Result: {result}",
        f"X Wins: {xwins}",
        f"O Wins: {owins}",
        f"Draws: {draws}"
    ]

    for i, t in enumerate(texts):

        txt = small_font.render(
            t,
            True,
            BLACK
        )

        screen.blit(
            txt,
            (20, WIDTH + 10 + i * 18)
        )
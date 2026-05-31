import pygame
import numpy as np
import sys

# =========================================================
# GRID WORLD + VALUE ITERATION VISUALIZATION (PYGAME)
# =========================================================

pygame.init()

# =========================================================
# GRID SETTINGS
# =========================================================

ROWS = 5
COLS = 5
CELL_SIZE = 120

WIDTH = COLS * CELL_SIZE
HEIGHT = ROWS * CELL_SIZE

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Bellman Value Iteration - Drone Grid")

font = pygame.font.SysFont("Arial", 24, bold=True)
small_font = pygame.font.SysFont("Arial", 18)

clock = pygame.time.Clock()

# =========================================================
# COLORS
# =========================================================

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GRAY = (180, 180, 180)
RED = (220, 80, 80)
GREEN = (80, 220, 80)
BLUE = (80, 120, 255)
YELLOW = (255, 220, 50)

# =========================================================
# ENVIRONMENT
# =========================================================

start = (0, 0)
goal = (4, 4)

obstacles = [
    (1, 1),
    (1, 2),
    (3, 1),
    (3, 3)
]

# =========================================================
# RL PARAMETERS
# =========================================================

gamma = 0.9

move_reward = -1
goal_reward = 100
invalid_reward = -5

# =========================================================
# VALUE TABLE
# =========================================================

values = np.zeros((ROWS, COLS))

values[goal] = goal_reward

# =========================================================
# ACTIONS
# =========================================================

actions = {
    "UP": (-1, 0),
    "DOWN": (1, 0),
    "LEFT": (0, -1),
    "RIGHT": (0, 1)
}

# =========================================================
# HELPER FUNCTIONS
# =========================================================

def is_valid(r, c):

    if r < 0 or r >= ROWS:
        return False

    if c < 0 or c >= COLS:
        return False

    if (r, c) in obstacles:
        return False

    return True


def normalize_value(v, min_v, max_v):

    if max_v - min_v == 0:
        return 0

    return (v - min_v) / (max_v - min_v)


# =========================================================
# BELLMAN UPDATE
# =========================================================

iteration = 0

def value_iteration_step():

    global values
    global iteration

    new_values = values.copy()

    for r in range(ROWS):
        for c in range(COLS):

            if (r, c) in obstacles:
                continue

            if (r, c) == goal:
                continue

            action_values = []

            for action in actions.values():

                nr = r + action[0]
                nc = c + action[1]

                # Invalid move
                if not is_valid(nr, nc):

                    reward = invalid_reward
                    next_value = values[r, c]

                else:

                    if (nr, nc) == goal:
                        reward = goal_reward
                    else:
                        reward = move_reward

                    next_value = values[nr, nc]

                candidate_value = reward + gamma * next_value

                action_values.append(candidate_value)

            best_value = max(action_values)

            new_values[r, c] = best_value

    values = new_values
    iteration += 1


# =========================================================
# POLICY EXTRACTION
# =========================================================

def get_best_action(r, c):

    best_action = None
    best_value = -1e9

    for name, action in actions.items():

        nr = r + action[0]
        nc = c + action[1]

        if not is_valid(nr, nc):
            continue

        value = values[nr, nc]

        if value > best_value:
            best_value = value
            best_action = name

    return best_action


# =========================================================
# DRAWING
# =========================================================

def draw():

    screen.fill(WHITE)

    valid_values = []

    for r in range(ROWS):
        for c in range(COLS):

            if (r, c) not in obstacles:
                valid_values.append(values[r, c])

    min_v = min(valid_values)
    max_v = max(valid_values)

    for r in range(ROWS):
        for c in range(COLS):

            x = c * CELL_SIZE
            y = r * CELL_SIZE

            rect = pygame.Rect(x, y, CELL_SIZE, CELL_SIZE)

            # =================================================
            # OBSTACLE
            # =================================================

            if (r, c) in obstacles:

                pygame.draw.rect(screen, BLACK, rect)

                text = font.render("X", True, WHITE)
                screen.blit(
                    text,
                    (
                        x + CELL_SIZE//2 - text.get_width()//2,
                        y + CELL_SIZE//2 - text.get_height()//2
                    )
                )

            # =================================================
            # GOAL
            # =================================================

            elif (r, c) == goal:

                pygame.draw.rect(screen, GREEN, rect)

                text = font.render("G", True, BLACK)

                screen.blit(
                    text,
                    (
                        x + 10,
                        y + 10
                    )
                )

                value_text = small_font.render(
                    f"{values[r,c]:.1f}",
                    True,
                    BLACK
                )

                screen.blit(
                    value_text,
                    (
                        x + 10,
                        y + 50
                    )
                )

            # =================================================
            # NORMAL CELL
            # =================================================

            else:

                normalized = normalize_value(values[r, c], min_v, max_v)

                color_strength = int(255 * normalized)

                color = (
                    255 - color_strength,
                    255,
                    255 - color_strength
                )

                pygame.draw.rect(screen, color, rect)

                # Draw value
                value_text = small_font.render(
                    f"{values[r,c]:.1f}",
                    True,
                    BLACK
                )

                screen.blit(
                    value_text,
                    (
                        x + 10,
                        y + 10
                    )
                )

                # Draw policy arrow
                action = get_best_action(r, c)

                arrow = ""

                if action == "UP":
                    arrow = "↑"

                elif action == "DOWN":
                    arrow = "↓"

                elif action == "LEFT":
                    arrow = "←"

                elif action == "RIGHT":
                    arrow = "→"

                arrow_text = font.render(arrow, True, BLUE)

                screen.blit(
                    arrow_text,
                    (
                        x + CELL_SIZE//2 - arrow_text.get_width()//2,
                        y + CELL_SIZE//2 - arrow_text.get_height()//2 + 15
                    )
                )

            # Draw border
            pygame.draw.rect(screen, GRAY, rect, 2)

    # =====================================================
    # ITERATION TEXT
    # =====================================================

    info_text = font.render(
        f"Iteration: {iteration}",
        True,
        RED
    )

    screen.blit(info_text, (10, 10))

    pygame.display.update()


# =========================================================
# MAIN LOOP
# =========================================================

running = True
auto_run = False

while running:

    clock.tick(30)

    for event in pygame.event.get():

        if event.type == pygame.QUIT:
            running = False

        if event.type == pygame.KEYDOWN:

            # SPACE -> single Bellman iteration
            if event.key == pygame.K_SPACE:
                value_iteration_step()

            # A -> auto run
            if event.key == pygame.K_a:
                auto_run = not auto_run

            # R -> reset
            if event.key == pygame.K_r:

                values = np.zeros((ROWS, COLS))
                values[goal] = goal_reward

                iteration = 0

    if auto_run:
        value_iteration_step()
        pygame.time.delay(300)

    draw()

pygame.quit()
sys.exit()
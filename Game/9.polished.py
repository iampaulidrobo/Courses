import pygame
import os
import random

pygame.init()

# ======================
# Window & Grid Settings
# ======================
WIDTH, HEIGHT = 1200, 600
CELL_SIZE = 40
ROWS = HEIGHT // CELL_SIZE
COLS = WIDTH // CELL_SIZE

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Maze Game")

clock = pygame.time.Clock()

# =========
# Colors
# =========
BG = (30, 30, 30)
TEXT = (255, 255, 255)

# =========
# Fonts
# =========
font = pygame.font.SysFont(None, 36)
big_font = pygame.font.SysFont(None, 48)

# ======================
# Load Robot Images
# ======================
ROBOT_FOLDER = "robots"
robot_images = []

for file in sorted(os.listdir(ROBOT_FOLDER)):
    if file.lower().endswith((".png", ".jpg", ".jpeg")):
        img = pygame.image.load(os.path.join(ROBOT_FOLDER, file)).convert_alpha()
        normal = pygame.transform.scale(img, (CELL_SIZE, CELL_SIZE))
        hover = pygame.transform.scale(img, (CELL_SIZE * 4, CELL_SIZE * 4))
        robot_images.append((normal, hover, file))

TOTAL_ROBOTS = len(robot_images)

# ======================
# RANDOM MAZE GENERATOR
# ======================
def generate_maze(rows, cols):
    maze = [[1 for _ in range(cols)] for _ in range(rows)]

    def carve(x, y):
        maze[y][x] = 0
        directions = [(2,0), (-2,0), (0,2), (0,-2)]
        random.shuffle(directions)

        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if 0 <= nx < cols and 0 <= ny < rows and maze[ny][nx] == 1:
                maze[y + dy//2][x + dx//2] = 0
                carve(nx, ny)

    carve(0, 0)
    maze[rows - 1][cols - 1] = 0
    return maze

def random_wall_color():
    return (
        random.randint(120, 220),
        random.randint(80, 180),
        random.randint(80, 180)
    )

maze = generate_maze(ROWS, COLS)
WALL_COLOR = random_wall_color()

# ======================
# Start & End
# ======================
start_cell = (0, 0)
end_cell = (COLS - 1, ROWS - 1)

robot_index = 0
robot_x, robot_y = start_cell
game_done = False

def can_move(x, y):
    return 0 <= x < COLS and 0 <= y < ROWS and maze[y][x] == 0

# ======================
# Draw polished markers
# ======================
def draw_glow_circle(surface, center, radius, color):
    for i in range(6, 0, -1):
        glow_surf = pygame.Surface((radius*4, radius*4), pygame.SRCALPHA)
        pygame.draw.circle(
            glow_surf,
            (*color, 25),
            (radius*2, radius*2),
            radius + i*3
        )
        surface.blit(glow_surf, (center[0]-radius*2, center[1]-radius*2))

    pygame.draw.circle(surface, color, center, radius)

# ======================
# Main Loop
# ======================
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        if event.type == pygame.KEYDOWN and not game_done:
            nx, ny = robot_x, robot_y

            if event.key == pygame.K_LEFT:
                nx -= 1
            elif event.key == pygame.K_RIGHT:
                nx += 1
            elif event.key == pygame.K_UP:
                ny -= 1
            elif event.key == pygame.K_DOWN:
                ny += 1

            if can_move(nx, ny):
                robot_x, robot_y = nx, ny

            if (robot_x, robot_y) == end_cell:
                robot_index += 1

                if robot_index >= TOTAL_ROBOTS:
                    game_done = True
                else:
                    maze = generate_maze(ROWS, COLS)
                    WALL_COLOR = random_wall_color()
                    robot_x, robot_y = start_cell

    screen.fill(BG)

    # Draw maze
    for y in range(ROWS):
        for x in range(COLS):
            if maze[y][x] == 1:
                pygame.draw.rect(
                    screen,
                    WALL_COLOR,
                    (x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
                )

    # Draw START & END (polished)
    start_center = (
        start_cell[0]*CELL_SIZE + CELL_SIZE//2,
        start_cell[1]*CELL_SIZE + CELL_SIZE//2
    )
    end_center = (
        end_cell[0]*CELL_SIZE + CELL_SIZE//2,
        end_cell[1]*CELL_SIZE + CELL_SIZE//2
    )

    draw_glow_circle(screen, start_center, CELL_SIZE//3, (0, 220, 120))
    draw_glow_circle(screen, end_center, CELL_SIZE//3, (80, 170, 255))

    # Draw robot
    if not game_done:
        normal, hover, name = robot_images[robot_index]

        robot_rect = pygame.Rect(
            robot_x * CELL_SIZE,
            robot_y * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
        )

        if robot_rect.collidepoint(pygame.mouse.get_pos()):
            hover_rect = hover.get_rect(center=robot_rect.center)
            screen.blit(hover, hover_rect.topleft)
        else:
            screen.blit(normal, robot_rect.topleft)

        label = font.render(f"Robot: {name}", True, TEXT)
        screen.blit(label, (10, 10))
    else:
        msg = big_font.render("All robots completed their mazes!", True, TEXT)
        screen.blit(msg, (WIDTH // 2 - msg.get_width() // 2, 20))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

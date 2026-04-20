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
BULLET_COLOR = (255, 220, 100)

# =========
# Fonts
# =========
font = pygame.font.SysFont(None, 36)
big_font = pygame.font.SysFont(None, 48)

# ======================
# Load Robot Images
# ======================
ROBOT_FOLDER = "faces"
robot_images = []

for file in sorted(os.listdir(ROBOT_FOLDER)):
    if file.lower().endswith((".png", ".jpg", ".jpeg")):
        img = pygame.image.load(os.path.join(ROBOT_FOLDER, file)).convert_alpha()
        normal = pygame.transform.scale(img, (CELL_SIZE, CELL_SIZE))
        hover = pygame.transform.scale(img, (CELL_SIZE * 2, CELL_SIZE * 2))
        robot_images.append((normal, hover, file))

TOTAL_ROBOTS = len(robot_images)

# ======================
# RANDOM MAZE GENERATOR
# ======================
def generate_maze(rows, cols):
    maze = [[1 for _ in range(cols)] for _ in range(rows)]

    def carve(x, y):
        maze[y][x] = 0
        dirs = [(2,0), (-2,0), (0,2), (0,-2)]
        random.shuffle(dirs)
        for dx, dy in dirs:
            nx, ny = x + dx, y + dy
            if 0 <= nx < cols and 0 <= ny < rows and maze[ny][nx] == 1:
                maze[y + dy//2][x + dx//2] = 0
                carve(nx, ny)

    carve(0, 0)
    maze[rows-1][cols-1] = 0
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
# Wall HP (5 shots)
# ======================
def init_wall_hp():
    hp = [[0 for _ in range(COLS)] for _ in range(ROWS)]
    for y in range(ROWS):
        for x in range(COLS):
            if maze[y][x] == 1:
                hp[y][x] = 5
    return hp

wall_hp = init_wall_hp()

# ======================
# Start & End
# ======================
start_cell = (0, 0)
end_cell = (COLS - 1, ROWS - 1)

robot_x, robot_y = start_cell
robot_index = 0
game_done = False

last_dir = (1, 0)  # default shooting direction
bullets = []

def can_move(x, y):
    return 0 <= x < COLS and 0 <= y < ROWS and maze[y][x] == 0

# ======================
# Glow circles
# ======================
def draw_glow_circle(surface, center, radius, color):
    for i in range(5, 0, -1):
        glow = pygame.Surface((radius*4, radius*4), pygame.SRCALPHA)
        pygame.draw.circle(glow, (*color, 20),
                           (radius*2, radius*2),
                           radius + i*3)
        surface.blit(glow, (center[0]-radius*2, center[1]-radius*2))
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
                last_dir = (-1, 0)
            elif event.key == pygame.K_RIGHT:
                nx += 1
                last_dir = (1, 0)
            elif event.key == pygame.K_UP:
                ny -= 1
                last_dir = (0, -1)
            elif event.key == pygame.K_DOWN:
                ny += 1
                last_dir = (0, 1)

            elif event.key == pygame.K_SPACE:
                bullets.append({
                    "x": robot_x,
                    "y": robot_y,
                    "dx": last_dir[0],
                    "dy": last_dir[1]
                })

            if can_move(nx, ny):
                robot_x, robot_y = nx, ny

            if (robot_x, robot_y) == end_cell:
                robot_index += 1
                if robot_index >= TOTAL_ROBOTS:
                    game_done = True
                else:
                    maze = generate_maze(ROWS, COLS)
                    wall_hp = init_wall_hp()
                    WALL_COLOR = random_wall_color()
                    robot_x, robot_y = start_cell
                    bullets.clear()

    # ======================
    # Update bullets
    # ======================
    for b in bullets[:]:
        b["x"] += b["dx"]
        b["y"] += b["dy"]

        if not (0 <= b["x"] < COLS and 0 <= b["y"] < ROWS):
            bullets.remove(b)
            continue

        if maze[b["y"]][b["x"]] == 1:
            wall_hp[b["y"]][b["x"]] -= 1
            if wall_hp[b["y"]][b["x"]] <= 0:
                maze[b["y"]][b["x"]] = 0
            bullets.remove(b)

    # ======================
    # Draw
    # ======================
    screen.fill(BG)

    # Maze
    for y in range(ROWS):
        for x in range(COLS):
            if maze[y][x] == 1:
                pygame.draw.rect(
                    screen, WALL_COLOR,
                    (x*CELL_SIZE, y*CELL_SIZE, CELL_SIZE, CELL_SIZE)
                )

    # Start & End
    draw_glow_circle(
        screen,
        (CELL_SIZE//2, CELL_SIZE//2),
        CELL_SIZE//3,
        (0, 220, 120)
    )
    draw_glow_circle(
        screen,
        (end_cell[0]*CELL_SIZE + CELL_SIZE//2,
         end_cell[1]*CELL_SIZE + CELL_SIZE//2),
        CELL_SIZE//3,
        (80, 170, 255)
    )

    # Bullets
    for b in bullets:
        pygame.draw.circle(
            screen,
            BULLET_COLOR,
            (b["x"]*CELL_SIZE + CELL_SIZE//2,
             b["y"]*CELL_SIZE + CELL_SIZE//2),
            6
        )

    # Robot
    if not game_done:
        normal, hover, name = robot_images[robot_index]
        robot_rect = pygame.Rect(
            robot_x*CELL_SIZE,
            robot_y*CELL_SIZE,
            CELL_SIZE, CELL_SIZE
        )

        if robot_rect.collidepoint(pygame.mouse.get_pos()):
            r = hover.get_rect(center=robot_rect.center)
            screen.blit(hover, r.topleft)
        else:
            screen.blit(normal, robot_rect.topleft)

        screen.blit(font.render(f"Robot: {name}", True, TEXT), (10, 10))
        screen.blit(font.render("SPACE = Shoot ", True, TEXT), (10, 45))
    else:
        msg = big_font.render("All robots completed their mazes!", True, TEXT)
        screen.blit(msg, (WIDTH//2 - msg.get_width()//2, 20))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

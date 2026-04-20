import pygame

pygame.init()

# ======================
# Window & Grid Settings
# ======================
WIDTH, HEIGHT = 1200, 600
CELL_SIZE = 40
ROWS = HEIGHT // CELL_SIZE   # 15
COLS = WIDTH // CELL_SIZE    # 30

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Maze Game")

clock = pygame.time.Clock()

# =========
# Colors
# =========
BG = (30, 30, 30)
WALL = (200, 50, 50)
START = (0, 200, 0)
END = (50, 150, 255)
TEXT = (255, 255, 255)

# =========
# Font
# =========
font = pygame.font.SysFont(None, 48)

# ======================
# Load Robot Images
# ======================
robot_img = pygame.image.load("robots/user.jpeg").convert_alpha()
robot_img_normal = pygame.transform.scale(robot_img, (CELL_SIZE, CELL_SIZE))
robot_img_hover = pygame.transform.scale(
    robot_img, (CELL_SIZE * 4, CELL_SIZE * 4)
)

# ======================
# Maze (15 x 30)
# 0 = free, 1 = wall
# MANY paths
# ======================
maze = [
    [0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0],
    [1,1,1,0,1,1,0,1,1,0,1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,1,1,1,1,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
    [0,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0],
    [1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,0],
    [0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
    [0,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0,1,1,0],
    [0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0],
    [1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,1,0],
    [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
    [0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
]

# ======================
# Start & End
# ======================
start_cell = (0, 0)
end_cell = (29, 14)

robot_x, robot_y = start_cell
game_won = False

def can_move(x, y):
    return 0 <= x < COLS and 0 <= y < ROWS and maze[y][x] == 0

# ======================
# Main Loop
# ======================
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        if event.type == pygame.KEYDOWN and not game_won:
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
                game_won = True

    screen.fill(BG)

    # Draw walls
    for y in range(ROWS):
        for x in range(COLS):
            if maze[y][x] == 1:
                pygame.draw.rect(
                    screen, WALL,
                    (x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
                )

    # Draw START & END
    pygame.draw.rect(screen, START,
        (start_cell[0]*CELL_SIZE, start_cell[1]*CELL_SIZE, CELL_SIZE, CELL_SIZE))
    pygame.draw.rect(screen, END,
        (end_cell[0]*CELL_SIZE, end_cell[1]*CELL_SIZE, CELL_SIZE, CELL_SIZE))

    # Robot hover logic
    robot_rect = pygame.Rect(
        robot_x * CELL_SIZE, robot_y * CELL_SIZE, CELL_SIZE, CELL_SIZE
    )
    mouse_pos = pygame.mouse.get_pos()

    if robot_rect.collidepoint(mouse_pos):
        hover_rect = robot_img_hover.get_rect(center=robot_rect.center)
        screen.blit(robot_img_hover, hover_rect.topleft)
    else:
        screen.blit(robot_img_normal, robot_rect.topleft)

    # Win message
    if game_won:
        msg = font.render("You reached the goal!", True, TEXT)
        screen.blit(msg, (WIDTH//2 - msg.get_width()//2, 20))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

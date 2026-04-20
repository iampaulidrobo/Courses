import pygame

pygame.init()

# Window & grid
WIDTH, HEIGHT = 600, 400
CELL_SIZE = 40
ROWS = HEIGHT // CELL_SIZE
COLS = WIDTH // CELL_SIZE

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Grid Maze")

clock = pygame.time.Clock()

# Colors
BG = (30, 30, 30)
GRID = (80, 80, 80)
WALL = (200, 50, 50)
START = (0, 200, 0)
END = (50, 150, 255)
ROBOT = (255, 255, 0)
TEXT = (255, 255, 255)

# Font
font = pygame.font.SysFont(None, 36)

# Maze (0 = empty, 1 = wall)
maze = [
    [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
    [1,1,0,1,0,1,1,1,1,1,1,1,0,1,0],
    [0,0,0,0,0,0,0,0,0,0,0,1,0,1,0],
    [0,1,1,1,1,1,1,1,1,1,0,1,0,0,0],
    [0,0,0,0,0,0,0,0,0,1,0,1,1,1,0],
    [0,1,1,1,1,1,1,1,0,1,0,0,0,0,0],
    [0,0,0,0,0,0,0,1,0,1,1,1,1,1,0],
    [0,1,1,1,1,1,0,1,0,0,0,0,0,1,0],
    [0,0,0,0,0,0,0,0,0,1,1,1,0,0,0],
    [0,1,1,1,1,1,1,1,0,0,0,1,1,1,0],
]

start_cell = (0, 0)
end_cell = (14, 9)

robot_x, robot_y = start_cell
game_won = False

def can_move(x, y):
    if 0 <= x < COLS and 0 <= y < ROWS:
        return maze[y][x] == 0
    return False

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        if event.type == pygame.KEYDOWN and not game_won:
            next_x, next_y = robot_x, robot_y

            if event.key == pygame.K_LEFT:
                next_x -= 1
            elif event.key == pygame.K_RIGHT:
                next_x += 1
            elif event.key == pygame.K_UP:
                next_y -= 1
            elif event.key == pygame.K_DOWN:
                next_y += 1

            if can_move(next_x, next_y):
                robot_x, robot_y = next_x, next_y

            # Check win condition
            if (robot_x, robot_y) == end_cell:
                game_won = True

    screen.fill(BG)

    # Draw walls
    for row in range(ROWS):
        for col in range(COLS):
            if maze[row][col] == 1:
                pygame.draw.rect(
                    screen, WALL,
                    (col * CELL_SIZE, row * CELL_SIZE, CELL_SIZE, CELL_SIZE)
                )

    # Draw START & END
    pygame.draw.rect(
        screen, START,
        (start_cell[0]*CELL_SIZE, start_cell[1]*CELL_SIZE, CELL_SIZE, CELL_SIZE)
    )
    pygame.draw.rect(
        screen, END,
        (end_cell[0]*CELL_SIZE, end_cell[1]*CELL_SIZE, CELL_SIZE, CELL_SIZE)
    )

    # Draw ROBOT
    pygame.draw.rect(
        screen, ROBOT,
        (robot_x*CELL_SIZE, robot_y*CELL_SIZE, CELL_SIZE, CELL_SIZE)
    )

    # Draw grid
    for x in range(0, WIDTH, CELL_SIZE):
        pygame.draw.line(screen, GRID, (x, 0), (x, HEIGHT))
    for y in range(0, HEIGHT, CELL_SIZE):
        pygame.draw.line(screen, GRID, (0, y), (WIDTH, y))

    # Win message
    if game_won:
        msg = font.render("You reached the goal!", True, TEXT)
        screen.blit(msg, (WIDTH//2 - msg.get_width()//2, HEIGHT//2 - 20))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

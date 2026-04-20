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

# Maze layout (0 = empty, 1 = wall)
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

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    screen.fill(BG)

    # Draw maze cells
    for row in range(ROWS):
        for col in range(COLS):
            x = col * CELL_SIZE
            y = row * CELL_SIZE

            if maze[row][col] == 1:
                pygame.draw.rect(screen, WALL, (x, y, CELL_SIZE, CELL_SIZE))

    # Draw START
    sx, sy = start_cell
    pygame.draw.rect(
        screen, START,
        (sx * CELL_SIZE, sy * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    )

    # Draw END
    ex, ey = end_cell
    pygame.draw.rect(
        screen, END,
        (ex * CELL_SIZE, ey * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    )

    # Grid lines
    for x in range(0, WIDTH, CELL_SIZE):
        pygame.draw.line(screen, GRID, (x, 0), (x, HEIGHT))
    for y in range(0, HEIGHT, CELL_SIZE):
        pygame.draw.line(screen, GRID, (0, y), (WIDTH, y))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

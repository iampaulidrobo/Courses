import pygame

pygame.init()

# Window size
WIDTH, HEIGHT = 600, 400
CELL_SIZE = 40

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Grid")

clock = pygame.time.Clock()

# Colors
BG = (30, 30, 30)
GRID = (80, 80, 80)

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    screen.fill(BG)

    # Draw vertical grid lines
    for x in range(0, WIDTH, CELL_SIZE):
        pygame.draw.line(screen, GRID, (x, 0), (x, HEIGHT))

    # Draw horizontal grid lines
    for y in range(0, HEIGHT, CELL_SIZE):
        pygame.draw.line(screen, GRID, (0, y), (WIDTH, y))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()

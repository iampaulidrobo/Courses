from mtcnn import MTCNN
import cv2
import os

# Load image
img = cv2.imread("group.jpeg")
if img is None:
    raise FileNotFoundError("Image not found")

# Convert to RGB
rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

# Initialize detector
detector = MTCNN()

# Detect faces
faces = detector.detect_faces(rgb)

print("Faces detected:", len(faces))

# Create output folder
os.makedirs("faces", exist_ok=True)

# Crop & save faces
for i, face in enumerate(faces):
    x, y, w, h = face['box']

    # Fix negative coordinates (MTCNN quirk)
    x, y = max(0, x), max(0, y)

    face_img = img[y:y+h, x:x+w]
    cv2.imwrite(f"faces/face_{i+1}.jpg", face_img)

print("Saved faces to /faces/")

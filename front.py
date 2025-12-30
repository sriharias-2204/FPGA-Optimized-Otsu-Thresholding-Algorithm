import cv2
import os

current_dir = os.path.dirname(os.path.abspath(__file__))

input_filename = os.path.join(current_dir, 'image.png')
output_filename = os.path.join(current_dir, 'image_in.hex')

img = cv2.imread(input_filename, cv2.IMREAD_GRAYSCALE)

if img is None:
    print(f"Error: Could not find {input_filename}")
else:
    img = cv2.resize(img, (512, 512))

    with open(output_filename, 'w') as f:
        for pixel in img.flatten():
            f.write(f"{pixel:02x}\n")
    
    val, _ = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    print(f"Success! Hex file saved at: {output_filename}")
    print(f"OpenCV (Golden) Threshold: {val}")

import os
from PIL import Image

def convert_gif_to_png(source_dir):
	for root, dirs, files in os.walk(source_dir):
		for file in files:
			if file.lower().endswith('.jpg'):
				gif_path = os.path.join(root, file)
				png_path = os.path.splitext(gif_path)[0] + '.png'
				
				with Image.open(gif_path) as img:
					img.save(png_path, 'PNG')

if __name__ == "__main__":
	source_directory = 'Themes'
	convert_gif_to_png(source_directory)
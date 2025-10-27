from PIL import Image, ImageDraw, ImageFont
import os

# Create the assets/icon directory if it doesn't exist
os.makedirs('assets/icon', exist_ok=True)

# Define colors matching Veda AI theme
PURPLE = '#6C63FF'
CORAL = '#FF6B6B'
WHITE = '#FFFFFF'

def create_app_icon():
    """Create the main app icon with a heart symbol"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background circle
    for i in range(size//2):
        alpha = int(255 * (1 - i/(size//2)))
        color = (*hex_to_rgb(PURPLE), alpha)
        draw.ellipse([i, i, size-i, size-i], fill=color)
    
    # Draw solid background circle
    margin = size // 8
    draw.ellipse([margin, margin, size-margin, size-margin], fill=PURPLE)
    
    # Draw heart shape (simplified)
    heart_color = WHITE
    heart_margin = size // 3
    heart_size = size - 2 * heart_margin
    
    # Heart is made of two circles and a triangle
    circle_r = heart_size // 4
    cx_left = heart_margin + circle_r
    cx_right = size - heart_margin - circle_r
    cy = heart_margin + circle_r
    
    # Draw two circles for top of heart
    draw.ellipse([cx_left - circle_r, cy - circle_r, 
                  cx_left + circle_r, cy + circle_r], fill=heart_color)
    draw.ellipse([cx_right - circle_r, cy - circle_r, 
                  cx_right + circle_r, cy + circle_r], fill=heart_color)
    
    # Draw triangle for bottom of heart
    bottom_x = size // 2
    bottom_y = size - heart_margin
    draw.polygon([
        (cx_left - circle_r, cy),
        (cx_right + circle_r, cy),
        (bottom_x, bottom_y)
    ], fill=heart_color)
    
    # Fill the middle
    draw.rectangle([cx_left - circle_r, cy, cx_right + circle_r, bottom_y], fill=heart_color)
    
    img.save('assets/icon/app_icon.png')
    print('✓ Created app_icon.png')

def create_foreground_icon():
    """Create the adaptive foreground icon"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw heart shape (white)
    heart_color = WHITE
    heart_margin = size // 3
    heart_size = size - 2 * heart_margin
    
    circle_r = heart_size // 4
    cx_left = heart_margin + circle_r
    cx_right = size - heart_margin - circle_r
    cy = heart_margin + circle_r
    
    # Draw two circles for top of heart
    draw.ellipse([cx_left - circle_r, cy - circle_r, 
                  cx_left + circle_r, cy + circle_r], fill=heart_color)
    draw.ellipse([cx_right - circle_r, cy - circle_r, 
                  cx_right + circle_r, cy + circle_r], fill=heart_color)
    
    # Draw triangle for bottom of heart
    bottom_x = size // 2
    bottom_y = size - heart_margin
    draw.polygon([
        (cx_left - circle_r, cy),
        (cx_right + circle_r, cy),
        (bottom_x, bottom_y)
    ], fill=heart_color)
    
    # Fill the middle
    draw.rectangle([cx_left - circle_r, cy, cx_right + circle_r, bottom_y], fill=heart_color)
    
    img.save('assets/icon/app_icon_foreground.png')
    print('✓ Created app_icon_foreground.png')

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

if __name__ == '__main__':
    print('Generating Veda AI app icons...')
    create_app_icon()
    create_foreground_icon()
    print('\n✅ Icon generation complete!')
    print('Run: flutter pub run flutter_launcher_icons')

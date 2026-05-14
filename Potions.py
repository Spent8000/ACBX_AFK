import os
import subprocess
import sys

try:
    import easyocr
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "easyocr"])
    import easyocr

try:
    import pyautogui
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyautogui"])
    import pyautogui

# Should enter script in inventory after being clicked and leaving the main loop
reader = easyocr.Reader(['en'])
img = pyautogui.screenshot()
img.save("potions.png")
width, height = pyautogui.size()
base_path = os.path.dirname(sys.executable if getattr(sys, "frozen", False) else __file__)

potionList = []

if int(sys.argv[1]) == 1:
    try:
        potionList.append(pyautogui.locateOnScreen(os.path.join(base_path, "corrupted.png"), confidence=.90))
    except pyautogui.ImageNotFoundException:
        pass
if int(sys.argv[2]) == 1:
    try:
        potionList.append(pyautogui.locateOnScreen(os.path.join(base_path, "luck.png"), confidence=.90))
    except pyautogui.ImageNotFoundException:
        pass
if int(sys.argv[3]) == 1:
    try:
        potionList.append(pyautogui.locateOnScreen(os.path.join(base_path, "star.png"), confidence=.90))
    except pyautogui.ImageNotFoundException:
        pass
if int(sys.argv[4]) == 1:
    try:
        potionList.append(pyautogui.locateOnScreen(os.path.join(base_path, "boss.png"), confidence=.90))
    except pyautogui.ImageNotFoundException:
        pass

for potion in potionList:
    print((potion.left + potion.width/2) / 2560)
    print((potion.top + potion.height/2) / 1440)

if os.path.exists("potions.png"):
        os.remove("potions.png")
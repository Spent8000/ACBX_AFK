import subprocess
import sys
import warnings
import os
import smtplib
import re
from email.mime.text import MIMEText

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

def send_email(body,subject):
    sender = ""
    password = ""
    recipients = [sys.argv[1]]
    msg = MIMEText(body)
    msg['From'] = sender
    msg['To'] = ', '.join(recipients)
    msg["Subject"] = subject
    smtp_server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    smtp_server.login(sender, password)
    smtp_server.sendmail(sender, recipients, msg.as_string())
    smtp_server.quit()

warnings.filterwarnings("ignore")

width, height = pyautogui.size()

reader = easyocr.Reader(['en'])
img = pyautogui.screenshot(region=(int(width*.31), int(height* 0.035), int(width*0.38), int(height*0.069)))
img.save("curr.png")
if sys.argv[2] != None:
    last = int(sys.argv[2]) 
else:
    last = 0

result = reader.readtext('curr.png')
value = -1

for detection in result:
    text = detection[1]

    # skip empty / junk OCR results
    if not text or ":" not in text:
        continue

    try:
        raw_value = text.split(":", 1)[1].strip()

        # extract ONLY numbers (removes garbage)
        match = re.search(r"\d+", raw_value)
        if not match:
            continue

        value = int(match.group())

    except Exception:
        continue  # skip bad OCR line

if value > last:
    if os.path.exists("curr.png"):
        os.remove("curr.png")
elif value < last:
    if (sys.argv[1] != ""):
        send_email(f"Died on floor {last}", "Infinite ended")
        value = 0
print(value)
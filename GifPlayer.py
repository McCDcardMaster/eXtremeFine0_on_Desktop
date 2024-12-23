import os
import tkinter as tk
from PIL import Image, ImageTk
import sys

class GIFPlayer:
    def __init__(self, master, gif_path):
        self.master = master
        self.master.title("GIF Player")
        icon_path = resource_path("icon.ico")
        print(f"Icon path: {icon_path}")
        if os.path.exists(icon_path):
            self.master.iconbitmap(icon_path)
        else:
            print(f"Icon file not found: {icon_path}")

        self.master.attributes('-alpha', 0.0)
        self.master.overrideredirect(True)
        self.gif_path = gif_path
        self.frames = self.load_gif()
        self.label = tk.Label(master, bg='white')
        self.label.pack()
        self.index = 0
        self.play_gif()
        self.master.attributes('-alpha', 1.0)
        self.master.geometry(f"{self.frames[0].width()}x{self.frames[0].height()}")
        self.master.wm_attributes('-transparentcolor', 'white')
        screen_width = self.master.winfo_screenwidth()
        screen_height = self.master.winfo_screenheight()
        window_width = self.frames[0].width()
        window_height = self.frames[0].height()
        self.master.geometry(f"{window_width}x{window_height}+0+{screen_height - window_height}")
        self.master.bind("<ButtonPress-1>", self.start_move)
        self.master.bind("<B1-Motion>", self.do_move)

    def load_gif(self):
        img = Image.open(self.gif_path)
        frames = []
        try:
            while True:
                frame = ImageTk.PhotoImage(img.copy())
                frames.append(frame)
                img.seek(len(frames))
        except EOFError:
            pass
        return frames

    def play_gif(self):
        if self.frames:
            frame = self.frames[self.index]
            self.label.config(image=frame)
            self.index = (self.index + 1) % len(self.frames)
            self.master.after(11, self.play_gif)

    def start_move(self, event):
        self.master.x = event.x
        self.master.y = event.y

    def do_move(self, event):
        x = self.master.winfo_x() - self.master.x + event.x
        y = self.master.winfo_y() - self.master.y + event.y
        screen_width = self.master.winfo_screenwidth()
        screen_height = self.master.winfo_screenheight()
        window_width = self.master.winfo_width()
        window_height = self.master.winfo_height()
        if x < 0:
            x = 0
        elif x + window_width > screen_width:
            x = screen_width - window_width
        if y < 0:
            y = 0
        elif y + window_height > screen_height:
            y = screen_height - window_height
        self.master.geometry(f"+{x}+{y}")

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

if __name__ == "__main__":
    root = tk.Tk()
    gif_path = resource_path("ExtrimeFine.gif")
    player = GIFPlayer(root, gif_path)
    root.mainloop()

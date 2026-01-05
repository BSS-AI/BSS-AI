import cv2
import numpy as np
import onnxruntime
import time
import os
import math
import configparser
import ctypes
import ctypes.wintypes as wintypes
import sys
import socket
from pathlib import Path
import uuid
from datetime import datetime

install_path_file = Path(r"C:\ProgramData\BSSAI\.install-location.txt")

base_path = Path(install_path_file.read_text(encoding="utf-8").strip())

SETTINGS_FILE = base_path / "settings" / "settings.txt"
MAIN_SETTINGS_INI = base_path / "settings" / "settings.ini"
LOG_FILE = base_path / "lib/yolo_log.txt"

INPUT_WIDTH = 864
INPUT_HEIGHT = 864
NMS_THRESHOLD = 0.5

VIC_INPUT_HEIGHT = 736
VIC_INPUT_WIDTH = 736
VIC_CONFIDENCE_THRESHOLD = 0.4

SPRINKLER_INPUT_WIDTH = 736
SPRINKLER_INPUT_HEIGHT = 736

LABELS_BLUE = {
    0: 'Baby Love', 1: 'Beamstorm', 2: 'Beesmas Cheer', 3: 'Black Bear Morph', 4: 'Blue Bomb', 5: 'Blue Bomb Sync', 6: 'Blue Boost', 7: 'Blue Pulse', 8: 'Blueberry', 9: 'Brown Bear Morph',
    10: 'Buzz Bomb', 11: 'Festive Blessing', 12: 'Festive Gift', 13: 'Festive Mark', 14: 'Festive Mark Token', 15: 'Fetch', 16: 'Focus', 17: 'Fuzz Bomb Field', 18: 'Fuzz Bombs Token', 19: 'Glitch Token',
    20: 'Glob', 21: 'Gumdrop Barrage', 22: 'Haste', 23: 'Honey', 24: 'Honey Mark', 25: 'Honey Mark Token', 26: 'Impale', 27: 'Inflate Balloons', 28: 'Inspire', 29: 'Map Corruption',
    30: 'Melody', 31: 'Mind Hack', 32: 'Mother Bear Morph', 33: 'Panda Bear Morph', 34: 'Pineapple', 35: 'Polar Bear Morph', 36: 'Pollen Haze', 37: 'Pollen Mark', 38: 'Pollen Mark Token', 39: 'Puppy Ball',
    40: 'Puppy Love', 41: 'Rain Cloud', 42: 'Red Bomb', 43: 'Red Boost', 44: 'Science Bear Morph', 45: 'Scratch', 46: 'Snowflake', 47: 'Snowglobe Shake', 48: 'Strawberry', 49: 'Summon Frog',
    50: 'Sunflower Seed', 51: 'Surprise Party', 52: 'Tabby Love', 53: 'Token Link', 54: 'Tornado', 55: 'White Boost',
}

LABELS_SPRINKLER = {0: 'Basic', 1: 'Diamond', 2: 'Gold', 3: 'Silver', 4: 'Supreme'}
LABELS_VIC = {0: 'Vicious'}

PRESET_CALIBRATIONS = {
    (1920, 1080): [[759, 459], [1150, 462], [614, 778], [1289, 780]], 
    (1366, 768): [[540, 331], [815, 333], [439, 555], [915, 555]]
}
NORMALIZED_CAL_RATIOS = [
    (0.395314, 0.427995), (0.597795, 0.430686), 
    (0.320584, 0.721513), (0.670597, 0.722439)
]

config = configparser.ConfigParser(interpolation=None)
config.read(MAIN_SETTINGS_INI)

ENABLE_LOGGING = config.getboolean('Debug', 'enable_logging', fallback=True)
SHARED_FILE_PATH = config.get('Debug', 'shared_file_path', fallback="DEFAULT")
CONNECTION_TIMEOUT = config.getint('Debug', 'connection_timeout', fallback=600)

CONFIDENCE_THRESHOLD = config.getfloat('AIGather', 'confidence_threshold', fallback=0.4)
MAX_FPS = config.getint('AIGather', 'max_fps', fallback=15)
SPRINKLER_CONFIDENCE_THRESHOLD = config.getfloat('AIGather', 'sprinkler_confidence_threshold', fallback=0.6)

MAX_LEASH_DISTANCE = config.getfloat('AIGather', 'max_leash_distance', fallback=4.0)
SOFT_LEASH_DISTANCE = config.getfloat('AIGather', 'soft_leash_distance', fallback=2.5)
MOVEMENTS_BEFORE_RECALIBRATION = config.getint('AIGather', 'movements_before_recalibration', fallback=10)

MIN_TOKEN_DISTANCE = config.getfloat('AIGather', 'min_token_distance', fallback=0.3)
MAX_TOKEN_CONSIDERATION_DISTANCE = config.getfloat('AIGather', 'max_token_consideration_distance', fallback=5.0)
CLUSTER_RADIUS = config.getfloat('AIGather', 'cluster_radius', fallback=2.0)

PROXIMITY_EXPONENT = config.getfloat('AIGather', 'proximity_exponent', fallback=1.8)
TOWARD_HOME_BONUS = config.getfloat('AIGather', 'toward_home_bonus', fallback=1.4)
AWAY_FROM_HOME_PENALTY = config.getfloat('AIGather', 'away_from_home_penalty', fallback=0.6)
CLUSTER_BONUS_PER_TOKEN = config.getfloat('AIGather', 'cluster_bonus_per_token', fallback=0.15)
LEASH_EDGE_PENALTY = config.getfloat('AIGather', 'leash_edge_penalty', fallback=0.3)

IDLE_RETURN_INTERVAL = config.getfloat('AIGather', 'idle_return_interval', fallback=1.5)
NO_TOKEN_RECALIBRATION_TIMEOUT = config.getfloat('AIGather', 'no_token_recalibration_timeout', fallback=15.0)
SPRINKLER_ARRIVAL_THRESHOLD = config.getfloat('AIGather', 'sprinkler_arrival_threshold', fallback=0.8)

# Sprinkler detection limits
MAX_SPRINKLER_DISTANCE = config.getfloat('AIGather', 'max_sprinkler_distance', fallback=10.0)
SPRINKLER_RESCAN_ATTEMPTS = config.getint('AIGather', 'sprinkler_rescan_attempts', fallback=3)
SPRINKLER_RESCAN_DELAY = config.getfloat('AIGather', 'sprinkler_rescan_delay', fallback=0.3)

SPRINKLER_TYPE = config.get('Settings', 'sprinklertype', fallback='Supreme')

COMMUNICATION_METHOD = config.get('AIGather', 'communication_method', fallback="SOCKET").upper()
if len(sys.argv) > 1 and sys.argv[1].upper() in ["SOCKET", "COM"]:
    COMMUNICATION_METHOD = sys.argv[1].upper()

priority_tokens_str = config.get('AIGather', 'priority_tokens', fallback="Token Link:100, Focus")
ignore_tokens_str = config.get('AIGather', 'ignore_tokens', fallback="Balloon")

current_x = 0.0
current_y = 0.0
movement_count = 0
last_token_time = 0.0
last_idle_return_time = 0.0
g_com_object = None
g_conn = None
g_server_socket = None


class ScreenCapture:
    """GDI-based screen capture for minimal latency."""
    def __init__(self, region):
        self.x, self.y, self.width, self.height = region
        user32 = ctypes.WinDLL('user32', use_last_error=True)
        gdi32 = ctypes.WinDLL('gdi32', use_last_error=True)
        self.gdi32 = gdi32
        self.hdesktop = user32.GetDesktopWindow()
        self.desktop_dc = user32.GetWindowDC(self.hdesktop)
        self.mem_dc = gdi32.CreateCompatibleDC(self.desktop_dc)
        self.bitmap = gdi32.CreateCompatibleBitmap(self.desktop_dc, self.width, self.height)
        gdi32.SelectObject(self.mem_dc, self.bitmap)
        
        class BITMAPINFOHEADER(ctypes.Structure):
            _fields_ = [
                ('biSize', wintypes.DWORD), ('biWidth', wintypes.LONG), ('biHeight', wintypes.LONG),
                ('biPlanes', wintypes.WORD), ('biBitCount', wintypes.WORD), ('biCompression', wintypes.DWORD),
                ('biSizeImage', wintypes.DWORD), ('biXPelsPerMeter', wintypes.LONG), ('biYPelsPerMeter', wintypes.LONG),
                ('biClrUsed', wintypes.DWORD), ('biClrImportant', wintypes.DWORD)
            ]
        
        class BITMAPINFO(ctypes.Structure):
            _fields_ = [('bmiHeader', BITMAPINFOHEADER), ('bmiColors', wintypes.DWORD * 3)]
        
        self.bmi = BITMAPINFO()
        self.bmi.bmiHeader.biSize = ctypes.sizeof(BITMAPINFOHEADER)
        self.bmi.bmiHeader.biWidth = self.width
        self.bmi.bmiHeader.biHeight = -self.height
        self.bmi.bmiHeader.biPlanes = 1
        self.bmi.bmiHeader.biBitCount = 32
        self.bmi.bmiHeader.biCompression = 0
        self.buffer = np.empty((self.height, self.width, 4), dtype=np.uint8)

    def grab(self):
        self.gdi32.BitBlt(self.mem_dc, 0, 0, self.width, self.height, self.desktop_dc, self.x, self.y, 0x00CC0020)
        self.gdi32.GetDIBits(self.mem_dc, self.bitmap, 0, self.height, self.buffer.ctypes.data_as(ctypes.c_void_p), ctypes.byref(self.bmi), 0)
        return self.buffer

    def release(self):
        self.gdi32.DeleteObject(self.bitmap)
        self.gdi32.DeleteDC(self.mem_dc)


def log_message(message):
    if not ENABLE_LOGGING:
        return
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(f"[{timestamp}] {message}\n")
    except:
        pass


def get_shared_path():
    if SHARED_FILE_PATH == "DEFAULT" or not SHARED_FILE_PATH:
        return os.getcwd()
    if not os.path.isdir(SHARED_FILE_PATH):
        return os.getcwd()
    return SHARED_FILE_PATH


def get_current_resolution():
    return ctypes.windll.user32.GetSystemMetrics(0), ctypes.windll.user32.GetSystemMetrics(1)


def calc_points_from_resolution(width, height):
    return [[int(round(nx * width)), int(round(ny * height))] for nx, ny in NORMALIZED_CAL_RATIOS]


def preprocess_for_onnx(frame_rgba, input_width, input_height):
    resized = cv2.resize(frame_rgba, (int(input_width), int(input_height)), interpolation=cv2.INTER_LINEAR)
    rgb = cv2.cvtColor(resized, cv2.COLOR_BGRA2RGB)
    normalized = rgb.astype(np.float16) / 255.0
    chw = np.transpose(normalized, (2, 0, 1))
    return np.expand_dims(chw, axis=0)


def postprocess_onnx_detections(output, confidence_threshold):
    outputs = np.squeeze(output[0])
    class_probs = outputs[4:, :]
    confidences = np.max(class_probs, axis=0)
    mask = confidences > confidence_threshold
    filtered_confidences = confidences[mask]
    
    if len(filtered_confidences) == 0:
        return []
    
    class_ids = np.argmax(class_probs[:, mask], axis=0)
    boxes_data = outputs[:4, mask]
    cx, cy, w, h = boxes_data
    x1 = cx - w / 2
    y1 = cy - h / 2
    boxes_for_nms = np.stack((x1, y1, w, h), axis=1)
    indices = cv2.dnn.NMSBoxes(boxes_for_nms.tolist(), filtered_confidences.tolist(), confidence_threshold, NMS_THRESHOLD)
    
    detections = []
    if len(indices) > 0:
        for i in indices:
            box = boxes_for_nms[i]
            x1, y1, w, h = box
            detections.append(((x1, y1, x1 + w, y1 + h), class_ids[i], filtered_confidences[i]))
    return detections


SHARED_DIR = get_shared_path()

if COMMUNICATION_METHOD == "COM":
    import win32com.client


def initialize_com_client():
    global g_com_object
    clsid = f"{{{uuid.uuid4()}}}"

    config_write = configparser.ConfigParser(interpolation=None)
    config_write.read(MAIN_SETTINGS_INI)
    if not config_write.has_section('Communication'):
        config_write.add_section('Communication')
    config_write.set('Communication', 'python_clsid', clsid)
    with open(MAIN_SETTINGS_INI, 'w') as f:
        config_write.write(f)

    print(f"[YOLO COM] Generated CLSID: {clsid}")
    log_message(f"[COM] Generated CLSID: {clsid}")

    start_time = time.time()
    while time.time() - start_time < CONNECTION_TIMEOUT:
        try:
            g_com_object = win32com.client.Dispatch(clsid)
            print("[YOLO COM] Connected to AHK COM object.")
            log_message("[COM] Connected to AHK COM object.")
            return True
        except:
            time.sleep(1)

    ctypes.windll.user32.MessageBoxW(0, "Failed to connect to AutoHotkey COM object.", "Python COM Error", 0x1030)
    sys.exit(1)


def send_com_command(command, *params):
    global g_com_object
    if g_com_object is None:
        return False
    try:
        str_params = [str(p) for p in params]
        return g_com_object.HandleCommand(g_com_object, command, *str_params)
    except Exception as e:
        ctypes.windll.user32.MessageBoxW(0, f"Lost connection to AHK: {e}", "Python COM Error", 0x1030)
        sys.exit(1)


def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        return s.getsockname()[1]


def start_server():
    global g_server_socket
    port = find_free_port()

    config_write = configparser.ConfigParser(interpolation=None)
    config_write.read(MAIN_SETTINGS_INI)
    if not config_write.has_section('Communication'):
        config_write.add_section('Communication')
    config_write.set('Communication', 'python_port', str(port))
    with open(MAIN_SETTINGS_INI, 'w') as f:
        config_write.write(f)

    g_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    g_server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    g_server_socket.bind(('127.0.0.1', port))
    g_server_socket.listen(1)
    print(f"[YOLO Server] Listening on 127.0.0.1:{port}")
    log_message(f"[Socket] Listening on port {port}")


def accept_connection():
    global g_conn, g_server_socket
    if not g_server_socket:
        return False
    try:
        g_server_socket.settimeout(1.0)
        conn, addr = g_server_socket.accept()
        conn.settimeout(10.0)
        print(f"[YOLO Server] Connected by {addr}")
        log_message(f"[Socket] Connected from {addr}")
        g_conn = conn
        return True
    except socket.timeout:
        return False
    except Exception as e:
        print(f"[YOLO Server] Connection error: {e}")
        g_conn = None
        return False


def send_and_wait(command_text):
    global g_conn
    if g_conn is None:
        return False
    try:
        g_conn.sendall((command_text + "\n").encode('utf-8'))
        response = g_conn.recv(1024).decode('utf-8').strip()
        return response == "READY"
    except (socket.error, BrokenPipeError, ConnectionResetError, socket.timeout) as e:
        print(f"[YOLO Server] Connection lost: {e}")
        if g_conn:
            g_conn.close()
            g_conn = None
        return False


def load_settings():
    screen_w, screen_h = get_current_resolution()
    key = (screen_w, screen_h)
    
    if key in PRESET_CALIBRATIONS:
        return np.array(PRESET_CALIBRATIONS[key], dtype=np.float32)
    
    if os.path.exists(SETTINGS_FILE):
        try:
            content = open(SETTINGS_FILE, "r").read().strip()
            if content:
                rows = content.split("\n")
                pts = [[int(p.strip()) for p in row.split(",")] for row in rows if len(row.split(",")) == 2]
                if len(pts) >= 4:
                    return np.array(pts[:4], dtype=np.float32)
        except:
            pass
    
    return np.array(calc_points_from_resolution(screen_w, screen_h), dtype=np.float32)


def calculate_homography(pts_src):
    outer_dist = 5
    pts_dst = np.array([
        [-outer_dist, -outer_dist], [outer_dist, -outer_dist],
        [-outer_dist, outer_dist], [outer_dist, outer_dist]
    ], dtype=np.float32)
    h, _ = cv2.findHomography(pts_src, pts_dst, cv2.RANSAC)
    return h


def relative_distance(x, y, h):
    """Transform screen coordinates to game-world movement vector."""
    y += 15
    point = np.array([[[x, y]]], dtype=np.float32)
    transformed = cv2.perspectiveTransform(point, h)
    tx, ty = transformed[0][0]
    return tx, -ty


def load_models():
    providers = ['DmlExecutionProvider']
    
    try:
        token_model = onnxruntime.InferenceSession('blue.onnx', providers=providers)
        log_message("Loaded blue.onnx")
    except Exception as e:
        log_message(f"FATAL: Could not load blue.onnx: {e}")
        raise e

    sprinkler_model = None
    try:
        sprinkler_model = onnxruntime.InferenceSession('sprinkler.onnx', providers=providers)
        log_message("Loaded sprinkler.onnx")
    except Exception as e:
        log_message(f"Warning: sprinkler.onnx not loaded: {e}")
        print(f"Warning: sprinkler.onnx not available: {e}")

    vic_model = None
    try:
        vic_model = onnxruntime.InferenceSession('vic.onnx', providers=providers)
        log_message("Loaded vic.onnx")
    except Exception as e:
        log_message(f"Warning: vic.onnx not loaded: {e}")
        print(f"Warning: VIC detection unavailable: {e}")

    return token_model, sprinkler_model, vic_model


def parse_priority_tokens(token_string):
    tokens = []
    if not token_string:
        return tokens
    for part in [p.strip() for p in token_string.split(',')]:
        if ':' in part:
            try:
                name, value = part.split(':', 1)
                tokens.append((name.strip(), int(value.strip())))
            except ValueError:
                pass
        elif part:
            tokens.append(part)
    return tokens


def parse_ignore_tokens(token_string):
    if not token_string:
        return []
    return [t.strip() for t in token_string.split(',') if t.strip()]


priority_tokens = parse_priority_tokens(priority_tokens_str)
ignore_tokens = parse_ignore_tokens(ignore_tokens_str)


def get_token_importance(token_name):
    """Returns importance score. Higher = more valuable. Default 1 for unlisted tokens."""
    total = len(priority_tokens)
    for i, data in enumerate(priority_tokens):
        if isinstance(data, tuple) and data[0] == token_name:
            return data[1]
        elif data == token_name:
            return (total * 2) - (i * 2)
    return 1


class TokenCandidate:
    """Holds all scoring data for a potential token target."""
    def __init__(self, name, tx, ty, importance, confidence):
        self.name = name
        self.tx = tx
        self.ty = ty
        self.importance = importance
        self.confidence = confidence
        self.distance_to_token = 0.0
        self.future_x = 0.0
        self.future_y = 0.0
        self.future_distance_from_origin = 0.0
        self.direction_score = 1.0
        self.cluster_score = 1.0
        self.final_score = 0.0


def calculate_token_scores(candidates):
    """
    Score all candidates. Distance is the dominant factor - close tokens win.
    Direction and clusters act as multipliers for similar-distance tokens.
    """
    global current_x, current_y
    current_dist = math.hypot(current_x, current_y)
    
    for c in candidates:
        c.distance_to_token = math.hypot(c.tx, c.ty)
        c.future_x = current_x + c.tx
        c.future_y = current_y + c.ty
        c.future_distance_from_origin = math.hypot(c.future_x, c.future_y)
        
        proximity = 1.0 / (0.3 + c.distance_to_token) ** PROXIMITY_EXPONENT
        
        dist_change = c.future_distance_from_origin - current_dist
        if dist_change < -0.5:
            c.direction_score = TOWARD_HOME_BONUS
        elif dist_change < 0:
            c.direction_score = 1.0 + (TOWARD_HOME_BONUS - 1.0) * 0.5
        elif dist_change < 0.5:
            c.direction_score = 1.0
        elif dist_change < 1.5:
            c.direction_score = AWAY_FROM_HOME_PENALTY
        else:
            c.direction_score = AWAY_FROM_HOME_PENALTY * 0.7
        
        if current_dist > SOFT_LEASH_DISTANCE and c.future_distance_from_origin > current_dist:
            c.direction_score *= LEASH_EDGE_PENALTY
        
        importance = math.log(c.importance + 1) + 1
        c.final_score = proximity * c.direction_score * importance
    
    for c in candidates:
        nearby = sum(1 for other in candidates 
                    if other is not c and 
                    math.hypot(c.future_x - other.future_x, c.future_y - other.future_y) < CLUSTER_RADIUS)
        c.cluster_score = 1.0 + (nearby * CLUSTER_BONUS_PER_TOKEN)
        c.final_score *= c.cluster_score
    
    return candidates


def find_best_token(detections, h):
    """Find optimal token considering distance, direction, clusters, and priority."""
    global current_x, current_y
    
    candidates = []
    screen_w, screen_h = get_current_resolution()
    scale_x = screen_w / INPUT_WIDTH
    scale_y = screen_h / INPUT_HEIGHT
    
    for (box, class_id, conf) in detections:
        token_name = LABELS_BLUE.get(class_id)
        if not token_name or token_name in ignore_tokens:
            continue
        
        importance = get_token_importance(token_name)
        
        x1, y1, x2, y2 = box
        center_x = (x1 + x2) / 2 * scale_x
        center_y = (y1 + y2) / 2 * scale_y
        
        tx, ty = relative_distance(center_x, center_y, h)
        distance = math.hypot(tx, ty)
        
        if distance < MIN_TOKEN_DISTANCE or distance > MAX_TOKEN_CONSIDERATION_DISTANCE:
            continue
        
        future_dist = math.hypot(current_x + tx, current_y + ty)
        if future_dist > MAX_LEASH_DISTANCE:
            continue
        
        candidates.append(TokenCandidate(token_name, tx, ty, importance, conf))
    
    if not candidates:
        return None
    
    calculate_token_scores(candidates)
    best = max(candidates, key=lambda c: c.final_score)
    
    print(f"Target: {best.name} | dist:{best.distance_to_token:.1f} | "
          f"dir:{best.direction_score:.2f} | cluster:{best.cluster_score:.2f} | "
          f"score:{best.final_score:.2f} | options:{len(candidates)}")
    
    return (best.tx, best.ty)


def calculate_movement_directions(tx, ty):
    """Map movement vector to WASD diagonal pair for efficient pathing."""
    if tx > 0 and ty > 0:
        return ("d", "w") if tx > ty else ("w", "d")
    elif tx > 0 and ty < 0:
        return ("d", "s") if tx > abs(ty) else ("s", "d")
    elif tx < 0 and ty > 0:
        return ("a", "w") if abs(tx) > ty else ("w", "a")
    elif tx < 0 and ty < 0:
        return ("a", "s") if abs(tx) > abs(ty) else ("s", "a")
    return "", ""


def execute_movement_raw(tx, ty):
    """Send movement command without updating position state."""
    distance_one = math.sqrt(2) * min(abs(tx), abs(ty))
    distance_two = abs(abs(tx) - abs(ty))
    
    if distance_one < 0.1:
        distance_one = 0
    if distance_two < 0.1:
        distance_two = 0
    
    dir_one, dir_two = calculate_movement_directions(tx, ty)
    
    if dir_one and dir_two:
        if COMMUNICATION_METHOD == "COM":
            send_com_command("MOVEMENT", dir_one, f"{distance_one:.3f}", dir_two, f"{distance_two:.3f}")
        else:
            cmd = f"{dir_one},{distance_one:.3f}\n{dir_two},{distance_two:.3f}"
            if not send_and_wait(cmd):
                return False
    return True


def execute_movement(tx, ty):
    """Move to collect token, updating position tracking."""
    global current_x, current_y, movement_count, last_token_time
    
    print(f"Moving: ({tx:.1f}, {ty:.1f}) from ({current_x:.1f}, {current_y:.1f})")
    
    if execute_movement_raw(tx, ty):
        current_x += tx
        current_y += ty
        movement_count += 1
        last_token_time = time.time()
        
        dist = math.hypot(current_x, current_y)
        print(f"Now at: ({current_x:.1f}, {current_y:.1f}) | {dist:.1f} from origin | moves: {movement_count}")


def find_sprinkler(sprinkler_model, sprinkler_input_name, h, capturer):
    """Detect closest sprinkler within MAX_SPRINKLER_DISTANCE tiles."""
    if not sprinkler_model:
        return None

    frame = capturer.grab()
    tensor = preprocess_for_onnx(frame, SPRINKLER_INPUT_WIDTH, SPRINKLER_INPUT_HEIGHT)
    output = sprinkler_model.run(None, {sprinkler_input_name: tensor})
    detections = postprocess_onnx_detections(output, SPRINKLER_CONFIDENCE_THRESHOLD)

    screen_w, screen_h = get_current_resolution()
    scale_x = screen_w / SPRINKLER_INPUT_WIDTH
    scale_y = screen_h / SPRINKLER_INPUT_HEIGHT
    
    best = None
    best_dist = float('inf')

    for (box, class_id, conf) in detections:
        if LABELS_SPRINKLER.get(class_id) != SPRINKLER_TYPE:
            continue

        x1, y1, x2, y2 = box
        cx = (x1 + x2) / 2 * scale_x
        cy = (y1 + y2) / 2 * scale_y

        tx, ty = relative_distance(cx, cy, h)
        dist = math.hypot(tx, ty)

        # Ignore sprinklers beyond reasonable distance - probably misdetection or wrong field
        if dist > MAX_SPRINKLER_DISTANCE:
            print(f"Ignoring sprinkler at distance {dist:.1f} (max: {MAX_SPRINKLER_DISTANCE})")
            continue

        if dist < best_dist:
            best_dist = dist
            best = (tx, ty, dist)

    return best


def find_sprinkler_with_retry(sprinkler_model, sprinkler_input_name, h, capturer):
    """Try to find sprinkler multiple times before giving up."""
    for attempt in range(SPRINKLER_RESCAN_ATTEMPTS):
        result = find_sprinkler(sprinkler_model, sprinkler_input_name, h, capturer)
        if result:
            return result
        
        if attempt < SPRINKLER_RESCAN_ATTEMPTS - 1:
            print(f"Sprinkler not found, rescanning... ({attempt + 1}/{SPRINKLER_RESCAN_ATTEMPTS})")
            time.sleep(SPRINKLER_RESCAN_DELAY)
    
    return None


def execute_idle_return(sprinkler_model, sprinkler_input_name, h, capturer):
    """
    When no tokens available, use AI to find sprinkler and move toward it.
    Much more accurate than memory-based position tracking.
    """
    global current_x, current_y, last_idle_return_time
    
    result = find_sprinkler_with_retry(sprinkler_model, sprinkler_input_name, h, capturer)
    
    if not result:
        print("No sprinkler found within range, continuing without move")
        last_idle_return_time = time.time()
        return False
    
    tx, ty, distance = result
    
    # Already at sprinkler
    if distance < SPRINKLER_ARRIVAL_THRESHOLD:
        if abs(current_x) > 0.1 or abs(current_y) > 0.1:
            print(f"At sprinkler - correcting drift (was tracking: {current_x:.1f}, {current_y:.1f})")
            current_x, current_y = 0.0, 0.0
        last_idle_return_time = time.time()
        return False
    
    print(f"Idle return: moving to sprinkler (distance {distance:.1f})")
    
    if execute_movement_raw(tx, ty):
        last_idle_return_time = time.time()
        current_x, current_y = 0.0, 0.0
        print("Returned to sprinkler")
        return True
    
    return False


def send_saturator_command():
    if COMMUNICATION_METHOD == "COM":
        send_com_command("SATURATOR")
    else:
        send_and_wait("MOVE_TO_SATURATOR")


def recalibrate_position(sprinkler_model, sprinkler_input_name, h, capturer):
    """Reset position by returning to sprinkler. Handles accumulated drift."""
    global current_x, current_y, movement_count
    
    print(f"=== RECALIBRATING === (tracked pos: {current_x:.1f}, {current_y:.1f}, moves: {movement_count})")
    log_message(f"Recalibrating from ({current_x:.2f}, {current_y:.2f})")
    
    if sprinkler_model:
        result = find_sprinkler_with_retry(sprinkler_model, sprinkler_input_name, h, capturer)
        
        if result:
            tx, ty, dist = result
            
            if dist < SPRINKLER_ARRIVAL_THRESHOLD:
                print("Already at sprinkler")
                current_x, current_y = 0.0, 0.0
                movement_count = 0
                return
            
            print(f"Moving to sprinkler (distance: {dist:.1f})")
            execute_movement_raw(tx, ty)
            current_x, current_y = 0.0, 0.0
            movement_count = 0
            print("Recalibration complete (AI)")
            return
        
        print("Sprinkler not found within range after retries")
    
    # Fallback to saturator
    print("Using saturator for recalibration")
    send_saturator_command()
    current_x, current_y = 0.0, 0.0
    movement_count = 0


def should_recalibrate():
    """Check if position needs resetting due to movement count or timeout."""
    global movement_count, last_token_time
    
    if movement_count >= MOVEMENTS_BEFORE_RECALIBRATION:
        return True
    
    if last_token_time > 0:
        idle_time = time.time() - last_token_time
        if idle_time > NO_TOKEN_RECALIBRATION_TIMEOUT:
            return True
    
    return False


def detect_vicious_bee(vic_model, vic_input_name, capturer):
    """Check if vicious bee is on screen."""
    if not vic_model:
        return False

    try:
        frame = capturer.grab()
        tensor = preprocess_for_onnx(frame, VIC_INPUT_WIDTH, VIC_INPUT_HEIGHT)
        output = vic_model.run(None, {vic_input_name: tensor})
        detections = postprocess_onnx_detections(output, VIC_CONFIDENCE_THRESHOLD)

        for (box, class_id, conf) in detections:
            print(f"[VIC] Detected with confidence {conf:.2f}")
            log_message(f"VIC detected: {conf:.2f}")
            return True

        return False

    except Exception as e:
        log_message(f"VIC detection error: {e}")
        return False


def handle_vic_detection_request(vic_model, vic_input_name, capturer):
    """Process VIC detection request from AHK."""
    detected = detect_vicious_bee(vic_model, vic_input_name, capturer)
    result = "true" if detected else "false"

    if COMMUNICATION_METHOD == "COM":
        send_com_command("VIC_DETECT", result)
    else:
        global g_conn
        if g_conn:
            try:
                g_conn.sendall((result + "\n").encode('utf-8'))
            except:
                pass

    return detected


def main():
    global current_x, current_y, movement_count, last_token_time, last_idle_return_time
    
    log_message("--- YOLO Started ---")
    print(f"[YOLO] Mode: {COMMUNICATION_METHOD} | FPS: {MAX_FPS}")
    print(f"[YOLO] Leash: {MAX_LEASH_DISTANCE} (soft: {SOFT_LEASH_DISTANCE}) | Recal every {MOVEMENTS_BEFORE_RECALIBRATION} moves")
    print(f"[YOLO] Max sprinkler distance: {MAX_SPRINKLER_DISTANCE} | Rescan attempts: {SPRINKLER_RESCAN_ATTEMPTS}")

    try:
        token_model, sprinkler_model, vic_model = load_models()
        token_input = token_model.get_inputs()[0].name
        sprinkler_input = sprinkler_model.get_inputs()[0].name if sprinkler_model else None
        vic_input = vic_model.get_inputs()[0].name if vic_model else None
    except Exception as e:
        ctypes.windll.user32.MessageBoxW(0, f"Model load failed: {e}", "YOLO Error", 0x1030)
        sys.exit(1)

    h = calculate_homography(load_settings())

    if COMMUNICATION_METHOD == "COM":
        initialize_com_client()
    else:
        start_server()

    screen_w, screen_h = get_current_resolution()
    capturer = ScreenCapture((0, 0, screen_w, screen_h))

    gathering_active = False
    frame_time = 1.0 / MAX_FPS

    while True:
        loop_start = time.time()

        if COMMUNICATION_METHOD == "SOCKET" and g_conn is None:
            accept_connection()
            time.sleep(0.1)
            continue

        try:
            config.read(MAIN_SETTINGS_INI)
            if config.get('Vichop', 'vic_detect_request', fallback='false').lower() in ['true', '1', 'yes']:
                handle_vic_detection_request(vic_model, vic_input, capturer)
                config.set('Vichop', 'vic_detect_request', 'false')
                with open(MAIN_SETTINGS_INI, 'w') as f:
                    config.write(f)
                continue
        except:
            pass

        try:
            config.read(MAIN_SETTINGS_INI)
            gathering = config.get('AIGather', 'currently_gathering', fallback='false').lower() in ['true', '1', 'yes', 'on']
        except:
            gathering = False

        if gathering and not gathering_active:
            print("[YOLO] === Session started ===")
            current_x, current_y, movement_count = 0.0, 0.0, 0
            last_token_time = time.time()
            last_idle_return_time = time.time()
            gathering_active = True

        if not gathering:
            if gathering_active:
                print("[YOLO] === Session ended ===")
                gathering_active = False
            time.sleep(0.1)
            continue

        if should_recalibrate():
            recalibrate_position(sprinkler_model, sprinkler_input, h, capturer)
            last_token_time = time.time()
            continue

        frame = capturer.grab()
        tensor = preprocess_for_onnx(frame, INPUT_WIDTH, INPUT_HEIGHT)
        output = token_model.run(None, {token_input: tensor})
        detections = postprocess_onnx_detections(output, CONFIDENCE_THRESHOLD)

        target = find_best_token(detections, h)

        if target:
            execute_movement(*target)
        else:
            if time.time() - last_idle_return_time >= IDLE_RETURN_INTERVAL:
                execute_idle_return(sprinkler_model, sprinkler_input, h, capturer)

        elapsed = time.time() - loop_start
        if elapsed < frame_time:
            time.sleep(frame_time - elapsed)


if __name__ == "__main__":
    main()
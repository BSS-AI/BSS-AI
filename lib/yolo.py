import cv2
import numpy as np
from ultralytics import YOLO
import time
import os
import math
import mss
from cryptography.fernet import Fernet
import configparser
import ctypes
import sys
import socket
import uuid
from datetime import datetime

lib_path = os.path.join(os.path.expandvars("%APPDATA%"), "BSSAI", "lib")
settings_path = os.path.join(os.path.expandvars("%APPDATA%"), "BSSAI", "settings")
installLocation = os.path.join("C:\\", "ProgramData", "BSSAI", ".install-location.txt")
installPath = os.path.join(lib_path, "..")

with open(installLocation, "r", encoding="utf-8") as f:
    installPath = f.read().strip()

LOG_FILE = os.path.join(lib_path, "yolo_log.txt")
ENABLE_LOGGING = True

current_x = 0.0
current_y = 0.0
movement_count = 0

def log_message(message):
    if not ENABLE_LOGGING:
        return
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] {message}\n"
    try:
        with open(LOG_FILE, "a") as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Failed to write to log file: {e}")

config = configparser.ConfigParser(interpolation=None)
MAIN_SETTINGS_INI = os.path.join(settings_path, "settings.ini")
config.read(MAIN_SETTINGS_INI)

ENABLE_LOGGING = config.getboolean('Debug', 'enable_logging', fallback=True)
SHARED_FILE_PATH = config.get('Debug', 'shared_file_path', fallback="DEFAULT")
CONNECTION_TIMEOUT = config.getint('Debug', 'connection_timeout', fallback=600)

MOVEMENTS_BEFORE_SATURATOR = config.getint('AIGather', 'movements_before_saturator', fallback=10)
DRIFT_CORRECTION_TIMEOUT = config.getint('AIGather', 'drift_correction_timeout', fallback=10)

SAFE_DISTANCE = config.getfloat('AIGather', 'safe_distance', fallback=3.0)
PENALTY_START_DISTANCE = config.getfloat('AIGather', 'penalty_start_distance', fallback=3.0)
MAX_ALLOWED_DISTANCE = config.getfloat('AIGather', 'max_allowed_distance', fallback=11.0)
DISTANCE_PENALTY_EXPONENT = config.getfloat('AIGather', 'distance_penalty_exponent', fallback=1.5)
PRE_MOVEMENT_VALIDATION = config.getboolean('AIGather', 'pre_movement_validation', fallback=True)

SPRINKLER_CONFIDENCE_THRESHOLD = config.getfloat('AIGather', 'sprinkler_confidence_threshold', fallback=0.6)
DRIFT_CORRECTION_METHOD = config.get('AIGather', 'drift_correction_method', fallback='SATURATOR').upper()
SPRINKLER_TYPE = config.get('Settings', 'sprinklertype', fallback='Supreme')

def get_shared_path():
    if SHARED_FILE_PATH == "DEFAULT" or not SHARED_FILE_PATH:
        path = lib_path
        log_message(f"Using DEFAULT shared file path: {path}")
        return path
    else:
        if not os.path.isdir(SHARED_FILE_PATH):
            log_message(f"WARNING: Custom shared path '{SHARED_FILE_PATH}' does not exist. Falling back to DEFAULT.")
            path = os.getcwd()
            log_message(f"Using DEFAULT shared file path: {path}")
            return path
        log_message(f"Using CUSTOM shared file path from INI: {SHARED_FILE_PATH}")
        return SHARED_FILE_PATH

SHARED_DIR = get_shared_path()
GATHER_STATE_FILE = os.path.join(SHARED_DIR, "gather_state.txt")

COMMUNICATION_METHOD = config.get('AIGather', 'communication_method', fallback="SOCKET").upper()
if len(sys.argv) > 1 and sys.argv[1].upper() in ["SOCKET", "COM"]:
    COMMUNICATION_METHOD = sys.argv[1].upper()

if COMMUNICATION_METHOD == "COM":
    import win32com.client

g_com_object = None
g_conn = None
g_server_socket = None

def initialize_com_client():
    global g_com_object
    clsid = f"{{{uuid.uuid4()}}}"
    log_message(f"[COM] Writing CLSID to settings.ini")
    
    config_write = configparser.ConfigParser(interpolation=None)
    config_write.read(MAIN_SETTINGS_INI)
    if not config_write.has_section('Communication'):
        config_write.add_section('Communication')
    config_write.set('Communication', 'python_clsid', clsid)
    with open(MAIN_SETTINGS_INI, 'w') as f:
        config_write.write(f)
    
    print(f"[YOLO COM] Generated CLSID: {clsid}")
    log_message(f"[COM] Generated CLSID: {clsid}")
    
    max_wait_seconds = CONNECTION_TIMEOUT
    start_time = time.time()
    while time.time() - start_time < max_wait_seconds:
        try:
            g_com_object = win32com.client.Dispatch(clsid)
            print("[YOLO COM] Successfully connected to AHK COM object.")
            log_message("[COM] Successfully connected to AHK COM object.")
            return True
        except Exception:
            time.sleep(1)
    
    print(f"[YOLO COM] Error: Could not connect to COM object after {max_wait_seconds} seconds.")
    ctypes.windll.user32.MessageBoxW(0, "Failed to connect to AutoHotkey COM object.", "Python COM Error", 0x1030)
    sys.exit(1)

def send_com_command(command, *params):
    global g_com_object
    if g_com_object is None:
        print("[YOLO COM] Error: COM object is not initialized.")
        return False
    try:
        str_params = [str(p) for p in params]
        return g_com_object.HandleCommand(g_com_object, command, *str_params)
    except Exception as e:
        print(f"[YOLO COM] Critical error sending command '{command}': {e}")
        ctypes.windll.user32.MessageBoxW(0, f"Lost connection to AutoHotkey COM object: {e}", "Python COM Error", 0x1030)
        cv2.destroyAllWindows()
        sys.exit(1)

def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        return s.getsockname()[1]

def start_server():
    global g_server_socket
    port = find_free_port()
    log_message(f"[Socket] Writing port {port} to settings.ini")
    
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
    log_message(f"[Socket] Server listening on 127.0.0.1:{port}")

def accept_connection():
    global g_conn, g_server_socket
    if g_server_socket:
        try:
            g_server_socket.settimeout(1.0)
            conn, addr = g_server_socket.accept()
            conn.settimeout(10.0)
            print(f"[YOLO Server] Connected by {addr}")
            log_message(f"[Socket] Accepted connection from {addr}")
            g_conn = conn
            return True
        except socket.timeout:
            return False
        except Exception as e:
            print(f"[YOLO Server] Error accepting connection: {e}")
            g_conn = None
            return False
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
        print(f"[YOLO Server] Connection error: {e}. AHK likely closed.")
        if g_conn:
            g_conn.close()
            g_conn = None
        return False

SETTINGS_FILE = os.path.join(settings_path, "settings.txt")

CONFIDENCE_THRESHOLD = config.getfloat('AIGather', 'confidence_threshold', fallback=0.4)
MAX_FPS = config.getint('AIGather', 'max_fps', fallback=15)

PRESET_CALIBRATIONS = {
    (1920, 1080): [[759, 459], [1150, 462], [614, 778], [1289, 780]],
    (1366, 768): [[540, 331], [815, 333], [439, 555], [915, 555]],
}

NORMALIZED_CAL_RATIOS = [
    (0.395314, 0.427995), (0.597795, 0.430686),
    (0.320584, 0.721513), (0.670597, 0.722439),
]

def calc_points_from_resolution(width, height):
    pts = []
    for nx, ny in NORMALIZED_CAL_RATIOS:
        pts.append([int(round(nx * width)), int(round(ny * height))])
    return pts

def get_current_resolution():
    try:
        with mss.mss() as sct:
            mon = sct.monitors[1]
            return int(mon["width"]), int(mon["height"])
    except Exception:
        return 1920, 1080

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
                pts = []
                for row in rows:
                    parts = [p.strip() for p in row.split(",")]
                    if len(parts) == 2:
                        pts.append([int(parts[0]), int(parts[1])])
                if len(pts) >= 4:
                    return np.array(pts[:4], dtype=np.float32)
        except:
            pass
    
    return np.array(calc_points_from_resolution(screen_w, screen_h), dtype=np.float32)

def calculate_homography(pts_src):
    outer_dist = 5
    pts_dst = np.array([[-outer_dist, -outer_dist], [outer_dist, -outer_dist], 
                       [-outer_dist, outer_dist], [outer_dist, outer_dist]], dtype=np.float32)
    h, mask = cv2.findHomography(pts_src, pts_dst, cv2.RANSAC)
    return h

def load_models():
    token_model = YOLO(os.path.join(installPath, "blue.pt"))
    sprinkler_model = None
    
    if DRIFT_CORRECTION_METHOD == 'AI':
        try:
            sprinkler_model = YOLO(os.path.join(installPath, "sprinkler.pt"))
            log_message("Sprinkler model loaded successfully for AI drift correction.")
        except Exception as e:
            log_message(f"Failed to load sprinkler model: {e}")
            print(f"Warning: Could not load sprinkler.pt: {e}")
            print("Falling back to SATURATOR method")
    
    return token_model, sprinkler_model

def relative_distance(x, y, h):
    y += 15
    point = np.array([[x, y]], dtype=np.float32).reshape(-1, 1, 2)
    transformed_point = cv2.perspectiveTransform(point, h)
    tx, ty = transformed_point[0][0]
    ty *= -1
    return tx, ty

def calculate_distance_penalty(distance):
    if distance <= PENALTY_START_DISTANCE:
        return 1.0
    
    if distance >= MAX_ALLOWED_DISTANCE:
        return 0.0
    
    normalized_distance = (distance - PENALTY_START_DISTANCE) / (MAX_ALLOWED_DISTANCE - PENALTY_START_DISTANCE)
    penalty = (1.0 - normalized_distance) ** DISTANCE_PENALTY_EXPONENT
    
    return max(0.0, penalty)

def validate_movement_distance(tx, ty):
    if not PRE_MOVEMENT_VALIDATION:
        return True
    
    future_x = current_x + tx
    future_y = current_y + ty
    future_distance = math.hypot(future_x, future_y)
    
    if future_distance > MAX_ALLOWED_DISTANCE:
        print(f"Movement blocked: would exceed max distance ({future_distance:.1f} > {MAX_ALLOWED_DISTANCE})")
        return False
    
    return True

def find_closest_sprinkler(frame, sprinkler_model, h):
    if not sprinkler_model:
        return None
    
    from PIL import ImageGrab
    
    screen = ImageGrab.grab()
    screen_resized = screen.resize((1366, 768))
    screen_array = np.array(screen_resized)
    screen_bgr = cv2.cvtColor(screen_array, cv2.COLOR_RGB2BGR)
    
    results = sprinkler_model(screen_bgr, conf=0.4, verbose=False)
    
    if not results or not results[0].boxes:
        return None
    
    best_sprinkler = None
    closest_distance = float('inf')
    
    screen_w, screen_h = get_current_resolution()
    scale_x = screen_w / 1366
    scale_y = screen_h / 768
    
    for box in results[0].boxes:
        confidence = float(box.conf[0])
        if confidence < SPRINKLER_CONFIDENCE_THRESHOLD:
            continue
            
        cls = int(box.cls[0])
        sprinkler_name = sprinkler_model.names[cls]
        
        if sprinkler_name != SPRINKLER_TYPE:
            continue
        
        x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int)
        center_x = ((x1 + x2) / 2) * scale_x
        center_y = ((y1 + y2) / 2) * scale_y
        
        tx, ty = relative_distance(center_x, center_y, h)
        distance = math.hypot(tx, ty)
        
        if distance < closest_distance:
            closest_distance = distance
            best_sprinkler = (tx, ty, sprinkler_name, distance)
    
    if best_sprinkler:
        tx, ty, name, dist = best_sprinkler
        print(f"Found {name} sprinkler at distance {dist:.1f}")
        return (tx, ty)
    
    return None

def return_to_origin(frame=None, sprinkler_model=None, h=None):
    global current_x, current_y, movement_count
    
    if abs(current_x) > 0.1 or abs(current_y) > 0.1:
        print(f"Reverting movement from position ({current_x:.2f}, {current_y:.2f})")
        execute_movement_direct(-current_x, -current_y, update_position=False)
        current_x = 0.0
        current_y = 0.0
        print("Returned to origin (0,0)")
    
    if DRIFT_CORRECTION_METHOD == 'AI' and frame is not None and sprinkler_model is not None:
        max_retries = 2
        for attempt in range(max_retries + 1):
            with mss.mss() as sct:
                fresh_frame = np.array(sct.grab(sct.monitors[1]))
                fresh_frame = cv2.cvtColor(fresh_frame, cv2.COLOR_RGB2BGR)
            
            sprinkler_pos = find_closest_sprinkler(fresh_frame, sprinkler_model, h)
            if sprinkler_pos:
                tx, ty = sprinkler_pos
                print(f"Moving to {SPRINKLER_TYPE} sprinkler for AI drift correction")
                execute_movement_direct(tx, ty, update_position=False)
                movement_count = 0
                print("Moved to sprinkler, movement counter reset")
                return
            else:
                if attempt < max_retries:
                    print(f"No {SPRINKLER_TYPE} sprinkler found, retrying... (attempt {attempt + 1}/{max_retries + 1})")
                    time.sleep(0.5)
                else:
                    print(f"No {SPRINKLER_TYPE} sprinkler found after {max_retries + 1} attempts, continuing at origin")
                    movement_count = 0
                    return
    
    print("Using saturator for drift correction")
    send_saturator_command()
    movement_count = 0
    print("Saturator called, movement counter reset")

def execute_movement_direct(tx, ty, update_position=True):
    global current_x, current_y, movement_count
    
    print(f"Moving: {abs(tx):.1f},{abs(ty):.1f}")
    
    distance_one = math.sqrt(2) * min(abs(tx), abs(ty))
    distance_two = abs(abs(tx) - abs(ty))
    
    if distance_one < 0.1: distance_one = 0
    if distance_two < 0.1: distance_two = 0
    
    direction_one, direction_two = calculate_movement_directions(tx, ty, distance_one, distance_two)
    
    if direction_one and direction_two:
        if COMMUNICATION_METHOD == "COM":
            send_com_command("MOVEMENT", direction_one, f"{abs(distance_one):.3f}", 
                           direction_two, f"{abs(distance_two):.3f}")
        else:
            command_text = f"{direction_one},{abs(distance_one):.3f}\n{direction_two},{abs(distance_two):.3f}"
            if not send_and_wait(command_text):
                print("Movement command failed - trying simple w,0")
                send_and_wait("w,0")
    
    if update_position:
        current_x += tx
        current_y += ty
        movement_count += 1
        print(f"Position: ({current_x:.2f}, {current_y:.2f}) | Movements: {movement_count}")

def execute_movement(tx, ty, frame=None, sprinkler_model=None, h=None):
    global movement_count
    
    if not validate_movement_distance(tx, ty):
        print("Movement rejected due to distance validation, returning to origin")
        return_to_origin(frame, sprinkler_model, h)
        return
    
    if movement_count >= MOVEMENTS_BEFORE_SATURATOR:
        print(f"Reached {MOVEMENTS_BEFORE_SATURATOR} movements, returning to origin")
        return_to_origin(frame, sprinkler_model, h)
        return
    
    execute_movement_direct(tx, ty)

def calculate_movement_directions(tx, ty, distance_one, distance_two):
    if tx > 0 and ty > 0:
        return ("d", "w") if tx > ty else ("w", "d")
    elif tx > 0 and ty < 0:
        return ("d", "s") if tx > abs(ty) else ("s", "d")
    elif tx < 0 and ty > 0:
        return ("a", "w") if abs(tx) > ty else ("w", "a")
    elif tx < 0 and ty < 0:
        return ("a", "s") if abs(tx) > abs(ty) else ("s", "a")
    return "", ""

def send_saturator_command():
    if COMMUNICATION_METHOD == "COM":
        send_com_command("SATURATOR")
    else:
        send_and_wait("MOVE_TO_SATURATOR")

def parse_priority_tokens(token_string):
    tokens = []
    if not token_string:
        return tokens
    
    parts = [part.strip() for part in token_string.split(',')]
    for part in parts:
        if ':' in part:
            try:
                name, value = part.split(':', 1)
                tokens.append((name.strip(), int(value.strip())))
            except ValueError:
                print(f"Warning: Could not parse priority token entry '{part}'. Skipping.")
        elif part:
            tokens.append(part)
    return tokens

def parse_ignore_tokens(token_string):
    if not token_string:
        return []
    return [token.strip() for token in token_string.split(',') if token.strip()]

priority_tokens_str = config.get('AIGather', 'priority_tokens', fallback="Token Link:100, Focus")
priority_tokens = parse_priority_tokens(priority_tokens_str)
ignore_tokens_str = config.get('AIGather', 'ignore_tokens', fallback="Balloon")
ignore_tokens = parse_ignore_tokens(ignore_tokens_str)

def get_token_importance(token_name):
    total_items = len(priority_tokens)
    for i, token_data in enumerate(priority_tokens):
        if isinstance(token_data, tuple) and token_data[0] == token_name:
            return token_data[1]
        elif token_data == token_name:
            return (total_items * 2) - (i * 2)
    return 0

def calculate_token_score(importance, distance):
    distance_penalty = calculate_distance_penalty(distance)
    final_score = importance * distance_penalty
    
    return final_score

def find_best_token(boxes, h, labels):
    if not boxes:
        return None
    
    best_token, best_score, best_info = None, 0, ""
    
    for box in boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        
        if (x2 - x1) * (y2 - y1) > 100 * 100:
            continue
        
        tx, ty = relative_distance((x1 + x2) / 2, (y1 + y2) / 2, h)
        token_name = labels[box.cls.item()]
        importance = get_token_importance(token_name)
        
        if importance == 0:
            continue
        
        distance = math.hypot(tx, ty)
        
        if distance > MAX_ALLOWED_DISTANCE:
            continue
        
        score = calculate_token_score(importance, distance)
        penalty = calculate_distance_penalty(distance)
        
        if score > best_score:
            best_score, best_token = score, (tx, ty)
            best_info = f"{token_name} (score:{score:.1f}, penalty:{penalty:.2f})"
    
    if best_token:
        print(f"Best token: {best_info}")
    
    return best_token

def filter_valid_tokens(boxes, labels):
    return [box for box in boxes if box.conf.item() >= CONFIDENCE_THRESHOLD 
            and labels[box.cls.item()] not in ignore_tokens]

def main():
    log_message("--- YOLO Script Started ---")
    print(f"[YOLO] Starting with communication method: {COMMUNICATION_METHOD}")
    print(f"[YOLO] Max FPS: {MAX_FPS}")
    print(f"[YOLO] Movements before saturator: {MOVEMENTS_BEFORE_SATURATOR}")
    print(f"[YOLO] Distance config - Safe: {SAFE_DISTANCE}, Max: {MAX_ALLOWED_DISTANCE}, Penalty exp: {DISTANCE_PENALTY_EXPONENT}")
    print(f"[YOLO] Drift correction method: {DRIFT_CORRECTION_METHOD}")
    if DRIFT_CORRECTION_METHOD == 'AI':
        print(f"[YOLO] Target sprinkler type: {SPRINKLER_TYPE}")
        print(f"[YOLO] Sprinkler confidence threshold: {SPRINKLER_CONFIDENCE_THRESHOLD}")
    
    log_message(f"Communication method: {COMMUNICATION_METHOD}")
    log_message(f"Max FPS: {MAX_FPS}")
    log_message(f"Movements before saturator: {MOVEMENTS_BEFORE_SATURATOR}")
    log_message(f"Distance penalty system enabled - Safe: {SAFE_DISTANCE}, Max: {MAX_ALLOWED_DISTANCE}")
    log_message(f"Drift correction method: {DRIFT_CORRECTION_METHOD}")
    
    try:
        token_model, sprinkler_model = load_models()
        log_message("Token model loaded successfully.")
    except Exception as e:
        log_message(f"FATAL: Failed to load YOLO models: {e}")
        ctypes.windll.user32.MessageBoxW(0, f"Failed to load AI models: {e}", "YOLO Error", 0x1030)
        sys.exit(1)
    
    h = calculate_homography(load_settings())
    
    if COMMUNICATION_METHOD == "COM":
        initialize_com_client()
    else:
        start_server()
    
    gathering_active = False
    frame_time = 1.0 / MAX_FPS
    last_saturator_time = 0
    
    while True:
        loop_start = time.time()
        
        if COMMUNICATION_METHOD == "SOCKET" and g_conn is None:
            accept_connection()
            time.sleep(0.1)
            continue
        
        is_gathering_now = os.path.exists(GATHER_STATE_FILE)
        
        if is_gathering_now and not gathering_active:
            print("[YOLO] Gather session started.")
            gathering_active = True
        
        if not is_gathering_now:
            if gathering_active:
                print("[YOLO] Gather session ended.")
                gathering_active = False
            time.sleep(0.1)
            continue
        
        with mss.mss() as sct:
            frame = np.array(sct.grab(sct.monitors[1]))
            frame = frame[:, :, :3]
        
        results = token_model(frame, imgsz=1376, verbose=False)
        
        valid_boxes = filter_valid_tokens(list(results[0].boxes), token_model.names) if results and results[0].boxes else []
        best_token = find_best_token(valid_boxes, h, token_model.names)

        if best_token:
            execute_movement(*best_token, frame, sprinkler_model, h)
            last_saturator_time = time.time()

        current_time = time.time()
        if current_time - last_saturator_time >= DRIFT_CORRECTION_TIMEOUT:
            print(f"No valid tokens found for {DRIFT_CORRECTION_TIMEOUT} seconds, returning to origin")
            return_to_origin(frame, sprinkler_model, h)
            last_saturator_time = current_time

        elapsed = time.time() - loop_start
        sleep_time = max(0, frame_time - elapsed)
        if sleep_time > 0:
            time.sleep(sleep_time)

if __name__ == "__main__":
    main()

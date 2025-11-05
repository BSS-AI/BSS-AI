const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { exec, spawn } = require('child_process');
const ini = require('ini');
const fs = require("fs")

let mainWindow;
let tokenPriorityWindow = null;
let ahkProcess = null;
let processCheckInterval = null;

function getSettingsPath(filePath = 'settings.ini') {
  const appdata = path.join(process.env.APPDATA, "BSSAI")
  return path.join(appdata, 'settings', filePath);
}

function checkAhkProcess() {
  if (!ahkProcess) return;

  exec('tasklist /FI "IMAGENAME eq yolo.exe" /FO CSV /NH', (err, stdout) => {
    if (err) {
      console.error('Failed to check process:', err);
      return;
    }

    const isRunning = stdout.includes('yolo.exe');

    if (!isRunning && ahkProcess) {
      console.log('yolo.exe process detected as stopped externally.');
      ahkProcess = null;

      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('macro-status', { status: 'stopped' });
      }
    }
  });
}

function startProcessMonitoring() {
  if (processCheckInterval) {
    clearInterval(processCheckInterval);
  }
  processCheckInterval = setInterval(checkAhkProcess, 1000);
}

function stopProcessMonitoring() {
  if (processCheckInterval) {
    clearInterval(processCheckInterval);
    processCheckInterval = null;
  }
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1000,
    height: 700,
    minWidth: 800,
    minHeight: 600,
    frame: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
      allowRunningInsecureContent: false,
      experimentalFeatures: false,
      enableBlinkFeatures: undefined,
      sandbox: false
    },
    icon: path.join(__dirname, 'assets/bssAiLogo.png')
  });

  mainWindow.setMenuBarVisibility(false)

  mainWindow.webContents.on('before-input-event', (event, input) => {
    const isDevToolsShortcut =
      (input.control || input.meta) && input.shift && input.key.toLowerCase() === 'i';
    const isF12 = input.key === 'F12';

    if (isDevToolsShortcut || isF12) {
      event.preventDefault();
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'public', 'index.html'));

  mainWindow.webContents.on('will-navigate', (e, url) => {
    const allowed = /^file:\/\//.test(url) || /localhost:5173/.test(url)
    if (!allowed) e.preventDefault()
  })

  ipcMain.on('minimize-window', () => {
    mainWindow.minimize();
  });

  ipcMain.on('maximize-window', () => {
    if (mainWindow.isMaximized()) {
      mainWindow.unmaximize();
    } else {
      mainWindow.maximize();
    }
  });

  ipcMain.on('close-window', () => {
    app.quit();
  });
}

app.whenReady().then(async () => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  stopProcessMonitoring();
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  stopProcessMonitoring();
});

ipcMain.removeAllListeners('read-settings');
ipcMain.removeAllListeners('write-settings');
ipcMain.removeAllListeners('start-macro');
ipcMain.removeAllListeners('stop-macro');

ipcMain.on('read-settings', (event, filePath = 'settings.ini') => {
  const fullPath = getSettingsPath(filePath);

  try {
    const settingsDir = path.dirname(fullPath);
    if (!fs.existsSync(settingsDir)) {
      fs.mkdirSync(settingsDir, { recursive: true });
    }

    let config = {};
    if (fs.existsSync(fullPath)) {
      config = ini.parse(fs.readFileSync(fullPath, 'utf-8'));
    }

    event.reply('settings-read', config);
  } catch (error) {
    console.error('Failed to read INI file:', error);
    event.reply('settings-read-error', error.message);
  }
});

ipcMain.on('write-settings', (event, { section, key, value, filePath = 'settings.ini' }) => {
  const fullPath = getSettingsPath(filePath);

  try {
    const settingsDir = path.dirname(fullPath);
    if (!fs.existsSync(settingsDir)) {
      fs.mkdirSync(settingsDir, { recursive: true });
    }

    let config = {};
    if (fs.existsSync(fullPath)) {
      config = ini.parse(fs.readFileSync(fullPath, 'utf-8'));
    }

    if (!config[section]) {
      config[section] = {};
    }
    config[section][key] = value;

    fs.writeFileSync(fullPath, ini.stringify(config));
    event.reply('settings-written', { success: true });
  } catch (error) {
    console.error('Failed to write INI file:', error);
    event.reply('settings-written', { success: false, error: error.message });
  }
});

ipcMain.on('start-macro', (event, args = []) => {
  if (ahkProcess) {
    console.log('Macro already running.');
    event.reply('macro-status', { status: 'already_running' });
    return;
  }
  try {
    const file = path.join("C:", "ProgramData", "BSSAI", ".install-location.txt");
    
    if (!fs.existsSync(file)) {
      dialog.showErrorBox(
        "Macro Not Installed!",
        "Installation location file not found. Please reinstall the macro."
      );
      return event.reply('macro-status', { status: 'not_running' });
    }
    
    const installLocation = fs.readFileSync(file, "utf8").trim();
    const ahkExe = path.join(installLocation, "lib", "AutoHotKey64.exe");
    const ahkScript = path.join(installLocation, "bssai.ahk");
    
    if (!fs.existsSync(ahkExe)) {
      dialog.showErrorBox(
        "Macro Not Installed!",
        "AutoHotKey64.exe not found in the installation directory. Please reinstall the macro."
      );
      return event.reply('macro-status', { status: 'not_running' });
    }

    if (!fs.existsSync(ahkScript)) {
      dialog.showErrorBox(
        "Macro Not Installed!",
        "bssai.ahk not found in the installation directory. Please reinstall the macro."
      );
      return event.reply('macro-status', { status: 'not_running' });
    }

    ahkProcess = spawn(ahkExe, [ahkScript], { detached: true, stdio: 'ignore' });
    ahkProcess.unref();
    setTimeout(startProcessMonitoring, 20000)
  } catch (e) {
    console.error(e)
    dialog.showErrorBox(
      "Macro Not Installed!",
      "The GUI was unable to start the macro because it could not find bssai.ahk. Please redownload the macro from the origional source, and ensure no outside program is deleting the files."
    );
    return event.reply('macro-status', { status: 'not_running' });
  }
});

ipcMain.on('stop-macro', (event) => {
  if (!ahkProcess) {
    console.log('No macro running to stop.');
    event.reply('macro-status', { status: 'not_running' });
    return;
  }

  ahkProcess.kill();
  ahkProcess = null;
  stopProcessMonitoring();

  if (process.platform === 'win32') {
    exec('taskkill /F /IM AutoHotKey64.exe /T', (err) => {
      if (err) console.warn('Failed to kill bssai.ahk:', err.message);
    });

    exec('taskkill /F /IM yolo.exe /T', (err) => {
      if (err) console.warn('Failed to kill yolo.exe:', err.message);
    });
  } else {
    console.warn('Process killing for non-Windows OS is not fully implemented.');
  }

  console.log('Macro stopped.');
  event.reply('macro-status', { status: 'stopped' });
});

ipcMain.on('open-token-priority-window', () => {
  if (tokenPriorityWindow) {
    tokenPriorityWindow.focus();
    return;
  }

  tokenPriorityWindow = new BrowserWindow({
    width: 800,
    height: 700,
    minWidth: 700,
    minHeight: 600,
    frame: false,
    parent: mainWindow,
    modal: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
      allowRunningInsecureContent: false,
      experimentalFeatures: false,
      enableBlinkFeatures: undefined,
      sandbox: false
    },
    icon: path.join(__dirname, 'assets/bssAiLogo.png')
  });

  mainWindow.setMenuBarVisibility(false)

  tokenPriorityWindow.webContents.on('before-input-event', (event, input) => {
    const isDevToolsShortcut =
      (input.control || input.meta) && input.shift && input.key.toLowerCase() === 'i';
    const isF12 = input.key === 'F12';

    if (isDevToolsShortcut || isF12) {
      event.preventDefault();
    }
  });

  tokenPriorityWindow.loadFile(path.join(__dirname, 'public', 'tokenPriority.html'))

  tokenPriorityWindow.on('closed', () => {
    tokenPriorityWindow = null;
  });
});

ipcMain.on('close-token-priority-window', () => {
  if (tokenPriorityWindow) {
    tokenPriorityWindow.close();
  }
});

ipcMain.on('minimize-token-priority-window', () => {
  if (tokenPriorityWindow) {
    tokenPriorityWindow.minimize();
  }
});

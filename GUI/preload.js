const { ipcRenderer, contextBridge, shell } = require('electron')

let settingsReadListener = null
let settingsReadErrorListener = null
let settingsWrittenListener = null
let macroStatusListener = null

const removeSettingsListeners = () => {
  if (settingsReadListener) {
    ipcRenderer.removeListener('settings-read', settingsReadListener)
    settingsReadListener = null
  }
  if (settingsReadErrorListener) {
    ipcRenderer.removeListener('settings-read-error', settingsReadErrorListener)
    settingsReadErrorListener = null
  }
  if (settingsWrittenListener) {
    ipcRenderer.removeListener('settings-written', settingsWrittenListener)
    settingsWrittenListener = null
  }
}

contextBridge.exposeInMainWorld('electron', {
  minimize: () => ipcRenderer.send('minimize-window'),
  maximize: () => ipcRenderer.send('maximize-window'),
  close: () => ipcRenderer.send('close-window'),
  openExternal: (url) => shell.openExternal(url),
  readSettings: (filePath) => ipcRenderer.send('read-settings', filePath),
  onSettingsRead: (callback) => {
    removeSettingsListeners()
    settingsReadListener = (event, args) => callback(args)
    ipcRenderer.on('settings-read', settingsReadListener)
  },
  onSettingsReadError: (callback) => {
    if (settingsReadErrorListener) ipcRenderer.removeListener('settings-read-error', settingsReadErrorListener)
    settingsReadErrorListener = (event, args) => callback(args)
    ipcRenderer.on('settings-read-error', settingsReadErrorListener)
  },
  writeSettings: (section, key, value, filePath) => ipcRenderer.send('write-settings', { section, key, value, filePath }),
  onSettingsWritten: (callback) => {
    if (settingsWrittenListener) ipcRenderer.removeListener('settings-written', settingsWrittenListener)
    settingsWrittenListener = (event, args) => callback(args)
    ipcRenderer.on('settings-written', settingsWrittenListener)
  },
  startMacro: () => ipcRenderer.send('start-macro'),
  stopMacro: () => ipcRenderer.send('stop-macro'),
  onMacroStatus: (callback) => {
    if (macroStatusListener) ipcRenderer.removeListener('macro-status', macroStatusListener)
    macroStatusListener = (event, args) => callback(args)
    ipcRenderer.on('macro-status', macroStatusListener)
  },
  removeSettingsListeners: removeSettingsListeners,
  openTokenPriorityWindow: () => ipcRenderer.send('open-token-priority-window'),
  closeWindow: () => ipcRenderer.send('close-token-priority-window'),
  minimizeWindow: () => ipcRenderer.send('minimize-window')
})

contextBridge.exposeInMainWorld('electronAPI', {
  openTokenPriorityWindow: () => ipcRenderer.send('open-token-priority-window'),
  closeWindow: () => ipcRenderer.send('close-token-priority-window'),
  minimizeWindow: () => ipcRenderer.send('minimize-token-priority-window')
})

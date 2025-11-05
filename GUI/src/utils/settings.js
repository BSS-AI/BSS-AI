import { useState, useEffect, useCallback, useRef } from 'react';

export function useSettings(initialSettings = {}, filePath = 'settings.ini') {
  const [settings, setSettings] = useState(initialSettings);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const listenersAttached = useRef(false);

  const readSettings = useCallback(async () => {
    if (!window.electron) {
      console.warn('Electron IPC not available. Running in browser mode.');
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);

    return new Promise((resolve, reject) => {
      const handleSettingsRead = (config) => {
        setSettings(config);
        setLoading(false);
        resolve(config);
      };

      const handleSettingsReadError = (err) => {
        console.error('Error reading settings:', err);
        setError(err);
        setLoading(false);
        reject(err);
      };

      window.electron.removeSettingsListeners?.();

      window.electron.onSettingsRead(handleSettingsRead);
      window.electron.onSettingsReadError(handleSettingsReadError);
      window.electron.readSettings(filePath);
    });
  }, [filePath]);

  const updateSetting = useCallback(async (section, key, value, customFilePath = filePath) => {
    if (!window.electron) {
      console.warn('Electron IPC not available. Cannot write settings.');
      return;
    }

    setSettings(prevSettings => ({
      ...prevSettings,
      [section]: {
        ...(prevSettings[section] || {}),
        [key]: value,
      },
    }));

    return new Promise((resolve, reject) => {
      const handleSettingsWritten = (response) => {
        if (response.success) {
          console.log(`Setting ${section}.${key} updated to ${value}`);
          resolve(response);
        } else {
          console.error(`Failed to write setting ${section}.${key}:`, response.error);
          setError(response.error);

          setSettings(prevSettings => {
            const newSettings = { ...prevSettings };
            if (initialSettings[section] && initialSettings[section][key] !== undefined) {
              newSettings[section][key] = initialSettings[section][key];
            } else {
              delete newSettings[section][key];
            }
            return newSettings;
          });
          reject(response.error);
        }
      };

      window.electron.removeSettingsListeners?.();

      window.electron.onSettingsWritten(handleSettingsWritten);
      window.electron.writeSettings(section, key, value, customFilePath);
    });
  }, [initialSettings, filePath]);

  useEffect(() => {
    if (!listenersAttached.current) {
      readSettings();
      listenersAttached.current = true;
    }

    return () => {
      if (window.electron?.removeSettingsListeners) {
        window.electron.removeSettingsListeners();
      }
    };
  }, [readSettings]);

  return { settings, updateSetting, loading, error, readSettings };
}

export const getSetting = (settings, section, key, defaultValue = null) => {
  if (settings && settings[section] && settings[section][key] !== undefined) {
    const value = settings[section][key];
    return value;
  }
  return defaultValue;
};

export const boolToIni = (value) => (value ? 'true' : 'false');

export const parseIniValue = (value) => {
  if (value === 'true') return true;
  if (value === 'false') return false;
  if (value === '0') return false;
  if (value === '1') return true;
  if (!isNaN(value) && !isNaN(parseFloat(value))) return parseFloat(value);
  return value;
};
import { useState, useEffect, useCallback, useRef } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { listen, emit } from '@tauri-apps/api/event';

export function useSettings(initialSettings: any = {}, filePath = 'settings.ini') {
  const [settings, setSettings] = useState(initialSettings);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const listenersAttached = useRef(false);

  const readSettings = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const fullPath = await invoke<string>('get_settings_full_path', { filePath });
      console.log('[Settings] Reading from full path:', fullPath);
      const config = await invoke<any>('read_settings', { filePath });
      console.log('[Settings] Successfully read settings from:', fullPath);
      setSettings(config);
      setLoading(false);
      return config;
    } catch (err: any) {
      console.error('[Settings] Error reading settings from', filePath, ':', err);
      setError(err.toString());
      setLoading(false);
      throw err;
    }
  }, [filePath]);

  const updateSetting = useCallback(async (section: string, key: string, value: any, customFilePath = filePath) => {
    setSettings((prevSettings: any) => ({
      ...prevSettings,
      [section]: {
        ...(prevSettings[section] || {}),
        [key]: value,
      },
    }));

    try {
      const fullPath = await invoke<string>('get_settings_full_path', { filePath: customFilePath });
      console.log(`[Settings] Writing ${section}.${key}=${value} to full path:`, fullPath);
      await invoke('write_settings', {
        section,
        key,
        value: value.toString(),
        filePath: customFilePath
      });
      console.log(`[Settings] Successfully wrote ${section}.${key} to ${fullPath}`);
      await emit('setting-changed', { section, key, value });
    } catch (err: any) {
      const fullPath = await invoke<string>('get_settings_full_path', { filePath: customFilePath });
      console.error(`[Settings] Failed to write ${section}.${key} to ${fullPath}:`, err);
      setError(err.toString());

      setSettings((prevSettings: any) => {
        const newSettings = { ...prevSettings };
        if (initialSettings[section] && initialSettings[section][key] !== undefined) {
          newSettings[section][key] = initialSettings[section][key];
        } else {
          delete newSettings[section][key];
        }
        return newSettings;
      });
      throw err;
    }
  }, [initialSettings, filePath]);

  useEffect(() => {
    if (!listenersAttached.current) {
      readSettings();
      listenersAttached.current = true;
    }
  }, [readSettings]);

  useEffect(() => {
    const unlisten = listen('setting-changed', (event: any) => {
      const { section, key, value } = event.payload;
      setSettings((prev: any) => ({
        ...prev,
        [section]: {
          ...(prev[section] || {}),
          [key]: value,
        },
      }));
    });

    return () => {
      unlisten.then(f => f());
    };
  }, []);

  return { settings, updateSetting, loading, error, readSettings };
}

export const getSetting = (settings: any, section: string, key: string, defaultValue: any = null) => {
  if (settings && settings[section] && settings[section][key] !== undefined) {
    const value = settings[section][key];
    return value;
  }
  return defaultValue;
};

export const boolToIni = (value: boolean) => (value ? 'true' : 'false');

export const parseIniValue = (value: any) => {
  if (value === 'true') return true;
  if (value === 'false') return false;
  if (value === '0') return false;
  if (value === '1') return true;
  if (!isNaN(value) && !isNaN(parseFloat(value))) return parseFloat(value);
  return value;
};

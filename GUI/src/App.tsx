import React, { useState, useEffect } from 'react';
import { listen } from '@tauri-apps/api/event';
import { invoke } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { useSettings, getSetting, parseIniValue } from './utils/settings';

import MainLayout from './components/layout/MainLayout';
import BoostTab from './components/BoostTab';
import CollectTab from './components/CollectTab';
import GatherTab from './components/GatherTab';
import KillTab from './components/KillTab';
import PlanterTab from './components/PlanterTab';
import QuestTab from './components/QuestTab';
import SettingsTab from './components/SettingsTab';
import VichopTab from './components/VichopTab';

function App() {
  const appWindow = getCurrentWindow();
  const { settings } = useSettings();
  const [activeTab, setActiveTab] = useState('gather');
  const [macroStatus, setMacroStatus] = useState('stopped');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [theme, setTheme] = useState(() => {
    try {
      return localStorage.getItem('ui-theme') || 'dark';
    } catch (err) {
      return 'dark';
    }
  });

  // Apply window settings (Always On Top & Opacity)
  useEffect(() => {
    if (settings && settings.Settings) {
      // Always On Top
      const alwaysOnTop = parseIniValue(getSetting(settings, 'Settings', 'alwaysontop', false));
      appWindow.setAlwaysOnTop(alwaysOnTop).catch(err => console.error("Failed to set always on top:", err));

      // Opacity
      const opacityStr = getSetting(settings, 'Settings', 'opacity', '100');
      const opacity = parseFloat(opacityStr) / 100;
      // Ensure opacity is valid and at least 0.1 (10%) to prevent invisible window
      const safeOpacity = isNaN(opacity) ? 1 : Math.max(0.1, Math.min(1, opacity));

      document.documentElement.style.opacity = safeOpacity.toString();

      // Window Blur
      const blurEnabled = parseIniValue(getSetting(settings, 'Settings', 'blurwindow', false));
      invoke('set_window_blur', { enable: blurEnabled }).catch(err => console.error("Failed to set window blur:", err));

      if (blurEnabled) {
        document.documentElement.classList.add('blur-enabled');
      } else {
        document.documentElement.classList.remove('blur-enabled');
      }
    }
  }, [settings]);

  useEffect(() => {
    const unlisten = listen('macro-status', (event: any) => {
      setMacroStatus(event.payload.status);
      if (event.payload.status === 'error') {
        console.error('Macro Error:', event.payload.message);
        setErrorMessage(event.payload.message);
      }
    });

    return () => {
      unlisten.then(fn => fn());
    };
  }, []);

  const handleStartMacro = async () => {
    try {
      await invoke('start_macro');
    } catch (error) {
      console.error('Failed to start macro:', error);
    }
  };

  const handleStopMacro = async () => {
    try {
      await invoke('stop_macro');
    } catch (error) {
      console.error('Failed to stop macro:', error);
    }
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'F1') {
        e.preventDefault();
        handleStartMacro();
      }
      if (e.key === 'F3') {
        e.preventDefault();
        handleStopMacro();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  useEffect(() => {
    console.log('[Theme] Switching to:', theme);

    // Remove all theme classes first
    document.documentElement.classList.remove('theme-dark', 'theme-light', 'theme-tokyo', 'theme-nord', 'theme-dracula', 'theme-catppuccin', 'theme-sakuramochi');
    // Clear custom properties
    document.documentElement.removeAttribute('style');
    // Re-apply opacity if it was set separately
    if (settings && settings.Settings) {
      const opacityStr = getSetting(settings, 'Settings', 'opacity', '100');
      const opacity = parseFloat(opacityStr) / 100;
      const safeOpacity = isNaN(opacity) ? 1 : Math.max(0.1, Math.min(1, opacity));
      document.documentElement.style.opacity = safeOpacity.toString();
    }

    if (theme.startsWith('custom-')) {
      try {
        const stored = localStorage.getItem('custom_themes');
        if (stored) {
          const themes = JSON.parse(stored);
          const customTheme = themes.find((t: any) => t.id === theme);
          if (customTheme) {
            const c = customTheme.colors;
            const style = document.documentElement.style;
            style.setProperty('--bg-primary', c.bgPrimary);
            style.setProperty('--bg-secondary', c.bgSecondary);
            style.setProperty('--bg-tertiary', c.bgTertiary);
            style.setProperty('--bg-surface', c.bgSurface);

            style.setProperty('--text-primary', c.textPrimary);
            style.setProperty('--text-secondary', c.textSecondary);
            style.setProperty('--text-muted', c.textMuted);

            style.setProperty('--accent-primary', c.accentPrimary);
            style.setProperty('--accent-secondary', c.accentSecondary);
            style.setProperty('--accent-tertiary', c.accentTertiary);
            style.setProperty('--accent-hover', c.accentHover);

            style.setProperty('--status-success', c.statusSuccess);
            style.setProperty('--status-warning', c.statusWarning);
            style.setProperty('--status-error', c.statusError);
            style.setProperty('--status-info', c.statusInfo);

            style.setProperty('--glass-border', c.glassBorder);
          }
        }
      } catch (e) {
        console.error("Failed to load custom theme colors", e);
      }
    } else {
      // Add the current theme class
      document.documentElement.classList.add(`theme-${theme}`);
    }

    // Also set as data attribute for debugging
    document.documentElement.setAttribute('data-ui-theme', theme);

    try {
      localStorage.setItem('ui-theme', theme);
      console.log('[Theme] Saved to localStorage:', theme);
    } catch (err) {
      console.error('[Theme] Failed to save to localStorage:', err);
    }
  }, [theme, settings]);

  const handleThemeChange = (selectedTheme: string) => {
    setTheme(selectedTheme);
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'boost':
        return <BoostTab />;
      case 'collect':
        return <CollectTab />;
      case 'gather':
        return <GatherTab />;
      case 'kill':
        return <KillTab />;
      case 'planter':
        return <PlanterTab />;
      case 'quest':
        return <QuestTab />;
      case 'vichop':
        return <VichopTab />;
      case 'settings':
        return <SettingsTab currentTheme={theme} onThemeChange={handleThemeChange} />;
      default:
        return <GatherTab />;
    }
  };

  return (
    <>
      <MainLayout
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        macroStatus={macroStatus}
        onStartMacro={handleStartMacro}
        onStopMacro={handleStopMacro}
        theme={theme}
      >
        {renderContent()}
      </MainLayout>

      {/* Error Modal */}
      {errorMessage && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-[100] animate-fade-in">
          <div className="bg-background-surface border border-status-error/50 rounded-xl shadow-2xl p-6 max-w-md w-full mx-4">
            <div className="flex items-start mb-4">
              <div className="flex-shrink-0 w-12 h-12 bg-status-error/20 rounded-full flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-status-error" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-white mb-2">Error Occurred</h3>
                <div className="text-text-secondary whitespace-pre-wrap text-sm font-mono bg-black/30 p-4 rounded-lg border border-white/5 max-h-64 overflow-auto custom-scrollbar">
                  {errorMessage}
                </div>
              </div>
            </div>
            <div className="flex justify-end mt-6">
              <button
                onClick={() => setErrorMessage(null)}
                className="px-6 py-2.5 bg-status-error hover:bg-red-600 text-white rounded-lg font-semibold transition-all duration-200 shadow-lg shadow-red-900/20"
              >
                Dismiss
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default App;

import React, { useState, useEffect } from 'react';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { emit } from '@tauri-apps/api/event';
import Button from './UI/Button';
import Input from './UI/Input';

interface Theme {
    id: string;
    name: string;
    colors: {
        bgPrimary: string;
        bgSecondary: string;
        bgTertiary: string;
        bgSurface: string;
        textPrimary: string;
        textSecondary: string;
        textMuted: string;
        accentPrimary: string;
        accentSecondary: string;
        accentTertiary: string;
        accentHover: string;
        statusSuccess: string;
        statusWarning: string;
        statusError: string;
        statusInfo: string;
        glassBorder: string;
    };
}

const defaultColors = {
    bgPrimary: '#0f0f0f',
    bgSecondary: '#1a1a1a',
    bgTertiary: '#242424',
    bgSurface: '#2a2a2a',
    textPrimary: '#ffffff',
    textSecondary: '#a1a1aa',
    textMuted: '#71717a',
    accentPrimary: '#3b82f6',
    accentSecondary: '#8b5cf6',
    accentTertiary: '#06b6d4',
    accentHover: '#2563eb',
    statusSuccess: '#10b981',
    statusWarning: '#f59e0b',
    statusError: '#ef4444',
    statusInfo: '#3b82f6',
    glassBorder: 'rgba(255, 255, 255, 0.08)',
};

const ThemeEditorWindow: React.FC = () => {
    const [name, setName] = useState('');
    const [colors, setColors] = useState(defaultColors);
    const [editingId, setEditingId] = useState<string | null>(null);
    const [copied, setCopied] = useState(false);

    // Apply the current app theme to the editor window so it matches
    useEffect(() => {
        const currentTheme = localStorage.getItem('ui-theme') || 'dark';

        // Remove all theme classes first
        document.documentElement.classList.remove('theme-dark', 'theme-light', 'theme-tokyo', 'theme-nord', 'theme-dracula', 'theme-catppuccin', 'theme-sakuramochi');
        document.documentElement.removeAttribute('style');

        if (currentTheme.startsWith('custom-')) {
            try {
                const stored = localStorage.getItem('custom_themes');
                if (stored) {
                    const themes = JSON.parse(stored);
                    const customTheme = themes.find((t: any) => t.id === currentTheme);
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
            document.documentElement.classList.add(`theme-${currentTheme}`);
        }
        document.documentElement.setAttribute('data-ui-theme', currentTheme);
    }, []);

    useEffect(() => {
        // Parse query params to see if we are editing
        const searchParams = new URLSearchParams(window.location.search);
        const editId = searchParams.get('edit');

        if (editId) {
            try {
                const stored = localStorage.getItem('custom_themes');
                if (stored) {
                    const themes = JSON.parse(stored);
                    const themeToEdit = themes.find((t: Theme) => t.id === editId);
                    if (themeToEdit) {
                        setName(themeToEdit.name);
                        setColors(themeToEdit.colors);
                        setEditingId(editId);
                    }
                }
            } catch (e) {
                console.error("Failed to load theme for editing", e);
            }
        }
    }, []);

    const handleColorChange = (key: keyof typeof defaultColors, value: string) => {
        setColors(prev => ({ ...prev, [key]: value }));
    };

    const handleSave = async () => {
        if (!name.trim()) return;

        try {
            const stored = localStorage.getItem('custom_themes');
            let themes: Theme[] = stored ? JSON.parse(stored) : [];

            const newTheme: Theme = {
                id: editingId || `custom-${Date.now()}`,
                name,
                colors
            };

            if (editingId) {
                const index = themes.findIndex(t => t.id === editingId);
                if (index !== -1) themes[index] = newTheme;
                else themes.push(newTheme);
            } else {
                themes.push(newTheme);
            }

            localStorage.setItem('custom_themes', JSON.stringify(themes));

            // Emit event to main window to reload themes
            await emit('theme-updated');

            await getCurrentWindow().close();
        } catch (e) {
            console.error("Failed to save theme", e);
        }
    };

    const handleClose = async () => {
        await getCurrentWindow().close();
    };

    const handleExport = () => {
        const themeData = JSON.stringify({ name, colors }, null, 2);
        navigator.clipboard.writeText(themeData);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    return (
        <div className="h-screen bg-background flex flex-col font-sans text-text-primary select-none">
            {/* Header */}
            <div data-tauri-drag-region className="h-10 bg-background-secondary border-b border-glass-border flex items-center justify-between px-4 shrink-0">
                <div className="flex items-center gap-2 text-sm font-medium text-text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path></svg>
                    <span>Theme Editor</span>
                </div>
                <div className="flex gap-2">
                    <button onClick={handleExport} className="text-xs bg-background-tertiary hover:bg-background-surface px-2 py-1 rounded transition-colors text-text-secondary">
                        {copied ? "Copied" : "Export"}
                    </button>
                    <button onClick={() => getCurrentWindow().minimize()} className="p-1 hover:bg-background-tertiary rounded text-text-secondary">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    </button>
                    <button onClick={handleClose} className="p-1 hover:bg-status-error/20 hover:text-status-error rounded text-text-secondary">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">

                <div className="bg-accent-primary/10 border border-accent-primary/20 p-4 rounded-lg flex gap-3 text-sm text-accent-primary">
                    <svg className="shrink-0 mt-0.5" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                    <p>
                        Edit your theme colors below. Use Hex codes (e.g., #FF0000) or RGB/RGBA values.
                        Click 'Save Theme' to apply your changes.
                    </p>
                </div>

                <div className="space-y-4">
                    <label className="block text-xs font-semibold text-text-secondary uppercase tracking-wider">Theme Name</label>
                    <input
                        type="text"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        placeholder="My Awesome Theme"
                        className="w-full bg-background-tertiary border border-glass-border rounded-lg px-4 py-2 text-text-primary focus:outline-none focus:border-accent-primary transition-colors"
                    />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div className="space-y-3">
                        <h4 className="text-sm font-semibold text-text-muted border-b border-glass-border pb-1 mb-2">Backgrounds</h4>
                        <ColorInput label="Primary BG" value={colors.bgPrimary} onChange={(v) => handleColorChange('bgPrimary', v)} />
                        <ColorInput label="Secondary BG" value={colors.bgSecondary} onChange={(v) => handleColorChange('bgSecondary', v)} />
                        <ColorInput label="Tertiary BG" value={colors.bgTertiary} onChange={(v) => handleColorChange('bgTertiary', v)} />
                        <ColorInput label="Surface BG" value={colors.bgSurface} onChange={(v) => handleColorChange('bgSurface', v)} />
                    </div>

                    <div className="space-y-3">
                        <h4 className="text-sm font-semibold text-text-muted border-b border-glass-border pb-1 mb-2">Text</h4>
                        <ColorInput label="Primary Text" value={colors.textPrimary} onChange={(v) => handleColorChange('textPrimary', v)} />
                        <ColorInput label="Secondary Text" value={colors.textSecondary} onChange={(v) => handleColorChange('textSecondary', v)} />
                        <ColorInput label="Muted Text" value={colors.textMuted} onChange={(v) => handleColorChange('textMuted', v)} />
                    </div>

                    <div className="space-y-3">
                        <h4 className="text-sm font-semibold text-text-muted border-b border-glass-border pb-1 mb-2">Accents</h4>
                        <ColorInput label="Primary Accent" value={colors.accentPrimary} onChange={(v) => handleColorChange('accentPrimary', v)} />
                        <ColorInput label="Secondary Accent" value={colors.accentSecondary} onChange={(v) => handleColorChange('accentSecondary', v)} />
                        <ColorInput label="Tertiary Accent" value={colors.accentTertiary} onChange={(v) => handleColorChange('accentTertiary', v)} />
                        <ColorInput label="Hover Accent" value={colors.accentHover} onChange={(v) => handleColorChange('accentHover', v)} />
                    </div>

                    <div className="space-y-3">
                        <h4 className="text-sm font-semibold text-text-muted border-b border-glass-border pb-1 mb-2">Status</h4>
                        <ColorInput label="Success" value={colors.statusSuccess} onChange={(v) => handleColorChange('statusSuccess', v)} />
                        <ColorInput label="Warning" value={colors.statusWarning} onChange={(v) => handleColorChange('statusWarning', v)} />
                        <ColorInput label="Error" value={colors.statusError} onChange={(v) => handleColorChange('statusError', v)} />
                        <ColorInput label="Info" value={colors.statusInfo} onChange={(v) => handleColorChange('statusInfo', v)} />
                    </div>

                    <div className="space-y-3">
                        <h4 className="text-sm font-semibold text-text-muted border-b border-glass-border pb-1 mb-2">Misc</h4>
                        <ColorInput label="Glass Border" value={colors.glassBorder} onChange={(v) => handleColorChange('glassBorder', v)} />
                    </div>
                </div>
            </div>

            {/* Footer */}
            <div className="p-4 border-t border-glass-border bg-background-secondary flex justify-end gap-3 shrink-0">
                <Button variant="secondary" onClick={handleClose}>Cancel</Button>
                <Button variant="primary" onClick={handleSave} disabled={!name.trim()}>Save Theme</Button>
            </div>
        </div>
    );
};

const ColorInput = ({ label, value, onChange }: { label: string, value: string, onChange: (val: string) => void }) => {
    return (
        <div className="flex flex-col gap-1">
            <label className="text-xs text-text-secondary">{label}</label>
            <div className="flex items-center gap-2">
                <div
                    className="w-8 h-8 rounded border border-glass-border shrink-0"
                    style={{ backgroundColor: value }}
                />
                <input
                    type="text"
                    value={value}
                    onChange={(e) => onChange(e.target.value)}
                    className="w-full bg-background-tertiary text-text-primary text-xs border border-glass-border rounded px-2 py-2 focus:outline-none focus:border-accent-primary font-mono"
                    placeholder="#000000"
                />
            </div>
        </div>
    )
}

export default ThemeEditorWindow;

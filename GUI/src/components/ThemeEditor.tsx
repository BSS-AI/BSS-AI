import React, { useState, useEffect } from 'react';
import { getCurrentWindow } from '@tauri-apps/api/window';
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

interface ThemeEditorProps {
    onClose: () => void;
    onSave: (theme: Theme) => void;
    existingTheme?: Theme;
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

const ThemeEditor: React.FC<ThemeEditorProps> = ({ onClose, onSave, existingTheme }) => {
    const [name, setName] = useState(existingTheme?.name || '');
    const [colors, setColors] = useState(existingTheme?.colors || defaultColors);
    const [copied, setCopied] = useState(false);

    const handleColorChange = (key: keyof typeof defaultColors, value: string) => {
        setColors(prev => ({ ...prev, [key]: value }));
    };

    const handleSave = () => {
        if (!name.trim()) return;
        const theme: Theme = {
            id: existingTheme?.id || `custom-${Date.now()}`,
            name,
            colors
        };
        onSave(theme);
        onClose();
    };

    const handleExport = () => {
        const themeData = JSON.stringify({ name, colors }, null, 2);
        navigator.clipboard.writeText(themeData);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md p-4 animate-fade-in text-left">
            <div className="bg-[#1a1a1a] border border-white/10 rounded-xl shadow-2xl w-full max-w-4xl h-[80vh] flex flex-col overflow-hidden">
                <div className="p-4 border-b border-white/10 flex justify-between items-center bg-[#151515]">
                    <div>
                        <h2 className="text-lg font-bold text-white">Theme Editor</h2>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="secondary" size="sm" onClick={handleExport}>
                            {copied ? "Copied!" : "Export JSON"}
                        </Button>
                        <button onClick={onClose} className="text-gray-400 hover:text-white transition-colors p-2">
                            ✕
                        </button>
                    </div>
                </div>

                <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
                    <div className="space-y-4">
                        <Input
                            label="Theme Name"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="My Awesome Theme"
                        />
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <div className="space-y-3">
                            <h4 className="text-sm font-semibold text-white/50 border-b border-white/10 pb-1 mb-2">Backgrounds</h4>
                            <ColorInput label="Primary BG" value={colors.bgPrimary} onChange={(v) => handleColorChange('bgPrimary', v)} />
                            <ColorInput label="Secondary BG" value={colors.bgSecondary} onChange={(v) => handleColorChange('bgSecondary', v)} />
                            <ColorInput label="Tertiary BG" value={colors.bgTertiary} onChange={(v) => handleColorChange('bgTertiary', v)} />
                            <ColorInput label="Surface BG" value={colors.bgSurface} onChange={(v) => handleColorChange('bgSurface', v)} />
                        </div>

                        <div className="space-y-3">
                            <h4 className="text-sm font-semibold text-white/50 border-b border-white/10 pb-1 mb-2">Text</h4>
                            <ColorInput label="Primary Text" value={colors.textPrimary} onChange={(v) => handleColorChange('textPrimary', v)} />
                            <ColorInput label="Secondary Text" value={colors.textSecondary} onChange={(v) => handleColorChange('textSecondary', v)} />
                            <ColorInput label="Muted Text" value={colors.textMuted} onChange={(v) => handleColorChange('textMuted', v)} />
                        </div>

                        <div className="space-y-3">
                            <h4 className="text-sm font-semibold text-white/50 border-b border-white/10 pb-1 mb-2">Accents</h4>
                            <ColorInput label="Primary Accent" value={colors.accentPrimary} onChange={(v) => handleColorChange('accentPrimary', v)} />
                            <ColorInput label="Secondary Accent" value={colors.accentSecondary} onChange={(v) => handleColorChange('accentSecondary', v)} />
                            <ColorInput label="Tertiary Accent" value={colors.accentTertiary} onChange={(v) => handleColorChange('accentTertiary', v)} />
                            <ColorInput label="Hover Accent" value={colors.accentHover} onChange={(v) => handleColorChange('accentHover', v)} />
                        </div>

                        <div className="space-y-3">
                            <h4 className="text-sm font-semibold text-white/50 border-b border-white/10 pb-1 mb-2">Status</h4>
                            <ColorInput label="Success" value={colors.statusSuccess} onChange={(v) => handleColorChange('statusSuccess', v)} />
                            <ColorInput label="Warning" value={colors.statusWarning} onChange={(v) => handleColorChange('statusWarning', v)} />
                            <ColorInput label="Error" value={colors.statusError} onChange={(v) => handleColorChange('statusError', v)} />
                            <ColorInput label="Info" value={colors.statusInfo} onChange={(v) => handleColorChange('statusInfo', v)} />
                        </div>

                        <div className="space-y-3">
                            <h4 className="text-sm font-semibold text-white/50 border-b border-white/10 pb-1 mb-2">Misc</h4>
                            <ColorInput label="Glass Border" value={colors.glassBorder} onChange={(v) => handleColorChange('glassBorder', v)} />
                        </div>
                    </div>
                </div>

                <div className="p-4 border-t border-white/10 bg-[#151515] flex justify-end gap-3">
                    <Button variant="secondary" onClick={onClose}>Cancel</Button>
                    <Button variant="primary" onClick={handleSave} disabled={!name.trim()}>Save Theme</Button>
                </div>
            </div>
        </div>
    );
};

const ColorInput = ({ label, value, onChange }: { label: string, value: string, onChange: (val: string) => void }) => {
    return (
        <div className="flex flex-col gap-1">
            <label className="text-xs text-gray-400">{label}</label>
            <div className="flex items-center gap-2">
                <div
                    className="w-8 h-8 rounded border border-white/10 shrink-0"
                    style={{ backgroundColor: value }}
                />
                <input
                    type="text"
                    value={value}
                    onChange={(e) => onChange(e.target.value)}
                    className="w-full bg-[#0a0a0a] text-white text-xs border border-white/10 rounded px-2 py-2 focus:outline-none focus:border-blue-500 font-mono"
                    placeholder="#000000"
                />
            </div>
        </div>
    )
}

export default ThemeEditor;

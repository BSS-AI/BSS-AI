import React from 'react';
import { getCurrentWindow } from '@tauri-apps/api/window';

const TopBar: React.FC = () => {
    const appWindow = getCurrentWindow();

    const minimizeWindow = () => appWindow.minimize();
    const maximizeWindow = () => appWindow.toggleMaximize();
    const closeWindow = () => appWindow.close();

    return (
        <div data-tauri-drag-region className="h-10 bg-background-secondary/50 backdrop-blur-md border-b border-white/5 flex items-center justify-end px-4 select-none z-50">
            {/* Window Controls */}
            <div className="flex items-center gap-1">
                <button
                    onClick={minimizeWindow}
                    className="w-8 h-8 flex items-center justify-center text-text-secondary hover:bg-white/5 hover:text-white rounded-md transition-colors"
                >
                    <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
                    </svg>
                </button>
                <button
                    onClick={maximizeWindow}
                    className="w-8 h-8 flex items-center justify-center text-text-secondary hover:bg-white/5 hover:text-white rounded-md transition-colors"
                >
                    <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h18v18H3V3z" />
                    </svg>
                </button>
                <button
                    onClick={closeWindow}
                    className="w-8 h-8 flex items-center justify-center text-text-secondary hover:bg-status-error hover:text-white rounded-md transition-colors"
                >
                    <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>
    );
};

export default TopBar;

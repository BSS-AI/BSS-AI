import React from 'react';
import { getCurrentWindow } from '@tauri-apps/api/window';

interface NavBarProps {
    activeTab: string;
    setActiveTab: (tab: string) => void;
    theme: string;
}

const NavBar: React.FC<NavBarProps> = ({ activeTab, setActiveTab, theme }) => {
    const appWindow = getCurrentWindow();

    const minimizeWindow = () => appWindow.minimize();
    const closeWindow = () => appWindow.close();

    const menuItems = [
        { id: 'gather', label: 'Gather', icon: 'gather' },
        { id: 'collect', label: 'Collect', icon: 'collect' },
        { id: 'kill', label: 'Kill', icon: 'kill' },
        { id: 'planter', label: 'Planter', icon: 'planter' },
        { id: 'quest', label: 'Quest', icon: 'quest' },
        { id: 'vichop', label: 'Vichop', icon: 'vichop' },
        { id: 'boost', label: 'Boost', icon: 'boost' },
        { id: 'settings', label: 'Settings', icon: 'setting' },
    ];

    // Use light icons for light themes (light and sakuramochi), dark icons for all other themes
    const iconVariant = (theme === 'light' || theme === 'sakuramochi') ? 'light' : 'dark';

    return (
        <div data-tauri-drag-region className={`h-14 bg-background-secondary flex items-center justify-between px-4 flex-shrink-0 z-20 select-none ${theme === 'light' ? 'border-b border-black/10' : 'border-b border-white/5'}`}>
            {/* Navigation Tabs */}
            <div className="flex items-center justify-center gap-1 h-full max-w-5xl flex-1">
                {menuItems.map((item) => (
                    <button
                        key={item.id}
                        onClick={() => setActiveTab(item.id)}
                        className={`
                            relative h-10 px-3 rounded-lg flex items-center gap-2 transition-all duration-200 flex-1
                            ${activeTab === item.id
                                ? 'bg-white/10 text-text-primary shadow-lg shadow-black/10'
                                : 'text-text-secondary hover:bg-white/5 hover:text-text-primary'
                            }
                        `}
                    >
                        <img
                            src={`/assets/${item.icon}_${iconVariant}.webp`}
                            alt={item.label}
                            className={`w-4 h-4 object-contain transition-transform duration-200 ${activeTab === item.id ? 'scale-110' : ''}`}
                        />
                        <span className="text-sm font-medium whitespace-nowrap">{item.label}</span>

                        {activeTab === item.id && (
                            <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-1/2 h-0.5 bg-accent-primary rounded-full shadow-[0_0_8px_rgba(59,130,246,0.8)]" />
                        )}
                    </button>
                ))}
            </div>

            {/* Window Controls */}
            <div className={`flex items-center gap-1 ml-4 pl-4 ${theme === 'light' ? 'border-l border-black/10' : 'border-l border-white/10'}`}>
                <button
                    onClick={minimizeWindow}
                    className={`w-8 h-8 flex items-center justify-center text-text-secondary rounded-md transition-colors ${theme === 'light' ? 'hover:bg-black/5 hover:text-black' : 'hover:bg-white/5 hover:text-white'}`}
                >
                    <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
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

export default NavBar;

import React, { useState } from 'react';

interface SidebarProps {
    activeTab: string;
    setActiveTab: (tab: string) => void;
    macroStatus: string;
    onStartMacro: () => void;
    onStopMacro: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ activeTab, setActiveTab, macroStatus, onStartMacro, onStopMacro }) => {
    const [isCollapsed, setIsCollapsed] = useState(false);

    const menuItems = [
        { id: 'home', label: 'Home', icon: 'home' },
        { id: 'gather', label: 'Gather', icon: 'gather' },
        { id: 'collect', label: 'Collect', icon: 'collect' },
        { id: 'kill', label: 'Kill', icon: 'kill' },
        { id: 'planter', label: 'Planter', icon: 'planter' },
        { id: 'quest', label: 'Quest', icon: 'quest' },
        { id: 'boost', label: 'Boost', icon: 'boost' },
        { id: 'settings', label: 'Settings', icon: 'setting' },
    ];

    return (
        <aside
            className={`
        relative h-full bg-background-secondary/80 backdrop-blur-xl border-r border-white/5 
        transition-all duration-300 ease-in-out flex flex-col
        ${isCollapsed ? 'w-20' : 'w-64'}
      `}
        >
            {/* Logo Area */}
            <div className="h-16 flex items-center px-6 border-b border-white/5">
                <img src="/assets/bssAiLogo.png" alt="Logo" className="w-8 h-8" />
                <span className={`ml-3 font-bold text-xl bg-clip-text text-transparent bg-gradient-to-r from-accent-primary to-accent-secondary whitespace-nowrap overflow-hidden transition-all duration-300 ${isCollapsed ? 'opacity-0 w-0' : 'opacity-100 w-auto'}`}>
                    BSS AI
                </span>
            </div>

            {/* Navigation */}
            <nav className="flex-1 py-6 px-3 space-y-1 overflow-y-auto custom-scrollbar">
                {menuItems.map((item) => (
                    <button
                        key={item.id}
                        onClick={() => setActiveTab(item.id)}
                        className={`
              w-full flex items-center px-3 py-3 rounded-lg transition-all duration-200 group
              ${activeTab === item.id
                                ? 'bg-accent-primary/10 text-accent-primary shadow-[0_0_20px_rgba(59,130,246,0.15)]'
                                : 'text-text-secondary hover:bg-white/5 hover:text-white'}
            `}
                    >
                        <div className="relative w-6 h-6 flex-shrink-0">
                            {/* Icon Placeholder - Using existing assets as requested */}
                            <img
                                src={`/assets/${item.icon}_dark.png`}
                                alt={item.label}
                                className={`w-full h-full object-contain transition-transform duration-200 ${activeTab === item.id ? 'scale-110' : 'group-hover:scale-110'}`}
                            />
                        </div>
                        <span className={`ml-3 font-medium whitespace-nowrap overflow-hidden transition-all duration-300 ${isCollapsed ? 'opacity-0 w-0' : 'opacity-100 w-auto'}`}>
                            {item.label}
                        </span>

                        {/* Active Indicator */}
                        {activeTab === item.id && (
                            <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-accent-primary rounded-r-full shadow-[0_0_10px_rgba(59,130,246,0.5)]" />
                        )}
                    </button>
                ))}
            </nav>

            {/* Macro Controls */}
            <div className="p-4 border-t border-white/5 bg-black/20">
                <div className={`flex flex-col gap-3 transition-all duration-300 ${isCollapsed ? 'items-center' : ''}`}>

                    {/* Status Display */}
                    {!isCollapsed && (
                        <div className="flex items-center justify-between mb-2 px-1">
                            <span className="text-xs font-medium text-text-muted uppercase tracking-wider">Status</span>
                            <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${macroStatus === 'started' ? 'bg-status-success/20 text-status-success' : 'bg-status-error/20 text-status-error'
                                }`}>
                                {macroStatus.toUpperCase()}
                            </span>
                        </div>
                    )}

                    {/* Start Button */}
                    <button
                        onClick={onStartMacro}
                        disabled={macroStatus === 'started'}
                        className={`
              relative group overflow-hidden rounded-lg bg-gradient-to-r from-status-success to-emerald-600 
              text-white font-semibold shadow-lg shadow-emerald-900/20 transition-all duration-300
              disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-emerald-500/20 hover:scale-[1.02] active:scale-[0.98]
              ${isCollapsed ? 'w-10 h-10 p-0 flex items-center justify-center' : 'w-full py-2.5'}
            `}
                        title="Start Macro (F1)"
                    >
                        {isCollapsed ? (
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                            </svg>
                        ) : (
                            <span className="flex items-center justify-center gap-2">
                                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                </svg>
                                Start
                            </span>
                        )}
                    </button>

                    {/* Stop Button */}
                    <button
                        onClick={onStopMacro}
                        disabled={macroStatus !== 'started'}
                        className={`
              relative group overflow-hidden rounded-lg bg-gradient-to-r from-status-error to-rose-600 
              text-white font-semibold shadow-lg shadow-rose-900/20 transition-all duration-300
              disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-rose-500/20 hover:scale-[1.02] active:scale-[0.98]
              ${isCollapsed ? 'w-10 h-10 p-0 flex items-center justify-center' : 'w-full py-2.5'}
            `}
                        title="Stop Macro (F3)"
                    >
                        {isCollapsed ? (
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                            </svg>
                        ) : (
                            <span className="flex items-center justify-center gap-2">
                                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                                </svg>
                                Stop
                            </span>
                        )}
                    </button>
                </div>
            </div>

            {/* Collapse Toggle */}
            <button
                onClick={() => setIsCollapsed(!isCollapsed)}
                className="absolute -right-3 top-1/2 -translate-y-1/2 w-6 h-6 bg-background-tertiary border border-white/10 rounded-full flex items-center justify-center text-text-secondary hover:text-white hover:bg-accent-primary hover:border-accent-primary transition-all duration-200 shadow-lg z-10"
            >
                <svg
                    className={`w-3 h-3 transition-transform duration-300 ${isCollapsed ? 'rotate-180' : ''}`}
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
            </button>
        </aside>
    );
};

export default Sidebar;

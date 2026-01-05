import React from 'react';
import NavBar from './NavBar';
import BottomBar from './BottomBar';

interface MainLayoutProps {
    children: React.ReactNode;
    activeTab: string;
    setActiveTab: (tab: string) => void;
    macroStatus: string;
    onStartMacro: () => void;
    onStopMacro: () => void;
    theme: string;
}

const MainLayout: React.FC<MainLayoutProps> = ({
    children,
    activeTab,
    setActiveTab,
    macroStatus,
    onStartMacro,
    onStopMacro,
    theme,
}) => {
    return (
        <div className="flex flex-col h-screen w-full bg-background text-text-primary overflow-hidden font-sans">
            {/* Background Ambience */}
            <div className="fixed inset-0 z-0 pointer-events-none">
                <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[50%] rounded-full bg-accent-primary/5 blur-[120px]" />
                <div className="absolute bottom-[-20%] right-[-10%] w-[50%] h-[50%] rounded-full bg-accent-secondary/5 blur-[120px]" />
            </div>

            {/* Navigation Bar (with window controls) */}
            <NavBar activeTab={activeTab} setActiveTab={setActiveTab} theme={theme} />

            {/* Main Content Area */}
            <main className="flex-1 min-h-0 relative z-10 overflow-hidden">
                {children}
            </main>

            {/* Bottom Bar (Macro Controls) */}
            <BottomBar
                macroStatus={macroStatus}
                onStartMacro={onStartMacro}
                onStopMacro={onStopMacro}
            />
        </div>
    );
};

export default MainLayout;

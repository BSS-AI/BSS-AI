import React, { useState, useEffect } from 'react';

interface SidebarItem {
    id: string;
    label: string;
    icon?: React.ReactNode;
    content: React.ReactNode;
}

interface TabSidebarLayoutProps {
    items: SidebarItem[];
    defaultActiveId?: string;
    sidebarHeader?: React.ReactNode;
}

const TabSidebarLayout: React.FC<TabSidebarLayoutProps> = ({ items, defaultActiveId, sidebarHeader }) => {
    const [activeId, setActiveId] = useState(defaultActiveId || items[0]?.id);

    // Sync activeId when items change (e.g. switching modes in PlanterTab)
    useEffect(() => {
        if (!items.find(item => item.id === activeId)) {
            setActiveId(items[0]?.id);
        }
    }, [items, activeId]);

    const activeItem = items.find(item => item.id === activeId) || items[0];

    return (
        <div className="flex h-full w-full overflow-hidden">
            {/* Inner Sidebar */}
            <div className="w-48 md:w-56 bg-background-secondary/50 border-r border-glass-border flex-shrink-0 overflow-y-auto custom-scrollbar p-3 flex flex-col gap-1">
                {sidebarHeader && (
                    <div className="mb-2 pb-2 border-b border-glass-border">
                        {sidebarHeader}
                    </div>
                )}
                {items.map((item) => (
                    <button
                        key={item.id}
                        onClick={() => setActiveId(item.id)}
                        className={`
                            w-full text-left px-4 py-3 rounded-lg text-sm font-medium transition-all duration-200
                            flex items-center gap-3
                            ${activeId === item.id
                                ? 'bg-accent-primary text-white shadow-lg shadow-accent-primary/20'
                                : 'text-text-secondary hover:bg-background-tertiary hover:text-text-primary'
                            }
                        `}
                    >
                        {item.icon}
                        <span>{item.label}</span>
                    </button>
                ))}
            </div>

            {/* Content Area */}
            <div className="flex-1 overflow-y-auto custom-scrollbar p-6 bg-background/50 relative">
                <div className="max-w-4xl mx-auto animate-fade-in">
                    {activeItem?.content}
                </div>
            </div>
        </div>
    );
};

export default TabSidebarLayout;

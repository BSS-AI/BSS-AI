import React from 'react';

interface CardProps {
    children: React.ReactNode;
    className?: string;
    title?: string;
    action?: React.ReactNode;
    bodyClassName?: string;
}

const Card: React.FC<CardProps> = ({ children, className = '', title, action, bodyClassName = '' }) => {
    return (
        <div className={`glass-card rounded-xl overflow-hidden ${className}`}>
            {(title || action) && (
                <div className="px-6 py-4 border-b border-glass-border flex items-center justify-between bg-background-tertiary/50">
                    {title && <h3 className="text-lg font-semibold text-text-primary tracking-tight">{title}</h3>}
                    {action && <div>{action}</div>}
                </div>
            )}
            <div className={`p-6 ${bodyClassName}`}>
                {children}
            </div>
        </div>
    );
};

export default Card;

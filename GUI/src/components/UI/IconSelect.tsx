import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';

interface IconSelectProps {
    label?: string;
    value: string;
    onChange: (value: string) => void;
    options: string[];
    getIcon: (value: string) => string | null;
    className?: string;
    disabled?: boolean;
}

const IconSelect: React.FC<IconSelectProps> = ({ label, value, onChange, options, getIcon, className = '', disabled = false }) => {
    const [isOpen, setIsOpen] = useState(false);
    const [coords, setCoords] = useState({ top: 0, left: 0, width: 0, height: 0 });
    const [placement, setPlacement] = useState<'bottom' | 'top'>('bottom');
    const containerRef = useRef<HTMLDivElement>(null);
    const dropdownRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (
                containerRef.current &&
                !containerRef.current.contains(event.target as Node) &&
                dropdownRef.current &&
                !dropdownRef.current.contains(event.target as Node)
            ) {
                setIsOpen(false);
            }
        };

        const handleScroll = (event: Event) => {
            if (dropdownRef.current && dropdownRef.current.contains(event.target as Node)) {
                return;
            }
            if (isOpen) setIsOpen(false);
        };

        document.addEventListener('mousedown', handleClickOutside);
        window.addEventListener('scroll', handleScroll, true);
        window.addEventListener('resize', handleScroll);

        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
            window.removeEventListener('scroll', handleScroll, true);
            window.removeEventListener('resize', handleScroll);
        };
    }, [isOpen]);

    const toggleOpen = () => {
        if (!isOpen && !disabled && containerRef.current) {
            const rect = containerRef.current.getBoundingClientRect();
            const spaceBelow = window.innerHeight - rect.bottom;
            const spaceAbove = rect.top;

            // Prefer bottom, but flip to top if space below is tight (< 250px) and space above is better
            const newPlacement = (spaceBelow < 250 && spaceAbove > spaceBelow) ? 'top' : 'bottom';

            setCoords({
                top: rect.top,
                left: rect.left,
                width: rect.width,
                height: rect.height
            });
            setPlacement(newPlacement);
            setIsOpen(true);
        } else {
            setIsOpen(false);
        }
    };

    const handleSelect = (option: string) => {
        onChange(option);
        setIsOpen(false);
    };

    return (
        <div className={`relative ${className}`} ref={containerRef}>
            {label && <label className="block text-xs font-medium text-text-secondary mb-1.5 uppercase tracking-wider">{label}</label>}

            <button
                type="button"
                onClick={toggleOpen}
                disabled={disabled}
                className={`
                  w-full flex items-center justify-between bg-background-tertiary border border-white/10 text-text-primary 
                  rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:border-accent-primary/50 focus:ring-1 focus:ring-accent-primary/50
                  disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200
                  ${isOpen ? 'border-accent-primary/50 ring-1 ring-accent-primary/50' : ''}
                `}
            >
                <div className="flex items-center gap-3">
                    {getIcon(value) && (
                        getIcon(value)!.includes(',') ? (
                            <div className="flex gap-1">
                                {getIcon(value)!.split(',').map((icon, idx) => (
                                    <img key={idx} src={icon} alt="" className="w-5 h-5 object-contain" />
                                ))}
                            </div>
                        ) : (
                            <img src={getIcon(value)!} alt="" className="w-5 h-5 object-contain" />
                        )
                    )}
                    <span className="truncate">{value}</span>
                </div>
                <svg className={`h-4 w-4 text-text-secondary transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                </svg>
            </button>

            {isOpen && createPortal(
                <div
                    ref={dropdownRef}
                    style={{
                        position: 'fixed',
                        top: placement === 'bottom' ? coords.top + coords.height + 4 : 'auto',
                        bottom: placement === 'top' ? window.innerHeight - coords.top + 4 : 'auto',
                        left: coords.left,
                        width: coords.width,
                        zIndex: 9999,
                    }}
                    className="bg-background-tertiary border border-white/10 rounded-lg shadow-xl max-h-60 overflow-y-auto custom-scrollbar animate-fade-in"
                >
                    {options.map((option) => (
                        <button
                            key={option}
                            type="button"
                            onClick={() => handleSelect(option)}
                            className={`
                              w-full flex items-center gap-3 px-3 py-2.5 text-sm text-left transition-colors
                              ${option === value ? 'bg-accent-primary/20 text-white' : 'text-text-secondary hover:bg-white/5 hover:text-white'}
                            `}
                        >
                            {getIcon(option) && (
                                getIcon(option)!.includes(',') ? (
                                    <div className="flex gap-1">
                                        {getIcon(option)!.split(',').map((icon, idx) => (
                                            <img key={idx} src={icon} alt="" className="w-5 h-5 object-contain" />
                                        ))}
                                    </div>
                                ) : (
                                    <img src={getIcon(option)!} alt="" className="w-5 h-5 object-contain" />
                                )
                            )}
                            <span className="truncate">{option}</span>
                        </button>
                    ))}
                </div>,
                document.body
            )}
        </div>
    );
};

export default IconSelect;

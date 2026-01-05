import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';

interface FieldSelectProps {
    label?: string;
    value: string;
    onChange: (value: string) => void;
    options: string[];
    className?: string;
    disabled?: boolean;
}

const fieldIcons: { [key: string]: string } = {
    "Sunflower": "Hivesticker_sunflower_field_stamp.webp",
    "Dandelion": "Hivesticker_dandelion_field_stamp.webp",
    "Mushroom": "Hivesticker_mushroom_field_stamp.webp",
    "Blue Flower": "Hivesticker_blue_flower_field_stamp.webp",
    "Clover": "Hivesticker_clover_field_stamp.webp",
    "Strawberry": "Hivesticker_strawberry_field_stamp.webp",
    "Spider": "Hivesticker_spider_field_stamp.webp",
    "Bamboo": "Hivesticker_bamboo_field_stamp.webp",
    "Pineapple": "Hivesticker_pineapple_patch_stamp.webp",
    "Stump": "Hivesticker_stump_field_stamp.webp",
    "Cactus": "Hivesticker_cactus_field_stamp.webp",
    "Pumpkin": "Hivesticker_pumpkin_patch_stamp.webp",
    "Pine Tree": "Hivesticker_pine_tree_forest_stamp.webp",
    "Rose": "Hivesticker_rose_field_stamp.webp",
    "Mountain Top": "Hivesticker_mountain_top_field_stamp.webp",
    "Pepper": "Hivesticker_pepper_patch_stamp.webp",
    "Coconut": "Hivesticker_coconut_field_stamp.webp",
    "Ant": "Hivesticker_ant_field_stamp.webp",
    "Hub": "Hivesticker_hub_field_stamp.webp"
};

export const getFieldIcon = (field: string) => {
    return fieldIcons[field] ? `/assets/${fieldIcons[field]}` : null;
};

const FieldSelect: React.FC<FieldSelectProps> = ({ label, value, onChange, options, className = '', disabled = false }) => {
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
                    {getFieldIcon(value) && (
                        <img src={getFieldIcon(value)!} alt="" className="w-5 h-5 object-contain" />
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
                            {getFieldIcon(option) && (
                                <img src={getFieldIcon(option)!} alt="" className="w-5 h-5 object-contain" />
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

export default FieldSelect;

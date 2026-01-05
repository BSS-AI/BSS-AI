import React from 'react';

interface SwitchProps {
    checked: boolean;
    onChange: (checked: boolean) => void;
    label?: string;
    className?: string;
    disabled?: boolean;
}

const Switch: React.FC<SwitchProps> = ({ checked, onChange, label, className = '', disabled = false }) => {
    return (
        <label className={`inline-flex items-center ${disabled ? 'cursor-not-allowed opacity-50' : 'cursor-pointer'} ${className}`}>
            <div className="relative">
                <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={checked}
                    onChange={(e) => !disabled && onChange(e.target.checked)}
                    disabled={disabled}
                />
                <div className={`
          w-11 h-6 rounded-full peer 
          bg-background-tertiary border border-white/10 peer-focus:ring-2 peer-focus:ring-accent-primary/50
          peer-checked:after:translate-x-full peer-checked:after:border-white 
          after:content-[''] after:absolute after:top-[2px] after:left-[2px] 
          after:bg-white after:border-gray-300 after:border after:rounded-full 
          after:h-5 after:w-5 after:transition-all 
          peer-checked:bg-accent-primary
        `}></div>
            </div>
            {label && <span className="ml-3 text-sm font-medium text-text-primary">{label}</span>}
        </label>
    );
};

export default Switch;

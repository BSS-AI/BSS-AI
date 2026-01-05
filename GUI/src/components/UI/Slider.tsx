import React from 'react';

interface SliderProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    value: number;
    min?: number;
    max?: number;
    step?: number;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
    formatValue?: (value: number) => string;
}

const Slider: React.FC<SliderProps> = ({
    label,
    value,
    min = 0,
    max = 100,
    step = 1,
    onChange,
    className = '',
    formatValue = (v) => `${v}%`,
    ...props
}) => {
    return (
        <div className={className}>
            {label && (
                <div className="flex justify-between mb-2">
                    <label className="block text-xs font-medium text-text-secondary uppercase tracking-wider">{label}</label>
                    <span className="text-xs text-text-primary font-mono">{formatValue(value)}</span>
                </div>
            )}
            <div className="relative flex items-center h-5">
                <input
                    type="range"
                    min={min}
                    max={max}
                    step={step}
                    value={value}
                    onChange={onChange}
                    className="
                        w-full h-1.5 bg-background-tertiary rounded-lg appearance-none cursor-pointer
                        [&::-webkit-slider-thumb]:appearance-none
                        [&::-webkit-slider-thumb]:w-4
                        [&::-webkit-slider-thumb]:h-4
                        [&::-webkit-slider-thumb]:rounded-full
                        [&::-webkit-slider-thumb]:bg-accent-primary
                        [&::-webkit-slider-thumb]:hover:bg-accent-hover
                        [&::-webkit-slider-thumb]:transition-colors
                        [&::-webkit-slider-thumb]:shadow-lg
                    "
                    {...props}
                />
            </div>
        </div>
    );
};

export default Slider;

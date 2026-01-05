import React from 'react';

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
    label?: React.ReactNode;
    options: { value: string; label: string }[] | string[];
}

const Select: React.FC<SelectProps> = ({ label, options, className = '', ...props }) => {
    return (
        <div className={className}>
            {label && <label className="block text-xs font-medium text-text-secondary mb-1.5 uppercase tracking-wider">{label}</label>}
            <div className="relative">
                <select
                    className={`
            w-full appearance-none bg-background-tertiary border border-white/10 text-text-primary 
            rounded-lg px-3 py-2.5 pr-8 text-sm focus:outline-none focus:border-accent-primary/50 focus:ring-1 focus:ring-accent-primary/50
            disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200
          `}
                    {...props}
                >
                    {options.map((opt) => {
                        const value = typeof opt === 'string' ? opt : opt.value;
                        const label = typeof opt === 'string' ? opt : opt.label;
                        return (
                            <option key={value} value={value} className="bg-background-secondary text-text-primary">
                                {label}
                            </option>
                        );
                    })}
                </select>
                <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-text-secondary">
                    <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                    </svg>
                </div>
            </div>
        </div>
    );
};

export default Select;

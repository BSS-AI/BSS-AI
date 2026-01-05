import React from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label?: React.ReactNode;
    error?: string;
}

const Input: React.FC<InputProps> = ({ label, error, className = '', ...props }) => {
    return (
        <div className={className}>
            {label && <label className="block text-xs font-medium text-text-secondary mb-1.5 uppercase tracking-wider">{label}</label>}
            <input
                className={`
          w-full bg-background-tertiary border border-white/10 text-text-primary 
          rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:border-accent-primary/50 focus:ring-1 focus:ring-accent-primary/50
          disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200
          placeholder-text-muted/50
          ${error ? 'border-status-error focus:border-status-error focus:ring-status-error' : ''}
        `}
                {...props}
            />
            {error && <p className="mt-1 text-xs text-status-error">{error}</p>}
        </div>
    );
};

export default Input;

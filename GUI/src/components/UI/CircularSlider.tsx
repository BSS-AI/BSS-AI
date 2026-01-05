import React, { useState, useEffect, useCallback, useRef } from 'react';

interface CircularSliderProps {
    label?: string;
    value: number;
    min?: number;
    max?: number;
    size?: number;
    strokeWidth?: number;
    onChange: (value: number) => void;
    onInteractionEnd?: (value: number) => void;
    disabled?: boolean;
    suffix?: string;
}

const CircularSlider: React.FC<CircularSliderProps> = ({
    label,
    value,
    min = 0,
    max = 100,
    size = 120,
    strokeWidth = 10,
    onChange,
    onInteractionEnd,
    disabled = false,
    suffix = '%'
}) => {
    const [isDragging, setIsDragging] = useState(false);
    const sliderRef = useRef<HTMLDivElement>(null);
    const center = size / 2;
    const radius = (size - strokeWidth) / 2;
    const circumference = 2 * Math.PI * radius;

    // Convert value to degrees (0-360)
    // Value 0 is at top (Start), so we subtract 90 degrees from standard circle
    const percentage = Math.min(Math.max((value - min) / (max - min), 0), 1);
    const offset = circumference - (percentage * circumference);

    const handleInteraction = useCallback((clientX: number, clientY: number) => {
        if (disabled || !sliderRef.current) return;

        const rect = sliderRef.current.getBoundingClientRect();
        const x = clientX - rect.left - center;
        const y = clientY - rect.top - center;

        let angle = Math.atan2(y, x);
        angle = angle + Math.PI / 2;
        if (angle < 0) angle += 2 * Math.PI;

        const percent = angle / (2 * Math.PI);
        const newValue = Math.round(min + percent * (max - min));

        onChange(Math.min(Math.max(newValue, min), max));
    }, [center, min, max, onChange, disabled]);

    const handleMouseDown = useCallback((e: React.MouseEvent) => {
        if (disabled) return;
        setIsDragging(true);
        handleInteraction(e.clientX, e.clientY);
    }, [disabled, handleInteraction]);

    const handleTouchStart = useCallback((e: React.TouchEvent) => {
        if (disabled) return;
        setIsDragging(true);
        handleInteraction(e.touches[0].clientX, e.touches[0].clientY);
    }, [disabled, handleInteraction]);

    const handleMouseUp = useCallback(() => {
        setIsDragging(false);
        if (onInteractionEnd) onInteractionEnd(value);
    }, [onInteractionEnd, value]);

    const handleTouchEnd = useCallback(() => {
        setIsDragging(false);
        if (onInteractionEnd) onInteractionEnd(value);
    }, [onInteractionEnd, value]);

    const handleMouseMove = useCallback((e: MouseEvent) => {
        if (isDragging) {
            e.preventDefault();
            handleInteraction(e.clientX, e.clientY);
        }
    }, [isDragging, handleInteraction]);

    const handleTouchMove = useCallback((e: TouchEvent) => {
        if (isDragging) {
            e.preventDefault();
            handleInteraction(e.touches[0].clientX, e.touches[0].clientY);
        }
    }, [isDragging, handleInteraction]);

    useEffect(() => {
        if (isDragging) {
            window.addEventListener('mouseup', handleMouseUp);
            window.addEventListener('mousemove', handleMouseMove);
            window.addEventListener('touchend', handleTouchEnd);
            window.addEventListener('touchmove', handleTouchMove, { passive: false });
        } else {
            window.removeEventListener('mouseup', handleMouseUp);
            window.removeEventListener('mousemove', handleMouseMove);
            window.removeEventListener('touchend', handleTouchEnd);
            window.removeEventListener('touchmove', handleTouchMove);
        }
        return () => {
            window.removeEventListener('mouseup', handleMouseUp);
            window.removeEventListener('mousemove', handleMouseMove);
            window.removeEventListener('touchend', handleTouchEnd);
            window.removeEventListener('touchmove', handleTouchMove);
        };
    }, [isDragging, handleMouseUp, handleMouseMove, handleTouchEnd, handleTouchMove]);

    return (
        <div className={`flex flex-col items-center select-none ${disabled ? 'opacity-50 grayscale' : ''}`}>
            {label && (
                <div className="mb-3 text-xs font-medium text-text-secondary uppercase tracking-wider">
                    {label}
                </div>
            )}
            <div
                ref={sliderRef}
                className="relative cursor-pointer touch-none"
                style={{ width: size, height: size }}
                onMouseDown={handleMouseDown}
                onTouchStart={handleTouchStart}
            >
                <svg width={size} height={size} className="transform -rotate-90 pointer-events-none">
                    {/* Background Track */}
                    <circle
                        cx={center}
                        cy={center}
                        r={radius}
                        fill="none"
                        stroke="currentColor"
                        strokeWidth={strokeWidth}
                        className="text-background-tertiary"
                    />
                    {/* Progress Track */}
                    <circle
                        cx={center}
                        cy={center}
                        r={radius}
                        fill="none"
                        stroke="currentColor"
                        strokeWidth={strokeWidth}
                        strokeDasharray={circumference}
                        strokeDashoffset={offset}
                        strokeLinecap="round"
                        className="text-accent-primary transition-all duration-75"
                    />
                </svg>
                {/* Center Text */}
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <span className="text-xl font-bold text-text-primary">
                        {value}{suffix}
                    </span>
                </div>
            </div>
        </div>
    );
};

export default CircularSlider;

import React, { useState, useEffect, useRef } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import Input from './UI/Input';
import Slider from './UI/Slider';
import CircularSlider from './UI/CircularSlider';
import TabSidebarLayout from './layout/TabSidebarLayout';

const Tooltip = ({ text, children }: { text: string, children: React.ReactNode }) => {
    const [show, setShow] = useState(false);
    const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

    const showTooltip = () => {
        if (timeoutRef.current) clearTimeout(timeoutRef.current);
        setShow(true);
    };

    const hideTooltip = () => {
        timeoutRef.current = setTimeout(() => {
            setShow(false);
        }, 100);
    };

    useEffect(() => {
        return () => {
            if (timeoutRef.current) clearTimeout(timeoutRef.current);
        };
    }, []);

    return (
        <span
            className="relative inline-flex items-center justify-center ml-1"
            onMouseEnter={showTooltip}
            onMouseLeave={hideTooltip}
        >
            {children}
            {show && (
                <div className="absolute left-full top-1/2 z-50 ml-2 -translate-y-1/2 w-72 p-3 text-sm font-normal text-white bg-gray-900/95 border border-white/10 rounded-lg shadow-xl backdrop-blur-md animate-fade-in pointer-events-none">
                    {text}
                    <div className="absolute right-full top-1/2 -translate-y-1/2 border-4 border-solid border-y-transparent border-r-gray-900/95 border-l-transparent" />
                </div>
            )}
        </span>
    );
};

const accountTypeOptions = ["main", "alt"];

function VichopTab() {
    const { settings, updateSetting, loading, error, readSettings } = useSettings();

    // Local state for smooth slider experience
    const [localPercent, setLocalPercent] = React.useState<number | null>(null);
    const [localSessionDuration, setLocalSessionDuration] = React.useState<number | null>(null);

    // Auto-update stats every 1 second
    useEffect(() => {
        const interval = setInterval(() => {
            readSettings();
        }, 1000);
        return () => clearInterval(interval);
    }, [readSettings]);

    // Only show full loading spinner on initial load (when settings are empty)
    // This prevents the tab from unmounting/resetting during auto-updates
    if (loading && Object.keys(settings).length === 0) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
    if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

    const handleSwitchChange = (section: string, key: string) => (checked: boolean) => {
        updateSetting(section, key, boolToIni(checked));
    };

    const handleInputChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLInputElement>) => {
        updateSetting(section, key, e.target.value);
    };

    const handleSelectChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
        updateSetting(section, key, e.target.value);
    };

    const getParsedSetting = (section: string, key: string, defaultValue: any) => {
        return parseIniValue(getSetting(settings, section, key, defaultValue));
    };

    const accountType = getSetting(settings, 'Vichop', 'vichopaccounttype', 'main');
    const isMainAccount = accountType === 'main';

    // Get stats from settings
    const alltimeVicsKilled = getSetting(settings, 'Vichop', 'alltime_vics_killed', '0');
    const alltimeVicsSpotted = getSetting(settings, 'Vichop', 'alltime_vics_spotted', '0');
    const alltimeNightsDetected = getSetting(settings, 'Vichop', 'alltime_nights_detected', '0');
    const alltimeServersJoined = getSetting(settings, 'Vichop', 'alltime_servers_joined', '0');

    const sessionVicsKilled = getSetting(settings, 'Vichop', 'session_vics_killed', '0');
    const sessionVicsSpotted = getSetting(settings, 'Vichop', 'session_vics_spotted', '0');
    const sessionNightsDetected = getSetting(settings, 'Vichop', 'session_nights_detected', '0');
    const sessionServersJoined = getSetting(settings, 'Vichop', 'session_servers_joined', '0');

    const GeneralContent = (
        <div className="space-y-4">
            <Card title="Core Settings" className="w-full">
                <div className="space-y-3">
                    {/* Enable Toggle */}
                    <div className="flex items-center justify-between p-3 rounded-lg bg-background-secondary border border-glass-border">
                        <span className="text-sm font-semibold text-text-primary">Enable Vichop</span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'vichop_enabled', true)}
                            onChange={handleSwitchChange('Vichop', 'vichop_enabled')}
                        />
                    </div>

                    {/* Account Type */}
                    <div className="p-3 rounded-lg bg-background-secondary border border-glass-border">
                        <div className="mb-2">
                            <Select
                                label="Role"
                                options={accountTypeOptions}
                                value={accountType}
                                onChange={handleSelectChange('Vichop', 'vichopaccounttype')}
                            />
                        </div>
                    </div>
                </div>
            </Card>

            <Card title="Configuration" className="w-full">
                <div className="grid grid-cols-1 gap-2">
                    {/* Speed Hop */}
                    <div className="flex items-center justify-between p-2 rounded bg-background-secondary/50 hover:bg-background-secondary transition-colors">
                        <span className="text-xs font-medium text-text-secondary flex items-center gap-1">
                            Speed Hop
                            <Tooltip text="Don't close Roblox between hops. Faster but less stable.">
                                <span className="text-accent-primary cursor-help text-[10px]">(?)</span>
                            </Tooltip>
                        </span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'speedhop', false)}
                            onChange={handleSwitchChange('Vichop', 'speedhop')}
                        />
                    </div>

                    {/* Server Fetching */}
                    <div className="flex items-center justify-between p-2 rounded bg-background-secondary/50 hover:bg-background-secondary transition-colors">
                        <span className="text-xs font-medium text-text-secondary flex items-center gap-1">
                            Use API Fetching
                            <Tooltip text="Fallback to 3rd party API to avoid Roblox rate limits.">
                                <span className="text-accent-primary cursor-help text-[10px]">(?)</span>
                            </Tooltip>
                        </span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'useserverfetching', false)}
                            onChange={handleSwitchChange('Vichop', 'useserverfetching')}
                        />
                    </div>

                    {/* Spider Field */}
                    <div className="flex items-center justify-between p-2 rounded bg-background-secondary/50 hover:bg-background-secondary transition-colors">
                        <span className="text-xs font-medium text-text-secondary flex items-center gap-1">
                            Include Spider
                            <Tooltip text="Check Spider field during rotation.">
                                <span className="text-accent-primary cursor-help text-[10px]">(?)</span>
                            </Tooltip>
                        </span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'spiderenabled', false)}
                            onChange={handleSwitchChange('Vichop', 'spiderenabled')}
                        />
                    </div>

                    {/* 3rd Party Join */}
                    <div className="flex items-center justify-between p-2 rounded bg-background-secondary/50 hover:bg-background-secondary transition-colors">
                        <span className="text-xs font-medium text-text-secondary flex items-center gap-1">
                            3rd Party Join
                            <Tooltip text="Enable if it keeps joining servers with friends during vichop. Uses a different join method that takes ~0.5s longer per server.">
                                <span className="text-accent-primary cursor-help text-[10px]">(?)</span>
                            </Tooltip>
                        </span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'use3rdpartyjoin', false)}
                            onChange={handleSwitchChange('Vichop', 'use3rdpartyjoin')}
                        />
                    </div>
                </div>
            </Card>
        </div>
    );

    const DiscordContent = (
        <div className="space-y-6">
            {isMainAccount ? (
                // Main account settings
                <Card title="Main Account - Discord Bot Settings">
                    <div className="space-y-4">
                        <p className="text-sm text-text-secondary mb-4">
                            Configure the Discord bot to receive signals from alt accounts. The main account listens for messages in a channel where alt accounts send Vicious Bee sightings. <strong className="text-status-info">This is only required if you are running alt accounts.</strong>
                        </p>



                        <Input
                            label={
                                <>
                                    Channel ID
                                    <Tooltip text="The Discord channel ID where alt accounts send signals. THIS MUST BE DIFFERENT from the Channel ID in Settings => Status.">
                                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                                    </Tooltip>
                                </>
                            }
                            type="text"
                            value={getSetting(settings, 'Vichop', 'main_channel_id', '')}
                            onChange={handleInputChange('Vichop', 'main_channel_id')}
                            placeholder="Enter channel ID..."
                        />

                        <div className="p-4 rounded-lg bg-status-warning/10 border border-status-warning/20">
                            <h4 className="text-sm font-semibold text-status-warning mb-2">Important Requirements</h4>
                            <ul className="text-xs text-text-muted space-y-2 list-disc list-inside">
                                <li>
                                    Having a Discord bot configured under <strong className="text-text-primary">Settings {'=>'} Status</strong> is <strong className="text-status-error">MANDATORY</strong>.
                                </li>
                                <li className="text-status-error">
                                    Make sure to turn on "Message Content Intent" for the bot in the Discord Developer Portal and potentially reinvite the bot to your server.
                                </li>
                                <li>
                                    The <strong>Channel ID</strong> above must be <strong className="text-status-warning">DIFFERENT</strong> from the one in Settings {'=>'} Status.
                                </li>
                                <li>
                                    This Channel ID must be the <strong>SAME</strong> as the one used by your alt accounts in their Vichop {'=>'} Discord.
                                </li>
                            </ul>
                        </div>
                    </div>
                </Card>
            ) : (
                // Alt account settings
                <Card title="Alt Account - Webhook Settings">
                    <div className="space-y-4">
                        <p className="text-sm text-text-secondary mb-4">
                            Configure the webhook for this alt account to send signals when Vicious Bee is found. The webhook should post to the same channel that the main account's bot monitors.
                        </p>

                        <Input
                            label={
                                <>
                                    Webhook URL
                                    <Tooltip text="The Discord webhook URL for the channel where signals are sent. This should be the same channel that the main account's bot is monitoring.">
                                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                                    </Tooltip>
                                </>
                            }
                            type="password"
                            value={getSetting(settings, 'Vichop', 'alt_webhook_url', '')}
                            onChange={handleInputChange('Vichop', 'alt_webhook_url')}
                            placeholder="https://discord.com/api/webhooks/..."
                        />

                        <div className="p-4 rounded-lg bg-accent-secondary/10 border border-accent-secondary/20">
                            <h4 className="text-sm font-semibold text-accent-secondary mb-2">Setup Instructions</h4>
                            <ol className="text-xs text-text-secondary space-y-1.5 list-decimal list-inside">
                                <li>Go to the same channel used for main account signals</li>
                                <li>Click the gear icon to edit the channel</li>
                                <li>Go to Integrations → Webhooks</li>
                                <li>Create a new webhook and copy the URL</li>
                                <li>Paste the URL above</li>
                            </ol>
                        </div>

                        <div className="p-4 rounded-lg bg-yellow-500/10 border border-yellow-500/20">
                            <p className="text-xs text-yellow-400">
                                <strong>Note:</strong> You can have multiple alt accounts, but only one main account. All alt webhooks should post to the same channel that the main account monitors.
                            </p>
                        </div>
                    </div>
                </Card>
            )}
        </div>
    );

    const StatsContent = (
        <div className="space-y-6">
            <Card title="Session Statistics">
                <div className="grid grid-cols-3 gap-4">
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">Servers Joined</p>
                        <p className="text-2xl font-bold text-text-primary">{sessionServersJoined}</p>
                    </div>
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">Nights Detected</p>
                        <p className="text-2xl font-bold text-indigo-400">{sessionNightsDetected}</p>
                    </div>
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">
                            {isMainAccount ? 'Vicious Killed' : 'Vicious Spotted'}
                        </p>
                        <p className="text-2xl font-bold text-red-400">
                            {isMainAccount ? sessionVicsKilled : sessionVicsSpotted}
                        </p>
                    </div>
                </div>
            </Card>

            <Card title="All-Time Statistics">
                <div className="grid grid-cols-3 gap-4">
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">Servers Joined</p>
                        <p className="text-2xl font-bold text-text-primary">{alltimeServersJoined}</p>
                    </div>
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">Nights Detected</p>
                        <p className="text-2xl font-bold text-indigo-400">{alltimeNightsDetected}</p>
                    </div>
                    <div className="p-4 rounded-xl bg-background-secondary border border-text-primary/10">
                        <p className="text-xs text-text-muted uppercase tracking-wider mb-1">
                            {isMainAccount ? 'Vicious Killed' : 'Vicious Spotted'}
                        </p>
                        <p className="text-2xl font-bold text-red-400">
                            {isMainAccount ? alltimeVicsKilled : alltimeVicsSpotted}
                        </p>
                    </div>
                </div>
            </Card>

            <div className="flex items-center justify-center gap-2 py-2">
                <div className="w-2 h-2 rounded-full bg-accent-primary animate-pulse"></div>
                <span className="text-xs text-text-muted">Stats auto-refreshing</span>
            </div>
        </div>
    );

    const displayPercent = localPercent ?? (parseInt(getSetting(settings, 'Vichop', 'vichop_active_percent', '100')) || 100);

    const ScheduleContent = (
        <div className="h-full flex flex-col">
            <Card title="Scheduling" className="flex-1">
                <div className="space-y-3">
                    <div className="flex items-center justify-between p-2 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-colors">
                        <span className="text-sm font-medium text-text-primary flex items-center">
                            Only Vichop and Higher
                            <Tooltip text="Run vichop for a fixed session duration, then restart from priority 1. Never runs lower priorities.">
                                <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                            </Tooltip>
                        </span>
                        <Switch
                            checked={getParsedSetting('Vichop', 'vichop_exclusive', false)}
                            onChange={handleSwitchChange('Vichop', 'vichop_exclusive')}
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-6">
                        <div className="flex flex-col items-center justify-center py-4 bg-background-secondary rounded-lg">
                            <CircularSlider
                                label="Active Minutes / Hour"
                                value={displayPercent}
                                onChange={setLocalPercent}
                                onInteractionEnd={(val) => {
                                    updateSetting('Vichop', 'vichop_active_percent', val.toString());
                                }}
                                min={0}
                                max={100}
                                size={220}
                                strokeWidth={18}
                                disabled={getParsedSetting('Vichop', 'vichop_exclusive', false)}
                            />
                            <p className="text-xs text-text-muted mt-4 text-center max-w-xs">
                                {getParsedSetting('Vichop', 'vichop_exclusive', false)
                                    ? "Exclusive mode. Scheduler ignored (100%)."
                                    : `Target: ${Math.round(displayPercent * 0.6)} min/hr`}
                            </p>
                        </div>

                        <div className={`flex flex-col items-center justify-center py-4 bg-background-secondary rounded-lg ${!getParsedSetting('Vichop', 'vichop_exclusive', false) ? 'opacity-50' : ''}`}>
                            <CircularSlider
                                label="Session Duration (minutes)"
                                value={localSessionDuration ?? (parseInt(getSetting(settings, 'Vichop', 'vichop_session_duration', '10')) || 10)}
                                onChange={setLocalSessionDuration}
                                onInteractionEnd={(val) => {
                                    updateSetting('Vichop', 'vichop_session_duration', val.toString());
                                }}
                                min={1}
                                max={60}
                                size={220}
                                strokeWidth={18}
                                disabled={!getParsedSetting('Vichop', 'vichop_exclusive', false)}
                                suffix="min"
                            />
                            <p className="text-xs text-text-muted mt-4 text-center max-w-xs">
                                {getParsedSetting('Vichop', 'vichop_exclusive', false)
                                    ? `Each session runs for ${localSessionDuration ?? (parseInt(getSetting(settings, 'Vichop', 'vichop_session_duration', '10')) || 10)} minutes`
                                    : "Enable exclusive retry to use session duration"}
                            </p>
                        </div>
                    </div>
                </div>
            </Card>
        </div>
    );

    const sidebarItems = [
        { id: 'general', label: 'General', content: GeneralContent },
        { id: 'schedule', label: 'Schedule', content: ScheduleContent },
        { id: 'discord', label: 'Discord', content: DiscordContent },
        { id: 'stats', label: 'Stats', content: StatsContent },
    ];

    return <TabSidebarLayout items={sidebarItems} />;
}

export default VichopTab;

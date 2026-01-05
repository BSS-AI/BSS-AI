import React, { useState, useEffect } from 'react';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { WebviewWindow } from '@tauri-apps/api/webviewWindow';
import { listen } from '@tauri-apps/api/event';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import IconSelect from './UI/IconSelect';
import Input from './UI/Input';
import Slider from './UI/Slider';
import Button from './UI/Button';
import TabSidebarLayout from './layout/TabSidebarLayout';
import ActionPriorityList from './ActionPriorityList';

const actionIcons: { [key: string]: string } = {
  "Planters": "planter_dark.webp",
  "Collect": "collect_dark.webp",
  "Kill": "kill_dark.webp",
  "Quest": "quest_dark.webp",
  "Gather": "gather_dark.webp",
  "Vichop": "vichop_dark.webp"
};

function getActionIcon(action: string) {
  return actionIcons[action] ? `/assets/${actionIcons[action]}` : null;
}

const sprinklerIcons: { [key: string]: string } = {
  "Supreme": "Supreme_Saturator.webp",
  "Diamond": "Diamond_Drenchers.webp",
  "Gold": "Golden_Gushers.webp",
  "Silver": "Silver_Soakers.webp",
  "Basic": "Basic_Sprinkler.webp"
};

function getSprinklerIcon(sprinkler: string) {
  return sprinklerIcons[sprinkler] ? `/assets/${sprinklerIcons[sprinkler]}` : null;
}

const moveMethodIcons: { [key: string]: string } = {
  "Cannon": "Red_cannon.webp",
  "Walk": "walk_icon.webp"
};

function getMoveMethodIcon(method: string) {
  return moveMethodIcons[method] ? `/assets/${moveMethodIcons[method]}` : null;
}

function SettingsTab({ currentTheme = 'dark', onThemeChange }: { currentTheme?: string, onThemeChange?: (theme: string) => void }) {
  const { settings, updateSetting, loading, error } = useSettings();
  const [privateServerUrlError, setPrivateServerUrlError] = useState('');

  // Custom Themes State
  const [customThemes, setCustomThemes] = useState<any[]>([]);

  const loadCustomThemes = () => {
    try {
      const stored = localStorage.getItem('custom_themes');
      if (stored) {
        setCustomThemes(JSON.parse(stored));
      }
    } catch (e) {
      console.error("Failed to load custom themes", e);
    }
  };

  useEffect(() => {
    loadCustomThemes();

    // Listen for updates from other windows
    const unlisten = listen('theme-updated', () => {
      loadCustomThemes();
    });

    return () => {
      unlisten.then(f => f());
    }
  }, []);

  const openThemeEditor = async (editId?: string) => {
    const label = 'theme-editor';
    const existing = await WebviewWindow.getByLabel(label);

    const url = `theme-editor.html${editId ? `?edit=${editId}` : ''}`;

    if (existing) {
      // If we want to change url, we probably need to close and reopen or eval js to change location.
      // Simplest is close and reopen for now.
      await existing.close();
    }

    new WebviewWindow(label, {
      url: url,
      title: 'Theme Editor',
      width: 900,
      height: 700,
      resizable: true,
      focus: true
    });
  };

  const handleSaveTheme = (theme: any) => {
    let updatedThemes = [...customThemes];
    const index = updatedThemes.findIndex(t => t.id === theme.id);
    if (index >= 0) {
      updatedThemes[index] = theme;
    } else {
      updatedThemes.push(theme);
    }
    setCustomThemes(updatedThemes);
    localStorage.setItem('custom_themes', JSON.stringify(updatedThemes));

    if (onThemeChange) onThemeChange(theme.id);
  };

  const handleDeleteTheme = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const updatedThemes = customThemes.filter(t => t.id !== id);
    setCustomThemes(updatedThemes);
    localStorage.setItem('custom_themes', JSON.stringify(updatedThemes));
    // If deleted current theme, switch to dark
    if (currentTheme === id && onThemeChange) {
      onThemeChange('dark');
    }
  };

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

  const handleSwitchChange = (section: string, key: string) => (checked: boolean) => {
    updateSetting(section, key, boolToIni(checked));
  };

  const handleInputChange = (section: string, key: string, type = 'text') => (e: React.ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }
    updateSetting(section, key, value);
  };

  const handlePrivateServerUrlChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    if (value.toLowerCase().includes('sharecode')) {
      setPrivateServerUrlError('Sharecode links are not allowed.');
      return;
    }
    setPrivateServerUrlError('');
    updateSetting(section, key, value);
  };

  const handleSelectChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newValue = e.target.value;
    const actionKeys = ['action1', 'action2', 'action3', 'action4', 'action5', 'action6'];

    // Swap logic for priority
    if (actionKeys.includes(key)) {
      const otherKey = actionKeys.find(k => k !== key && getSetting(settings, section, k, '') === newValue);
      if (otherKey) {
        const oldValue = getSetting(settings, section, key, '');
        updateSetting(section, otherKey, oldValue);
      }
    }

    updateSetting(section, key, newValue);
  };

  const getParsedSetting = (section: string, key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const usePrivateServer = getParsedSetting('Settings', 'useprivateserver', false);
  const usebot = getParsedSetting('Settings', 'usebot', false);
  const usewebhook = getParsedSetting('Settings', 'usewebhook', false);
  const usediscordrichpresence = getParsedSetting('Settings', 'usediscordrichpresence', true);

  const defaultThemes = [
    { value: 'dark', label: 'Dark' },
    { value: 'light', label: 'Light' },
    { value: 'tokyo', label: 'Tokyo Night' },
    { value: 'nord', label: 'Nord' },
    { value: 'dracula', label: 'Dracula' },
    { value: 'catppuccin', label: 'Catppuccin' },
    { value: 'sakuramochi', label: 'Sakuramochi' }
  ];

  const customThemeOptions = customThemes.map(t => ({ value: t.id, label: t.name }));
  const allThemeOptions = [...defaultThemes, ...customThemeOptions];

  // Credits Content
  const CreditsContent = (
    <div className="space-y-6">
      <Card title="Credits">
        <div className="space-y-4">
          <ul className="space-y-2 text-sm text-text-secondary">
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">Lead Dev</span>
              <span>Slymi</span>
            </li>
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">Lead Dev</span>
              <span>money_mountain</span>
            </li>
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">Developer</span>
              <span>Freezing</span>
            </li>
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">Core of AI</span>
              <span>SniperThrilla</span>
            </li>
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">AI Model</span>
              <span>Slymi & lvl18bubblebee</span>
            </li>
            <li className="flex items-center justify-between border-b border-glass-border pb-2">
              <span className="font-medium text-text-primary">Founder</span>
              <span>dutchrailwayslover</span>
            </li>
          </ul>

          <div className="pt-2">
            <h4 className="text-sm font-bold text-text-primary mb-2">Testers</h4>
            <p className="text-xs text-text-secondary leading-relaxed">
              money_mountain, pog.01, slymih, xawer5k2k, zenvhm, mini_orphan, poor_cereal, schnu145
            </p>
          </div>

          <div className="pt-2">
            <h4 className="text-sm font-bold text-text-primary mb-2">Annotators</h4>
            <p className="text-xs text-text-secondary leading-relaxed">
              schnu145, poor_cereal, billythecooldude, 613ghost, buko0365, cxnnsored, zenvhm, ze_ws, boyboxer, ividdyy, symbol_101, gui64977, devkeyboard, mqnke., pog.01, slymih, z_zqcv, money_mountain, clpd
            </p>
          </div>
        </div>
      </Card>

      <Card title="Special Thanks">
        <p className="text-sm text-text-secondary">
          Special thanks to <span className="font-semibold text-text-primary">Natro Macro</span> for setting the foundation and contributing so much to the open source macros.
        </p>
      </Card>

      <div className="pt-4 text-center">
        <p className="text-xs text-text-muted flex items-center justify-center gap-2">
          <span className="text-red-400">❤</span>
          <span>Dedicated to founder Bubble (lvl18bubblebee)</span>
          <span className="text-accent-primary">💙</span>
        </p>
      </div>
    </div>
  );

  // Changelog Content
  const ChangelogContent = (
    <Card title="Changelog">
      <div className="relative border-l border-glass-border ml-3 space-y-8 py-2">
        {[
          {
            version: "v0.0.2",
            date: "Current",
            items: [
              "Add Discord Rich Presence",
              "Better Installer",
              "COM communication bug fixes",
              "Guidance in Installer",
              "GUI revamp",
              "Recode GUI to Rust",
              "Recode Installer to Rust",
              "Smaller filesizes for everything",
              "Vichop"
            ]
          },
          {
            version: "v0.0.1",
            date: "Initial Release",
            items: [
              "Initial released"
            ]
          }
        ].map((release, idx) => (
          <div key={idx} className="relative pl-6">
            {/* Timeline Dot */}
            <div className="absolute -left-[5px] top-1.5 w-2.5 h-2.5 rounded-full bg-accent-primary shadow-[0_0_8px_rgba(59,130,246,0.5)]" />

            <div className="flex items-baseline gap-3 mb-2">
              <h3 className="text-lg font-bold text-text-primary">{release.version}</h3>
              <span className="text-xs text-text-muted uppercase tracking-wider font-medium">{release.date}</span>
            </div>

            <ul className="space-y-1.5">
              {release.items.map((item, i) => (
                <li key={i} className="text-sm text-text-secondary flex items-start">
                  <span className="mr-2 text-accent-primary/60">•</span>
                  {item}
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </Card>
  );

  // Character Content
  const CharacterContent = (
    <div className="space-y-4">
      <Card title="Character">
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Movement Speed"
            type="text"
            value={getSetting(settings, 'Settings', 'movespeed', '28')}
            onChange={handleInputChange('Settings', 'movespeed', 'number')}
          />
          <Input
            label="Camera Sensitivity"
            type="text"
            value={getSetting(settings, 'Settings', 'ingame_camera_sens', '1')}
            onChange={handleInputChange('Settings', 'ingame_camera_sens', 'number')}
          />
        </div>
      </Card>
      <Card title="Hive">
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Hive Slot"
            type="text"
            value={getSetting(settings, 'Settings', 'hiveslot', '1')}
            onChange={handleInputChange('Settings', 'hiveslot', 'number')}
          />
          <Input
            label="Hive Bees"
            type="text"
            value={getSetting(settings, 'Settings', 'hivebees', '50')}
            onChange={handleInputChange('Settings', 'hivebees', 'number')}
          />
          <Input
            label="Convert Delay (ms)"
            type="text"
            value={getSetting(settings, 'Settings', 'delayafterconvert', '10')}
            onChange={handleInputChange('Settings', 'delayafterconvert', 'number')}
            className="col-span-2"
          />
        </div>
      </Card>
    </div>
  );

  const StatusContent = (
    <Card title="Status & Notifications" className="h-full">
      <div className="space-y-4">
        <div className="flex items-center justify-between p-4 rounded-lg bg-background-secondary border border-glass-border">
          <span className="text-sm font-medium text-text-primary">Discord Rich Presence</span>
          <Switch
            checked={usediscordrichpresence}
            onChange={handleSwitchChange('Settings', 'usediscordrichpresence')}
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-4 rounded-lg bg-background-secondary border border-glass-border space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-text-primary">Use Discord Bot</span>
              <Switch
                checked={usebot}
                onChange={(checked) => {
                  if (!usebot) {
                    updateSetting('Settings', 'usebot', boolToIni(true));
                    if (usewebhook) updateSetting('Settings', 'usewebhook', boolToIni(false));
                  } else {
                    updateSetting('Settings', 'usebot', boolToIni(false));
                  }
                }}
              />
            </div>

            <div className={`transition-all duration-200 ${!usebot ? 'opacity-50 pointer-events-none' : ''}`}>
              <Input
                label="Bot Token"
                type="password"
                value={getSetting(settings, 'Settings', 'bottoken', 'MTE3NjU2NDQ1NDAzNzY3MjA0Nw.')}
                onChange={handleInputChange('Settings', 'bottoken')}
                disabled={!usebot}
              />
              <div className="mt-4">
                <Input
                  label="Main Channel ID"
                  type="text"
                  value={getSetting(settings, 'Settings', 'channelid', '')}
                  onChange={handleInputChange('Settings', 'channelid')}
                  disabled={!usebot}
                />
              </div>
            </div>
          </div>

          <div className="p-4 rounded-lg bg-background-secondary border border-glass-border space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-text-primary">Use Webhook</span>
              <Switch
                checked={usewebhook}
                onChange={(checked) => {
                  if (!usewebhook) {
                    updateSetting('Settings', 'usewebhook', boolToIni(true));
                    if (usebot) updateSetting('Settings', 'usebot', boolToIni(false));
                  } else {
                    updateSetting('Settings', 'usewebhook', boolToIni(false));
                  }
                }}
              />
            </div>

            <div className={`transition-all duration-200 ${!usewebhook ? 'opacity-50 pointer-events-none' : ''}`}>
              <Input
                label="Webhook URL"
                type="password"
                value={getSetting(settings, 'Settings', 'webhookurl', '')}
                onChange={handleInputChange('Settings', 'webhookurl')}
                disabled={!usewebhook}
              />
            </div>
          </div>
        </div>
      </div>
    </Card>
  );

  const MiscContent = (
    <Card title="Miscellaneous" className="w-full">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-text-secondary mb-1.5 uppercase tracking-wider">Private Server</label>
            <div className="flex items-center justify-between px-3 py-2.5 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-colors">
              <span className="text-sm font-medium text-text-primary">Use Private Server</span>
              <Switch
                checked={usePrivateServer}
                onChange={handleSwitchChange('Settings', 'useprivateserver')}
              />
            </div>
          </div>

          <Input
            label="Private Server URL"
            type="text"
            value={getSetting(settings, 'Settings', 'privateserverurl', 'https://www.roblox.com/games/1537690962/Bee-Swarm-Simulator?privateServerLinkCode=')}
            onChange={handlePrivateServerUrlChange('Settings', 'privateserverurl')}
            disabled={!usePrivateServer}
            error={privateServerUrlError}
            className={!usePrivateServer ? 'opacity-50' : ''}
          />

          <Input
            label="Key Delay (ms)"
            type="text"
            value={getSetting(settings, 'Settings', 'keydelay', '20')}
            onChange={handleInputChange('Settings', 'keydelay', 'number')}
          />

          <IconSelect
            label="Sprinkler Type"
            options={["Supreme", "Diamond", "Gold", "Silver", "Basic"]}
            value={getSetting(settings, 'Settings', 'sprinklertype', 'Supreme')}
            onChange={(val) => updateSetting('Settings', 'sprinklertype', val)}
            getIcon={getSprinklerIcon}
          />

          <IconSelect
            label="Move Method"
            options={["Cannon", "Walk"]}
            value={getSetting(settings, 'Settings', 'movemethod', 'Cannon')}
            onChange={(val) => updateSetting('Settings', 'movemethod', val)}
            getIcon={getMoveMethodIcon}
          />
        </div>

        <div className="space-y-4">
          <div className="p-3 rounded-lg bg-background-secondary border border-glass-border space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-text-primary">Always On Top</span>
              <Switch
                checked={getParsedSetting('Settings', 'alwaysontop', false)}
                onChange={(checked) => {
                  updateSetting('Settings', 'alwaysontop', boolToIni(checked));
                  getCurrentWindow().setAlwaysOnTop(checked).catch(console.error);
                }}
              />
            </div>

            <div className="flex items-center justify-between border-t border-glass-border pt-3">
              <span className="text-sm font-medium text-text-primary">Blur behind window</span>
              <Switch
                checked={getParsedSetting('Settings', 'blurwindow', false)}
                onChange={(checked) => {
                  updateSetting('Settings', 'blurwindow', boolToIni(checked));
                  if (checked) {
                    // Automatically set opacity to 75% when enabling blur for better effect
                    updateSetting('Settings', 'opacity', '85');
                    // Setting update triggers event which updates style in App.tsx
                  }
                }}
              />
            </div>

            <div>
              <Slider
                label="Window Opacity"
                value={parseInt(getSetting(settings, 'Settings', 'opacity', '100')) || 100}
                onChange={(e) => {
                  const val = parseInt(e.target.value);
                  updateSetting('Settings', 'opacity', val.toString());
                  document.documentElement.style.opacity = (val / 100).toString();
                }}
                min={10}
                max={100}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Select
              label="UI Theme"
              options={allThemeOptions.map(o => o.label)}
              value={allThemeOptions.find(o => o.value === currentTheme)?.label || 'Dark'}
              onChange={(e) => {
                const selected = allThemeOptions.find(o => o.label === e.target.value);
                if (selected && onThemeChange) onThemeChange(selected.value);
              }}
            />
            <div className="space-y-2">
              {customThemes.length > 0 && <div className="text-xs text-text-muted mt-2 mb-1 uppercase font-bold tracking-wider">Custom Themes</div>}
              <div className="grid grid-cols-2 gap-2">
                {customThemes.map(theme => (
                  <div key={theme.id} className="flex items-center justify-between p-2 bg-background-tertiary rounded border border-glass-border text-xs">
                    <div className="flex items-center gap-2 truncate">
                      <div className="w-3 h-3 rounded-full" style={{ background: theme.colors.bgPrimary, border: `1px solid ${theme.colors.accentPrimary}` }}></div>
                      <span className="truncate">{theme.name}</span>
                    </div>
                    <div className="flex gap-1">
                      <button
                        onClick={() => openThemeEditor(theme.id)}
                        className="p-1 hover:text-accent-primary" title="Edit"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                      </button>
                      <button
                        onClick={(e) => handleDeleteTheme(theme.id, e)}
                        className="p-1 hover:text-status-error" title="Delete"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              <div className="grid grid-cols-2 gap-2 mt-2">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => openThemeEditor()}
                  icon={<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>}
                >
                  Create
                </Button>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={async () => {
                    try {
                      const text = await navigator.clipboard.readText();
                      const theme = JSON.parse(text);
                      if (theme.name && theme.colors) {
                        theme.id = `imported-${Date.now()}`;
                        handleSaveTheme(theme);
                        alert(`Theme "${theme.name}" imported!`);
                      } else {
                        alert("Invalid theme JSON");
                      }
                    } catch (e) {
                      console.error(e);
                      alert("Failed to import. Copy JSON first.");
                    }
                  }}
                  icon={<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>}
                >
                  Import
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Card>
  );

  const PriorityContent = (
    <Card title="Macro Priority" className="w-full">
      <p className="text-xs text-text-muted mb-4 px-1">
        Drag to reorder. Tasks will only execute if they are enabled in their respective tabs.
      </p>
      <ActionPriorityList
        actions={[
          getSetting(settings, 'Settings', 'action1', 'Planters'),
          getSetting(settings, 'Settings', 'action2', 'Collect'),
          getSetting(settings, 'Settings', 'action3', 'Kill'),
          getSetting(settings, 'Settings', 'action4', 'Quest'),
          getSetting(settings, 'Settings', 'action5', 'Vichop'),
          getSetting(settings, 'Settings', 'action6', 'Gather'),
        ]}
        onChange={(newOrder) => {
          // Update all action settings based on new order
          updateSetting('Settings', 'action1', newOrder[0]);
          updateSetting('Settings', 'action2', newOrder[1]);
          updateSetting('Settings', 'action3', newOrder[2]);
          updateSetting('Settings', 'action4', newOrder[3]);
          updateSetting('Settings', 'action5', newOrder[4]);
          updateSetting('Settings', 'action6', newOrder[5]);
        }}
      />
    </Card>
  );

  const sidebarItems = [
    { id: 'character', label: 'Character', content: CharacterContent },
    { id: 'status', label: 'Status', content: StatusContent },
    { id: 'misc', label: 'Misc', content: MiscContent },
    { id: 'priority', label: 'Priority', content: PriorityContent },
    { id: 'credits', label: 'Credits', content: CreditsContent },
    { id: 'changelog', label: 'Changelog', content: ChangelogContent },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default SettingsTab;

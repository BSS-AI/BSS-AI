import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Input from './UI/Input';
import TabSidebarLayout from './layout/TabSidebarLayout';

const mobIcons: { [key: string]: string } = {
  "Ladybug": "Ladybug.webp",
  "Rhino Beetle": "RhinoBeetle.webp",
  "Spider": "spider.webp",
  "Mantis": "mantis.webp",
  "Scorpion": "Scorpion.webp",
  "Werewolf": "Werewolf.webp",
  "King Beetle": "King_Beetle.webp",
  "Tunnel Bear": "TunnelBear.webp",
  "Stump Snail": "Stump_Snail_GeplagtesSkelett.webp",
  "Coconut Crab": "Coconut_Crab.webp",
  "Commando Chick": "CommandoChick.webp",
  "Mondo Chick Autohop": "MondoChick.webp"
};

function getMobIcon(mobName: string) {
  return mobIcons[mobName] ? `/assets/${mobIcons[mobName]}` : null;
}

function KillTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

  const handleSwitchChange = (section: string, key: string) => (checked: boolean) => {
    updateSetting(section, key, boolToIni(checked));
  };

  const handleInputChange = (section: string, key: string, type = 'text') => (e: React.ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9]/g, '');
    }
    updateSetting(section, key, value);
  };

  const getParsedSetting = (section: string, key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const GeneralContent = (
    <Card title="General" className="h-full">
      <div className="space-y-4">
        <Input
          label="Mob Respawn Time (mins)"
          type="text"
          value={getSetting(settings, 'Kill', 'mobrespawntime', '0')}
          onChange={handleInputChange('Kill', 'mobrespawntime', 'number')}
          placeholder="0"
        />

        <div className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-colors">
          <span className="text-sm font-medium text-text-primary">Allow Gather Interrupt</span>
          <Switch
            checked={getParsedSetting('Kill', 'allowgatherinterrupt', false)}
            onChange={handleSwitchChange('Kill', 'allowgatherinterrupt')}
          />
        </div>
      </div>
    </Card>
  );

  const SpecificMobsContent = (
    <Card title="Specific Mobs" className="h-full">
      <div className="space-y-2">
        {[
          { label: "Ladybug", key: "ladybug", lootKey: "ladybugloot" },
          { label: "Rhino Beetle", key: "rhinobeetle", lootKey: "rhinobeetleloot" },
          { label: "Spider", key: "spider", lootKey: "spiderloot" },
          { label: "Mantis", key: "mantis", lootKey: "mantisloot" },
          { label: "Scorpion", key: "scorpion", lootKey: "scorpionloot" },
          { label: "Werewolf", key: "werewolf", lootKey: "werewolfloot" },
        ].map(mob => (
          <div key={mob.key} className="flex items-center justify-between p-2 rounded-lg hover:bg-white/5 transition-colors">
            <div className="flex items-center gap-2">
              {getMobIcon(mob.label) && <img src={getMobIcon(mob.label)!} alt="" className="w-12 h-12 object-contain" />}
              <span className="text-sm font-medium text-text-primary">{mob.label}</span>
            </div>
            <div className="flex items-center gap-4">
              {mob.lootKey && (
                <div className={`flex items-center gap-2 transition-opacity duration-200 ${!getParsedSetting('Kill', mob.key, false) ? 'opacity-50 pointer-events-none' : ''}`}>
                  <span className="text-xs text-text-muted uppercase tracking-wider">Loot</span>
                  <Switch
                    checked={getParsedSetting('Kill', mob.lootKey, false)}
                    onChange={handleSwitchChange('Kill', mob.lootKey)}
                    className="scale-75 origin-right"
                  />
                </div>
              )}
              <Switch
                checked={getParsedSetting('Kill', mob.key, false)}
                onChange={handleSwitchChange('Kill', mob.key)}
              />
            </div>
          </div>
        ))}
      </div>
    </Card>
  );

  const BossMobsContent = (
    <Card title="Boss Mobs" className="w-full">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {[
          { label: "King Beetle", key: "kingbeetle", babyLoveKey: "kingbeetlebabylove", keepOldKey: "kingbeetlekeepold" },
          { label: "Tunnel Bear", key: "tunnelbear", babyLoveKey: "tunnelbearbabylove", keepOldKey: null },
          { label: "Stump Snail", key: "stumpsnail", babyLoveKey: null, keepOldKey: "stumpsnailkeepold" },
          { label: "Coconut Crab", key: "coconutcrab", babyLoveKey: null, keepOldKey: null },
          { label: "Commando Chick", key: "commandochick", babyLoveKey: null, keepOldKey: null },
          // { label: "Mondo Chick Autohop", key: "mondohop", babyLoveKey: null, keepOldKey: null },
        ].map(boss => {
          const bossEnabled = getParsedSetting('Kill', boss.key, false);
          return (
            <div key={boss.key} className="p-4 rounded-lg bg-white/5 border border-white/5 hover:border-white/10 transition-colors">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  {getMobIcon(boss.label) && <img src={getMobIcon(boss.label)!} alt="" className="w-10 h-10 object-contain" />}
                  <span className="text-base font-medium text-text-primary">{boss.label}</span>
                </div>
                <Switch
                  checked={bossEnabled}
                  onChange={handleSwitchChange('Kill', boss.key)}
                />
              </div>

              {(boss.babyLoveKey || boss.keepOldKey) && (
                <div className={`space-y-3 pt-3 border-t border-white/5 transition-all duration-200 ${!bossEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
                  {boss.babyLoveKey && (
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-text-primary">Baby Love</span>
                      <Switch
                        checked={getParsedSetting('Kill', boss.babyLoveKey, false)}
                        onChange={handleSwitchChange('Kill', boss.babyLoveKey)}
                        className="scale-90 origin-right"
                      />
                    </div>
                  )}
                  {boss.keepOldKey && (
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-text-primary">Keep Old</span>
                      <Switch
                        checked={getParsedSetting('Kill', boss.keepOldKey, false)}
                        onChange={handleSwitchChange('Kill', boss.keepOldKey)}
                        className="scale-90 origin-right"
                      />
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </Card>
  );

  const sidebarItems = [
    { id: 'general', label: 'General', content: GeneralContent },
    { id: 'mobs', label: 'Specific Mobs', content: SpecificMobsContent },
    { id: 'bosses', label: 'Bosses', content: BossMobsContent },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default KillTab;
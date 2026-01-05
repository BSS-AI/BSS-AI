import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import TabSidebarLayout from './layout/TabSidebarLayout';

const toHiveOptions = ["Walk", "Cannon"];

function QuestTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

  const handleSwitchChange = (section: string, key: string) => (checked: boolean) => {
    updateSetting(section, key, boolToIni(checked));
  };

  const handleSelectChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
    updateSetting(section, key, e.target.value);
  };

  const getParsedSetting = (section: string, key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const GeneralContent = (
    <Card title="General Quest Options" className="w-full">
      <div className="space-y-4">
        <div className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-colors">
          <div className="flex items-center gap-3">
            <img src="/assets/polar_bear_questgiver.webp" alt="Polar Bear" className="w-8 h-8 object-contain" />
            <span className="text-sm font-medium text-text-primary">Polar Bear Quest</span>
          </div>
          <Switch
            checked={getParsedSetting('Quests', 'polarbear', false)}
            onChange={handleSwitchChange('Quests', 'polarbear')}
          />
        </div>

        <div className="p-3 rounded-lg bg-white/5 border border-white/5">
          <Select
            label="To Hive By Quest Method"
            options={toHiveOptions}
            value={getSetting(settings, 'Quests', 'tohivebyquest', 'Walk')}
            onChange={handleSelectChange('Quests', 'tohivebyquest')}
          />
        </div>
      </div>
    </Card>
  );

  const sidebarItems = [
    { id: 'general', label: 'General', content: GeneralContent },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default QuestTab;
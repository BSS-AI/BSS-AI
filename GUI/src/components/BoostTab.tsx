import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import Input from './UI/Input';
import TabSidebarLayout from './layout/TabSidebarLayout';

function BoostTab() {
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

  const handleSelectChange = (section: string, key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
    updateSetting(section, key, e.target.value);
  };

  const hotbarSlots = Array.from({ length: 7 }, (_, i) => i + 1);
  const useOptions = ["Always", "Gather Start", "Gathering", "At Hive", "Microconverter"];

  const HotbarContent = (
    <Card title="Hotbar Slots" className="w-full" bodyClassName="!p-0">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-white/10 text-xs font-bold text-text-muted uppercase tracking-wider">
              <th className="p-3 w-16 text-center">Slot</th>
              <th className="p-3 w-24 text-center">Enable</th>
              <th className="p-3">Condition</th>
              <th className="p-3 w-32">Delay (s)</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {hotbarSlots.map(slotNum => {
              const isEnabled = parseIniValue(getSetting(settings, 'Boost', `slot${slotNum}check`, false));

              return (
                <tr key={slotNum} className={`hover:bg-white/5 transition-colors ${!isEnabled ? 'opacity-60' : ''}`}>
                  <td className="py-2 px-3 text-center">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold mx-auto transition-colors ${isEnabled ? 'bg-accent-primary text-white shadow-lg shadow-accent-primary/20' : 'bg-white/5 text-text-muted'}`}>
                      {slotNum}
                    </div>
                  </td>
                  <td className="py-2 px-3 text-center">
                    <div className="flex justify-center">
                      <Switch
                        checked={isEnabled}
                        onChange={handleSwitchChange('Boost', `slot${slotNum}check`)}
                      />
                    </div>
                  </td>
                  <td className="py-2 px-3">
                    <Select
                      options={useOptions}
                      value={getSetting(settings, 'Boost', `slot${slotNum}use`, 'Always')}
                      onChange={handleSelectChange('Boost', `slot${slotNum}use`)}
                      disabled={!isEnabled}
                      className="!mt-0 w-full"
                    />
                  </td>
                  <td className="py-2 px-3">
                    <Input
                      type="text"
                      value={getSetting(settings, 'Boost', `slot${slotNum}time`, '0')}
                      onChange={handleInputChange('Boost', `slot${slotNum}time`, 'number')}
                      disabled={!isEnabled}
                      className="!mt-0"
                      placeholder="0"
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </Card>
  );

  const sidebarItems = [
    { id: 'hotbar', label: 'Hotbar', content: HotbarContent },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default BoostTab;
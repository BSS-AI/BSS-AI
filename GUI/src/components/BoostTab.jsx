import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

function BoostTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="text-center py-8">Loading settings...</div>;
  if (error) return <div className="text-center py-8 text-red-500">Error loading settings: {error}</div>;

  const handleSwitchChange = (section, key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleInputChange = (section, key, type = 'text') => (e) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9]/g, '');
    }
    updateSetting(section, key, value);
  };

  const handleSelectChange = (section, key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  const hotbarSlots = Array.from({ length: 7 }, (_, i) => i + 1);
  const useOptions = ["Always", "Gather Start", "Gathering", "At Hive", "Microconverter"];

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-pink-400">Boost Settings</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl">
        <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">Hotbar Slots</h3>
        <div className="grid grid-cols-1 gap-4">
          {hotbarSlots.map(slotNum => (
            <div key={slotNum} className="flex items-center justify-between bg-gray-700 p-3 rounded-md shadow-sm">
              <div className="flex items-center">
                <label htmlFor={`slot${slotNum}check`} className="text-lg mr-4">Slot {slotNum}:</label>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    id={`slot${slotNum}check`}
                    className="sr-only peer"
                    checked={parseIniValue(getSetting(settings, 'Boost', `slot${slotNum}check`, false))}
                    onChange={handleSwitchChange('Boost', `slot${slotNum}check`)}
                  />
                  <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center">
                <label htmlFor={`slot${slotNum}use`} className="text-md mr-2">Use:</label>
                <select
                  id={`slot${slotNum}use`}
                  className="w-40 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                  value={getSetting(settings, 'Boost', `slot${slotNum}use`, 'Always')}
                  onChange={handleSelectChange('Boost', `slot${slotNum}use`)}
                  disabled={!parseIniValue(getSetting(settings, 'Boost', `slot${slotNum}check`, false))}
                >
                  {useOptions.map(option => (
                    <option key={option} value={option}>{option}</option>
                  ))}
                </select>
              </div>

              <div className="flex items-center">
                <label htmlFor={`slot${slotNum}time`} className="text-md mr-2">Delay (s):</label>
                <input
                  id={`slot${slotNum}time`}
                  type="text"
                  className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                  value={getSetting(settings, 'Boost', `slot${slotNum}time`, '0')}
                  onChange={handleInputChange('Boost', `slot${slotNum}time`, 'number')}
                  disabled={!parseIniValue(getSetting(settings, 'Boost', `slot${slotNum}check`, false))}
                />
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

export default BoostTab;
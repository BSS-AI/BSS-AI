import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

const toHiveOptions = ["Walk", "Cannon"];

function QuestTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="text-center py-8">Loading settings...</div>;
  if (error) return <div className="text-center py-8 text-red-500">Error loading settings: {error}</div>;

  const handleSwitchChange = (section, key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleSelectChange = (section, key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  const getParsedSetting = (section, key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-indigo-300 to-purple-400">Quest Settings</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl">
        <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">General Quest Options</h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <label htmlFor="polarBear" className="text-lg">Polar Bear Quest:</label>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                id="polarBear"
                className="sr-only peer"
                checked={getParsedSetting('Quests', 'polarbear', false)}
                onChange={handleSwitchChange('Quests', 'polarbear')}
              />
              <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between">
            <label htmlFor="toHiveByQuest" className="text-lg">To Hive By Quest Method:</label>
            <select
              id="toHiveByQuest"
              className="w-40 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
              value={getSetting(settings, 'Quests', 'tohivebyquest', 'Walk')}
              onChange={handleSelectChange('Quests', 'tohivebyquest')}
            >
              {toHiveOptions.map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
        </div>
      </div>
    </>
  );
}

export default QuestTab;
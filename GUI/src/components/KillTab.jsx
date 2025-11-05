import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

function KillTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="text-center py-8">Loading settings...</div>;
  if (error) return <div className="text-center py-8 text-red-500">Error loading settings: {error}</div>;

  const handleSwitchChange = (section, key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleCheckboxChange = (section, key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleInputChange = (section, key, type = 'text') => (e) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9]/g, '');
    }
    updateSetting(section, key, value);
  };

  const getParsedSetting = (section, key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-red-300 to-rose-400">Kill Settings</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* General Kill Settings */}
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">General</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <label htmlFor="mobRespawnTime" className="text-lg">Mob Respawn Time (mins):</label>
              <input
                id="mobRespawnTime"
                type="text"
                className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
                value={getSetting(settings, 'Kill', 'mobrespawntime', '0')}
                onChange={handleInputChange('Kill', 'mobrespawntime', 'number')}
              />
            </div>
            <div className="flex items-center justify-between">
              <label htmlFor="allowGatherInterrupt" className="text-lg">Allow Gather Interrupt:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="allowGatherInterrupt"
                  className="sr-only peer"
                  checked={getParsedSetting('Kill', 'allowgatherinterrupt', false)}
                  onChange={handleSwitchChange('Kill', 'allowgatherinterrupt')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>
          </div>
        </div>

        {/* Specific Mobs */}
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-teal-400">Specific Mobs</h3>
          <div className="space-y-3">
            {[
              { label: "Ladybug", key: "ladybug", lootKey: "ladybugloot" },
              { label: "Rhino Beetle", key: "rhinobeetle", lootKey: "rhinobeetleloot" },
              { label: "Spider", key: "spider", lootKey: "spiderloot" },
              { label: "Mantis", key: "mantis", lootKey: "mantisloot" },
              { label: "Scorpion", key: "scorpion", lootKey: "scorpionloot" },
              { label: "Werewolf", key: "werewolf", lootKey: "werewolfloot" },
            ].map(mob => (
              <div key={mob.key} className="flex items-center justify-between">
                <label htmlFor={mob.key} className="text-lg">{mob.label}:</label>
                <div className="flex items-center space-x-4">
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      id={mob.key}
                      className="sr-only peer"
                      checked={getParsedSetting('Kill', mob.key, false)}
                      onChange={handleSwitchChange('Kill', mob.key)}
                    />
                    <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                  </label>
                  {mob.lootKey && (
                    <div className="flex items-center text-sm">
                      <label htmlFor={`${mob.lootKey}`} className={`mr-2 ${!getParsedSetting('Kill', mob.key, false) ? 'opacity-50' : ''}`}>Loot:</label>
                      <input
                        type="checkbox"
                        id={`${mob.lootKey}`}
                        className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                        checked={getParsedSetting('Kill', mob.lootKey, false)}
                        onChange={handleCheckboxChange('Kill', mob.lootKey)}
                        disabled={!getParsedSetting('Kill', mob.key, false)}
                      />
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Boss Mobs */}
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-pink-400">Boss Mobs</h3>
          <div className="space-y-4">
            {[
              { label: "King Beetle", key: "kingbeetle", babyLoveKey: "kingbeetlebabylove", keepOldKey: "kingbeetlekeepold" },
              { label: "Tunnel Bear", key: "tunnelbear", babyLoveKey: "tunnelbearbabylove", keepOldKey: null },
              { label: "Stump Snail", key: "stumpsnail", babyLoveKey: null, keepOldKey: "stumpsnailkeepold" },
              { label: "Coconut Crab", key: "coconutcrab", babyLoveKey: null, keepOldKey: null },
              { label: "Commando Chick", key: "commandochick", babyLoveKey: null, keepOldKey: null },
            ].map(boss => {
              const bossEnabled = getParsedSetting('Kill', boss.key, false);
              return (
                <div key={boss.key}>
                  <div className="flex items-center justify-between">
                    <label htmlFor={boss.key} className="text-lg">{boss.label}:</label>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        id={boss.key}
                        className="sr-only peer"
                        checked={bossEnabled}
                        onChange={handleSwitchChange('Kill', boss.key)}
                      />
                      <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                    </label>
                  </div>

                  {bossEnabled && (boss.babyLoveKey || boss.keepOldKey) && (
                    <div className="ml-8 mt-2 space-y-2">
                      {boss.babyLoveKey && (
                        <div className="flex items-center justify-between text-sm">
                          <label htmlFor={boss.babyLoveKey} className="text-gray-300">Baby Love:</label>
                          <input
                            type="checkbox"
                            id={boss.babyLoveKey}
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Kill', boss.babyLoveKey, false)}
                            onChange={handleCheckboxChange('Kill', boss.babyLoveKey)}
                          />
                        </div>
                      )}
                      {boss.keepOldKey && (
                        <div className="flex items-center justify-between text-sm">
                          <label htmlFor={boss.keepOldKey} className="text-gray-300">Keep Old:</label>
                          <input
                            type="checkbox"
                            id={boss.keepOldKey}
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Kill', boss.keepOldKey, false)}
                            onChange={handleCheckboxChange('Kill', boss.keepOldKey)}
                          />
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </>
  );
}

export default KillTab;
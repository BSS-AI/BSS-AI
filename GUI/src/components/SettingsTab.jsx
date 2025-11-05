import React, { useEffect, useState } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

function SettingsTab() {
  const { settings, updateSetting, loading, error } = useSettings();
  const [privateServerUrlError, setPrivateServerUrlError] = useState('');

  if (loading) return <div className="text-center py-8">Loading settings...</div>;
  if (error) return <div className="text-center py-8 text-red-500">Error loading settings: {error}</div>;

  const handleSwitchChange = (section, key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleInputChange = (section, key, type = 'text') => (e) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }
    updateSetting(section, key, value);
  };

  const handlePrivateServerUrlChange = (section, key) => (e) => {
    const value = e.target.value;
    if (value.toLowerCase().includes('sharecode')) {
      setPrivateServerUrlError('Sharecode links are not allowed.');
      return;
    }
    setPrivateServerUrlError('');
    updateSetting(section, key, value);
  };

  const handleSelectChange = (section, key) => (e) => {
    const newValue = e.target.value;
    const actionKeys = ['action1', 'action2', 'action3', 'action4', 'action5'];
    const otherKey = actionKeys.find(k => k !== key && getSetting(settings, section, k, '') === newValue);
    if (otherKey) {
      const oldValue = getSetting(settings, section, key, '');
      updateSetting(section, otherKey, oldValue);
    }
    updateSetting(section, key, newValue);
  };

  const getParsedSetting = (section, key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const usePrivateServer = getParsedSetting('Settings', 'useprivateserver', false);
  const usebot = getParsedSetting('Settings', 'usebot', false);
  const usewebhook = getParsedSetting('Settings', 'usewebhook', false);

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-gray-300 to-blue-400">Macro Settings</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">Character</h3>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="movementSpeed" className="text-lg">Movement Speed:</label>
            <input
              id="movementSpeed"
              type="text"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'movespeed', '28')}
              onChange={handleInputChange('Settings', 'movespeed', 'number')}
            />
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-teal-400">Hive</h3>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="hiveSlot" className="text-lg">Hive Slot:</label>
            <input
              id="hiveSlot"
              type="text"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'hiveslot', '1')}
              onChange={handleInputChange('Settings', 'hiveslot', 'number')}
            />
          </div>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="hiveBees" className="text-lg">Hive Bees:</label>
            <input
              id="hiveBees"
              type="text"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'hivebees', '50')}
              onChange={handleInputChange('Settings', 'hivebees', 'number')}
            />
          </div>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="convertDelay" className="text-lg">Convert Delay (ms):</label>
            <input
              id="convertDelay"
              type="text"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'delayafterconvert', '10')}
              onChange={handleInputChange('Settings', 'delayafterconvert', 'number')}
            />
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md col-span-full">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-yellow-300 to-green-400">Status</h3>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="useBot" className="text-lg">Use Discord Bot:</label>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                id="useBot"
                className="sr-only peer"
                checked={usebot}
                onChange={e => {
                  if (!usebot) {
                    updateSetting('Settings', 'usebot', boolToIni(true));
                    if (usewebhook) updateSetting('Settings', 'usewebhook', boolToIni(false));
                  } else {
                    updateSetting('Settings', 'usebot', boolToIni(false));
                  }
                }}
              />
              <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>
          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="useWebhook" className="text-lg">Use Webhook:</label>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                id="useWebhook"
                className="sr-only peer"
                checked={usewebhook}
                onChange={e => {
                  if (!usewebhook) {
                    updateSetting('Settings', 'usewebhook', boolToIni(true));
                    if (usebot) updateSetting('Settings', 'usebot', boolToIni(false));
                  } else {
                    updateSetting('Settings', 'usewebhook', boolToIni(false));
                  }
                }}
              />
              <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>
          <div className="mb-4">
            <label htmlFor="bottoken" className="block text-lg mb-2">Bot Token:</label>
            <input
              id="bottoken"
              type="text"
              className={`w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 ${(usewebhook || !usebot) ? 'opacity-50 cursor-not-allowed' : ''}`}
              value={getSetting(settings, 'Settings', 'bottoken', 'MTE3NjU2NDQ1NDAzNzY3MjA0Nw.')}
              onChange={handleInputChange('Settings', 'bottoken')}
              disabled={usewebhook || !usebot}
            />
          </div>
          <div className="mb-4">
            <label htmlFor="channelid" className="block text-lg mb-2">Main Channel ID:</label>
            <input
              id="channelid"
              type="text"
              className={`w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 ${(usewebhook || !usebot) ? 'opacity-50 cursor-not-allowed' : ''}`}
              value={getSetting(settings, 'Settings', 'channelid', '')}
              onChange={handleInputChange('Settings', 'channelid')}
              disabled={usewebhook || !usebot}
            />
          </div>
          <div className="mb-4">
            <label htmlFor="webhookurl" className="block text-lg mb-2">Webhook URL:</label>
            <input
              id="webhookurl"
              type="text"
              className={`w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 ${(usebot || !usewebhook) ? 'opacity-50 cursor-not-allowed' : ''}`}
              value={getSetting(settings, 'Settings', 'webhookurl', '')}
              onChange={handleInputChange('Settings', 'webhookurl')}
              disabled={usebot || !usewebhook}
            />
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md col-span-full">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-orange-300 to-red-400">Miscellaneous</h3>

          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="usePrivateServer" className="text-lg">Use Private Server:</label>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                id="usePrivateServer"
                className="sr-only peer"
                checked={usePrivateServer}
                onChange={handleSwitchChange('Settings', 'useprivateserver')}
              />
              <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
          </div>
          <div className="mb-4">
            <label htmlFor="privateServerUrl" className="block text-lg mb-2">Private Server URL:</label>
            <input
              id="privateServerUrl"
              type="text"
              className={`w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 ${!usePrivateServer ? 'opacity-50 cursor-not-allowed' : ''}`}
              value={getSetting(settings, 'Settings', 'privateserverurl', 'https://www.roblox.com/games/1537690962/Bee-Swarm-Simulator?privateServerLinkCode=')}
              onChange={handlePrivateServerUrlChange('Settings', 'privateserverurl')}
              disabled={!usePrivateServer}
            />
            {privateServerUrlError && (
              <div className="text-sm text-red-400 mt-1">{privateServerUrlError}</div>
            )}
          </div>

          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="keyDelay" className="text-lg">Key Delay (ms):</label>
            <input
              id="keyDelay"
              type="text"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'keydelay', '20')}
              onChange={handleInputChange('Settings', 'keydelay', 'number')}
            />
          </div>

          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="sprinklerType" className="text-lg">Sprinkler Type:</label>
            <select
              id="sprinklerType"
              className="w-48 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'sprinklertype', 'Supreme')}
              onChange={handleSelectChange('Settings', 'sprinklertype')}
            >
              {["Supreme", "Diamond", "Gold", "Silver", "Basic"].map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>

          <div className="mb-4 flex items-center justify-between">
            <label htmlFor="moveMethod" className="text-lg">Move Method:</label>
            <select
              id="moveMethod"
              className="w-48 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, 'Settings', 'movemethod', 'Cannon')}
              onChange={handleSelectChange('Settings', 'movemethod')}
            >
              {["Cannon", "Walk"].map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="bg-gray-700 p-5 rounded-lg shadow-md col-span-full">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-cyan-400">Macro Priority</h3>
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            {['action1', 'action2', 'action3', 'action4', 'action5'].map((actionKey, idx) => {
              const selected = [
                getSetting(settings, 'Settings', 'action1', ''),
                getSetting(settings, 'Settings', 'action2', ''),
                getSetting(settings, 'Settings', 'action3', ''),
                getSetting(settings, 'Settings', 'action4', ''),
                getSetting(settings, 'Settings', 'action5', '')
              ];
              const defaultOrder = ['Planters', 'Collect', 'Kill', 'Quest', 'Gather'];
              return (
                <div key={actionKey} className="mb-4">
                  <label htmlFor={actionKey} className="block text-md mb-2">{`Priority ${idx + 1}`}</label>
                  <select
                    id={actionKey}
                    className="w-full p-2 rounded-md bg-gray-600 border border-purple-500 focus:outline-none focus:ring-2 focus:ring-purple-400 transition-all duration-200"
                    value={getSetting(settings, 'Settings', actionKey, defaultOrder[idx])}
                    onChange={handleSelectChange('Settings', actionKey)}
                  >
                    {defaultOrder.map(opt => (
                      <option key={opt} value={opt}>{opt}</option>
                    ))}
                  </select>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </>
  );
}

export default SettingsTab;
import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

function CollectTab() {
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

  const handleBlenderAmountChange = (section, key) => (e) => {
    let value = e.target.value;
    value = value.replace(/[^0-9]/g, '');
    if (value && (parseInt(value) < 1 || parseInt(value) > 9999)) {
      return;
    }
    updateSetting(section, key, value);
  };

  const handleBlenderRepeatChange = (section, key) => (e) => {
    let value = e.target.value;
    if (value === 'Infinite') {
      updateSetting(section, key, 'Infinite');
    } else {
      value = value.replace(/[^0-9]/g, '');
      if (value && parseInt(value) > 9999) {
        return;
      }
      updateSetting(section, key, value);
    }
  };

  const handleSelectChange = (section, key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  const getParsedSetting = (section, key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const nectarTypes = ["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"];

  const blenderItems = [
    "None", "Red Extract", "Blue Extract", "Enzymes", "Oil", "Glue", "Tropical Drink",
    "Gumdrops", "Moon Charms", "Glitter", "Star Jelly", "Purple Potion", "Soft Wax",
    "Hard Wax", "Swirled Wax", "Caustic Wax", "Field Dice", "Smooth Dice", "Loaded Dice",
    "Super Smoothie", "Turpentine"
  ];

  const eggTypes = ["None", "Basic", "Silver", "Gold", "Diamond", "Mythic"];

  const stickerStackItems = ["Tickets", "Stickers", "Stickers + Tickets"];

  const blenderEnabled = getParsedSetting('Collect', 'blenderCheck', false);
  const nectarPotEnabled = getParsedSetting('Collect', 'nectarpot', false);
  const nectarCondenserEnabled = getParsedSetting('Collect', 'nectarconsender', false);
  const stickerPrinterEnabled = getParsedSetting('Collect', 'stickerprinter', false);
  const stickerStackEnabled = getParsedSetting('Collect', 'stickerstack', false);
  const stickerStackItem = getSetting(settings, 'Collect', 'stickerstackitem', 'Tickets');
  const stickerStackTimerDetect = getParsedSetting('Collect', 'stickerstacktimerdetect', false);

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-yellow-300 to-orange-400">Collect Settings</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">Basic Collectables</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <label htmlFor="wealthClock" className="text-lg">Wealth Clock:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="wealthClock"
                  className="sr-only peer"
                  checked={getParsedSetting('Collect', 'wealthclock', false)}
                  onChange={handleSwitchChange('Collect', 'wealthclock')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="antPass" className="text-lg">Ant Pass Dispenser:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="antPass"
                  className="sr-only peer"
                  checked={getParsedSetting('Collect', 'antpass', false)}
                  onChange={handleSwitchChange('Collect', 'antpass')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="antPassTickets" className="text-lg">Ant Pass Tickets:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="antPassTickets"
                  className="sr-only peer"
                  checked={getParsedSetting('Collect', 'antpasstickets', false)}
                  onChange={handleSwitchChange('Collect', 'antpasstickets')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="honeyStorm" className="text-lg">Honeystorm:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="honeyStorm"
                  className="sr-only peer"
                  checked={getParsedSetting('Collect', 'honeystorm', false)}
                  onChange={handleSwitchChange('Collect', 'honeystorm')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="glueDispenser" className="text-lg">Glue Dispenser:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="glueDispenser"
                  className="sr-only peer"
                  checked={getParsedSetting('Collect', 'gluedispenser', false)}
                  onChange={handleSwitchChange('Collect', 'gluedispenser')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-teal-400">Nectar Systems</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <label htmlFor="nectarPot" className="text-lg">Nectar Pot:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="nectarPot"
                  className="sr-only peer"
                  checked={nectarPotEnabled}
                  onChange={handleSwitchChange('Collect', 'nectarpot')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>
            <div className="ml-8 flex items-center justify-between text-sm">
              <label htmlFor="nectarPotType" className={`text-gray-300 ${!nectarPotEnabled ? 'opacity-50' : ''}`}>Nectar to store:</label>
              <select
                id="nectarPotType"
                className={`w-36 p-1 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm ${!nectarPotEnabled ? 'opacity-50 cursor-not-allowed' : ''}`}
                value={getSetting(settings, 'Collect', 'nectarpotnectar', 'Comforting')}
                onChange={handleSelectChange('Collect', 'nectarpotnectar')}
                disabled={!nectarPotEnabled}
              >
                {nectarTypes.map(option => (
                  <option key={option} value={option}>{option}</option>
                ))}
              </select>
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="nectarCondenser" className="text-lg">Nectar Condenser:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="nectarCondenser"
                  className="sr-only peer"
                  checked={nectarCondenserEnabled}
                  onChange={handleSwitchChange('Collect', 'nectarconsender')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>
            <div className="ml-8 flex items-center justify-between text-sm">
              <label htmlFor="condenseType" className={`text-gray-300 ${!nectarCondenserEnabled ? 'opacity-50' : ''}`}>Condense:</label>
              <select
                id="condenseType"
                className={`w-36 p-1 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm ${!nectarCondenserEnabled ? 'opacity-50 cursor-not-allowed' : ''}`}
                value={getSetting(settings, 'Collect', 'nectarconsendernectar', 'Comforting')}
                onChange={handleSelectChange('Collect', 'nectarconsendernectar')}
                disabled={!nectarCondenserEnabled}
              >
                {nectarTypes.map(option => (
                  <option key={option} value={option}>{option}</option>
                ))}
              </select>
            </div>
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md col-span-1 lg:col-span-2">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-pink-400">Blender</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <label htmlFor="blenderCheck" className="text-lg">Enable Blender:</label>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  id="blenderCheck"
                  className="sr-only peer"
                  checked={blenderEnabled}
                  onChange={handleSwitchChange('Collect', 'blenderCheck')}
                />
                <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            {blenderEnabled && (
              <div className="ml-8 space-y-4">
                {[1, 2, 3].map(slot => (
                  <div key={slot} className="border border-gray-600 p-4 rounded-lg">
                    <h4 className="text-lg font-medium mb-3">Slot {slot}</h4>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                      <div>
                        <label className="block text-sm text-gray-300 mb-1">Item:</label>
                        <select
                          className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                          value={getSetting(settings, 'Collect', `blenderslot${slot}item`, 'None')}
                          onChange={handleSelectChange('Collect', `blenderslot${slot}item`)}
                        >
                          {blenderItems.map(item => (
                            <option key={item} value={item}>{item}</option>
                          ))}
                        </select>
                      </div>
                      <div>
                        <label className="block text-sm text-gray-300 mb-1">Amount (1-9999):</label>
                        <input
                          type="text"
                          className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                          value={getSetting(settings, 'Collect', `blenderslot${slot}ammount`, '0')}
                          onChange={handleBlenderAmountChange('Collect', `blenderslot${slot}ammount`)}
                          placeholder="0"
                        />
                      </div>
                      <div>
                        <label className="block text-sm text-gray-300 mb-1">Repeat:</label>
                        <input
                          type="text"
                          className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                          value={getSetting(settings, 'Collect', `blenderslot${slot}repeat`, '0')}
                          onChange={handleBlenderRepeatChange('Collect', `blenderslot${slot}repeat`)}
                          placeholder="0 or Infinite"
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
        <div className="bg-gray-700 p-5 rounded-lg shadow-md col-span-1 lg:col-span-2">
          <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-red-300 to-rose-400">Sticker Systems</h3>
          <div className="space-y-6">
            <div>
              <div className="flex items-center justify-between">
                <label htmlFor="stickerPrinter" className="text-lg">Sticker Printer:</label>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    id="stickerPrinter"
                    className="sr-only peer"
                    checked={stickerPrinterEnabled}
                    onChange={handleSwitchChange('Collect', 'stickerprinter')}
                  />
                  <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                </label>
              </div>
              <div className="ml-8 flex items-center justify-between text-sm mt-2">
                <label htmlFor="stickerPrinterEgg" className={`text-gray-300 ${!stickerPrinterEnabled ? 'opacity-50' : ''}`}>Egg Type:</label>
                <select
                  id="stickerPrinterEgg"
                  className={`w-32 p-1 mt-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm ${!stickerPrinterEnabled ? 'opacity-50 cursor-not-allowed' : ''}`}
                  value={getSetting(settings, 'Collect', 'stickerprinteregg', 'None')}
                  onChange={handleSelectChange('Collect', 'stickerprinteregg')}
                  disabled={!stickerPrinterEnabled}
                >
                  {eggTypes.map(egg => (
                    <option key={egg} value={egg} className="py-2">{egg}</option>
                  ))}
                </select>
              </div>
            </div>
            <div>
              <div className="flex items-center justify-between">
                <label htmlFor="stickerStack" className="text-lg">Sticker Stacker:</label>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    id="stickerStack"
                    className="sr-only peer"
                    checked={stickerStackEnabled}
                    onChange={handleSwitchChange('Collect', 'stickerstack')}
                  />
                  <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                </label>
              </div>

              {stickerStackEnabled && (
                <div className="ml-8 space-y-3 mt-3">
                  <div className="flex items-center justify-between text-sm">
                    <label htmlFor="stickerStackItem" className="text-gray-300">Item to stack:</label>
                    <select
                      id="stickerStackItem"
                      className="w-40 p-1 mt-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                      value={stickerStackItem}
                      onChange={handleSelectChange('Collect', 'stickerstackitem')}
                    >
                      {stickerStackItems.map(item => (
                        <option key={item} value={item} className="py-2">{item}</option>
                      ))}
                    </select>
                  </div>

                  {(stickerStackItem === 'Stickers' || stickerStackItem === 'Stickers + Tickets') && (
                    <div className="flex items-center text-red-400 text-sm bg-red-900/20 p-2 rounded border border-red-500">
                      <span className="mr-2">⚠️</span>
                      <span>Consider trading all of your valuable stickers to an alternative account, to ensure you do not lose any valuable stickers.</span>
                    </div>
                  )}

                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-sm">
                      <label htmlFor="stickerStackTimerDetect" className="text-gray-300">Timer Detect:</label>
                      <input
                        type="checkbox"
                        id="stickerStackTimerDetect"
                        className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                        checked={stickerStackTimerDetect}
                        onChange={handleCheckboxChange('Collect', 'stickerstacktimerdetect')}
                      />
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <label htmlFor="stickerStackTimer" className={`text-gray-300 ${stickerStackTimerDetect ? 'opacity-50' : ''}`}>Timer (mins):</label>
                      <input
                        id="stickerStackTimer"
                        type="text"
                        className={`w-20 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm ${stickerStackTimerDetect ? 'opacity-50 cursor-not-allowed' : ''}`}
                        value={getSetting(settings, 'Collect', 'stickerstacktimer', '0')}
                        onChange={handleInputChange('Collect', 'stickerstacktimer', 'number')}
                        disabled={stickerStackTimerDetect}
                      />
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-gray-300">Stack Options:</span>
                      <div className="flex items-center space-x-4">
                        <label className="flex items-center space-x-1">
                          <input
                            type="checkbox"
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Collect', 'stickerstackhives', false)}
                            onChange={handleCheckboxChange('Collect', 'stickerstackhives')}
                          />
                          <span className="text-gray-300">Hives</span>
                        </label>
                        <label className="flex items-center space-x-1">
                          <input
                            type="checkbox"
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Collect', 'stickerstackcubs', false)}
                            onChange={handleCheckboxChange('Collect', 'stickerstackcubs')}
                          />
                          <span className="text-gray-300">Cubs</span>
                        </label>
                        <label className="flex items-center space-x-1">
                          <input
                            type="checkbox"
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Collect', 'stickerstackvouches', false)}
                            onChange={handleCheckboxChange('Collect', 'stickerstackvouches')}
                          />
                          <span className="text-gray-300">Vouches</span>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default CollectTab;
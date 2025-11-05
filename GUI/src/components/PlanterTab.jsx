import React, { useState } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

const planterTypes = ["None", "Plastic", "Candy", "Red Clay", "Blue Clay", "Tacky", "Pesticide", "Heat-treated", "Hydroponic", "Petal", "PoP"];
const fieldOptions = [
  "Sunflower", "Dandelion", "Mushroom", "Blue Flower", "Clover", "Strawberry", "Spider",
  "Bamboo", "Pineapple", "Stump", "Cactus", "Pumpkin", "Pine Tree", "Rose",
  "Mountain Top", "Pepper", "Coconut"
];
const timeOptions = ["30 mins", "1 hour", "1h 30 mins", "2 hours", "2h 30 mins", "3 hours", "3h 30 mins", "4 hours", "4h 30 mins", "5 hours", "5h 30 mins", "6 hours"];
const nectarTypes = ["None", "Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"];
const percentageOptions = ["100", "90", "80", "70", "60", "50", "40", "30", "20", "10"];
const maxPlantersOptions = ["3", "2", "1"];

function formatUnixTime(unix) {
  if (!unix || unix === '0') return 'Not set';
  const date = new Date(parseInt(unix, 10) * 1000);
  if (isNaN(date.getTime())) return 'Invalid';
  return date.toLocaleString();
}

function PlanterTimers() {
  const { settings: timerSettings, updateSetting, loading, error, readSettings } = useSettings({}, 'timers.ini');

  const planterKeys = [1, 2, 3].map(num => ({
    name: `PlanterName${num}`,
    field: `PlanterField${num}`,
    nectar: `PlanterNectar${num}`,
    harvestTime: `PlanterHarvestTime${num}`,
    estPercent: `PlanterEstPercent${num}`,
    harvestNow: `PlanterHarvestNow${num}`,
  }));

  const handleReset = async (num) => {
    const defaults = {
      [`PlanterName${num}`]: 'None',
      [`PlanterField${num}`]: 'None',
      [`PlanterNectar${num}`]: 'None',
      [`PlanterHarvestTime${num}`]: '0',
      [`PlanterEstPercent${num}`]: '0',
      [`PlanterHarvestNow${num}`]: '0',
    };
    for (const [key, value] of Object.entries(defaults)) {
      await updateSetting('Planters', key, value, 'timers.ini');
    }
    readSettings();
  };

  if (loading) return <div className="text-center py-4">Loading planter timers...</div>;
  if (error) return <div className="text-center py-4 text-red-500">Error loading timers: {error}</div>;

  return (
    <div className="mt-10 bg-gray-900 p-6 rounded-lg shadow-xl border-t border-gray-700">
      <h3 className="text-2xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-yellow-300 to-orange-400">Planter Timers</h3>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {planterKeys.map((keys, idx) => (
          <div key={idx} className="bg-gray-800 p-4 rounded-lg shadow-md flex flex-col">
            <h4 className="text-lg font-semibold mb-3 text-blue-300">Planter {idx + 1}</h4>
            <div className="mb-2 flex justify-between">
              <span className="font-medium">Name:</span>
              <span>{timerSettings.Planters?.[keys.name] || 'None'}</span>
            </div>
            <div className="mb-2 flex justify-between">
              <span className="font-medium">Field:</span>
              <span>{timerSettings.Planters?.[keys.field] || 'None'}</span>
            </div>
            <div className="mb-2 flex justify-between">
              <span className="font-medium">Nectar:</span>
              <span>{timerSettings.Planters?.[keys.nectar] || 'None'}</span>
            </div>
            <div className="mb-2 flex justify-between">
              <span className="font-medium">Harvest Time:</span>
              <span>{formatUnixTime(timerSettings.Planters?.[keys.harvestTime])}</span>
            </div>
            <button
              className="mt-4 px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded transition-all font-semibold"
              onClick={() => handleReset(idx + 1)}
            >
              Reset
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

function ManualPlanterCycle({ cycleNum, settings, updateSetting }) {
  const section = 'Planters';

  const handleSelectChange = (key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  return (
    <div className="bg-gray-700 p-4 rounded-lg shadow-md">
      <h4 className="text-lg font-semibold mb-3 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">Cycle {cycleNum}</h4>
      {[1, 2, 3].map(planterNum => (
        <div key={planterNum} className="mb-4 p-3 bg-gray-600 rounded-md">
          <h5 className="text-md font-medium mb-2">Planter {planterNum}</h5>
          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <label>Type:</label>
              <select
                className="w-32 p-1 rounded-md bg-gray-500 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
                value={getSetting(settings, section, `cycle${cycleNum}planter${planterNum}`, 'None')}
                onChange={handleSelectChange(`cycle${cycleNum}planter${planterNum}`)}
              >
                {planterTypes.map(option => <option key={option} value={option}>{option}</option>)}
              </select>
            </div>
            <div className="flex items-center justify-between text-sm">
              <label>Field:</label>
              <select
                className="w-32 p-1 rounded-md bg-gray-500 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
                value={getSetting(settings, section, `cycle${cycleNum}field${planterNum}`, 'Sunflower')}
                onChange={handleSelectChange(`cycle${cycleNum}field${planterNum}`)}
              >
                {fieldOptions.map(option => <option key={option} value={option}>{option}</option>)}
              </select>
            </div>
            <div className="flex items-center justify-between text-sm">
              <label>Time:</label>
              <select
                className="w-32 p-1 rounded-md bg-gray-500 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
                value={getSetting(settings, section, `cycle${cycleNum}time${planterNum}`, '30 mins')}
                onChange={handleSelectChange(`cycle${cycleNum}time${planterNum}`)}
              >
                {timeOptions.map(option => <option key={option} value={option}>{option}</option>)}
              </select>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function PlanterTab() {
  const { settings, updateSetting, loading, error } = useSettings();
  const [activeSubTab, setActiveSubTab] = useState('Automatic');

  const getParsedSetting = (section, key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const planterOption = getSetting(settings, 'Planters', 'planterOption', 'Off');
  const enabled = planterOption !== 'Off';

  const handleEnableToggle = () => {
    if (enabled) {
      updateSetting('Planters', 'planterOption', 'Off');
    } else {
      updateSetting('Planters', 'planterOption', activeSubTab === 'Automatic' ? 'Planters +' : 'Manual');
    }
  };

  const handleTabChange = (tab) => {
    setActiveSubTab(tab);
    if (enabled) {
      updateSetting('Planters', 'planterOption', tab === 'Automatic' ? 'Planters +' : 'Manual');
    }
  };

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

  const handleSelectChange = (section, key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  const handlePresetChange = (e) => {
    const preset = e.target.value;
    updateSetting('Planters', 'nectaroption', preset);

    const presets = {
      Blue: {
        nectar: [
          { priority: 1, type: 'Comforting', min: '70' },
          { priority: 2, type: 'Motivating', min: '80' },
          { priority: 3, type: 'Satisfying', min: '80' },
          { priority: 4, type: 'Refreshing', min: '80' },
          { priority: 5, type: 'Invigorating', min: '40' }
        ],
        fields: ['cloverallowed']
      },
      Red: {
        nectar: [
          { priority: 1, type: 'Invigorating', min: '70' },
          { priority: 2, type: 'Refreshing', min: '80' },
          { priority: 3, type: 'Motivating', min: '80' },
          { priority: 4, type: 'Satisfying', min: '80' },
          { priority: 5, type: 'Comforting', min: '40' }
        ],
        fields: ['bambooallowed', 'pumpkinallowed']
      },
      White: {
        nectar: [
          { priority: 1, type: 'Satisfying', min: '70' },
          { priority: 2, type: 'Motivating', min: '80' },
          { priority: 3, type: 'Refreshing', min: '80' },
          { priority: 4, type: 'Comforting', min: '80' },
          { priority: 5, type: 'Invigorating', min: '40' }
        ],
        fields: ['cloverallowed', 'bambooallowed']
      }
    };

    const selectedPreset = presets[preset];
    if (selectedPreset) {
      selectedPreset.nectar.forEach(item => {
        updateSetting('Planters', `nectarpriority${item.priority}`, item.type);
        updateSetting('Planters', `nectarmin${item.priority}`, item.min);
      });

      const alwaysEnabledFields = [
        'dandelionallowed', 'sunflowerallowed', 'blueflowerallowed', 'spiderallowed',
        'strawberryallowed', 'pineappleallowed', 'cactusallowed', 'pinetreeallowed',
        'roseallowed', 'pepperallowed'
      ];

      const allFields = [
        'dandelionallowed', 'sunflowerallowed', 'mushroomallowed', 'blueflowerallowed',
        'cloverallowed', 'spiderallowed', 'strawberryallowed', 'bambooallowed',
        'pineappleallowed', 'stumpallowed', 'cactusallowed', 'pumpkinallowed',
        'pinetreeallowed', 'roseallowed', 'mountaintopallowed', 'pepperallowed',
        'coconutallowed'
      ];

      allFields.forEach(field => {
        const shouldEnable = alwaysEnabledFields.includes(field) || selectedPreset.fields.includes(field);
        updateSetting('Planters', field, boolToIni(shouldEnable));
      });
    }
  };

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-cyan-400">Planter Settings</h2>
      <div className="flex items-center mb-6">
        <span className="text-lg font-semibold mr-4">Enable Planters:</span>
        <label className="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            checked={enabled}
            onChange={handleEnableToggle}
            className="sr-only peer"
          />
          <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
        </label>
      </div>

      {enabled && (
        <>
          <div className="flex mb-4 border-b border-gray-600">
            <button
              onClick={() => handleTabChange('Automatic')}
              className={`px-6 py-2 text-lg font-medium rounded-t-lg transition-colors duration-200 ${activeSubTab === 'Automatic' ? 'bg-gray-700 text-blue-400' : 'hover:bg-gray-700 text-gray-300'}`}
            >
              Automatic
            </button>
            <button
              onClick={() => handleTabChange('Manual')}
              className={`px-6 py-2 text-lg font-medium rounded-t-lg transition-colors duration-200 ${activeSubTab === 'Manual' ? 'bg-gray-700 text-blue-400' : 'hover:bg-gray-700 text-gray-300'}`}
            >
              Manual
            </button>
          </div>

          <div className="bg-gray-800 p-6 rounded-lg shadow-xl">
            {activeSubTab === 'Automatic' && (
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="bg-gray-700 p-5 rounded-lg shadow-md">
                  <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-teal-400">Automatic Nectar & Harvest</h3>

                  <div className="mb-4 flex items-center justify-between">
                    <label htmlFor="nectarPreset" className="text-lg">Presets:</label>
                    <select
                      id="nectarPreset"
                      className="w-32 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                      value={getSetting(settings, 'Planters', 'nectaroption', 'Blue')}
                      onChange={handlePresetChange}
                    >
                      {["Blue", "Red", "White"].map(option => (
                        <option key={option} value={option}>{option}</option>
                      ))}
                    </select>
                  </div>

                  <h4 className="text-lg font-semibold mt-6 mb-3">Nectar Priority</h4>
                  <div className="grid grid-cols-2 gap-x-4 gap-y-2">
                    <div className="font-medium">Priority</div>
                    <div className="font-medium">Min %</div>
                    {[1, 2, 3, 4, 5].map(i => (
                      <React.Fragment key={i}>
                        <div className="flex items-center justify-between">
                          <label htmlFor={`nectarPriority${i}`} className="text-md">{i}:</label>
                          <select
                            id={`nectarPriority${i}`}
                            className="w-32 p-1 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                            value={getSetting(settings, 'Planters', `nectarpriority${i}`, 'None')}
                            onChange={handleSelectChange('Planters', `nectarpriority${i}`)}
                          >
                            {nectarTypes.map(option => <option key={option} value={option}>{option}</option>)}
                          </select>
                        </div>
                        <select
                          id={`nectarMin${i}`}
                          className="w-20 p-1 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                          value={getSetting(settings, 'Planters', `nectarmin${i}`, '70')}
                          onChange={handleSelectChange('Planters', `nectarmin${i}`)}
                        >
                          {percentageOptions.map(option => <option key={option} value={option}>{option}</option>)}
                        </select>
                      </React.Fragment>
                    ))}
                  </div>

                  <h4 className="text-lg font-semibold mt-6 mb-3">Harvest Options</h4>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <label htmlFor="harvestEvery" className="text-lg">Harvest every (hours):</label>
                      <input
                        id="harvestEvery"
                        type="text"
                        className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
                        value={getSetting(settings, 'Planters', 'harvestevery', '2')}
                        onChange={handleInputChange('Planters', 'harvestevery', 'number')}
                      />
                    </div>
                    <div className="flex items-center justify-between">
                      <label htmlFor="harvestFullGrown" className="text-lg">Full Grown:</label>
                      <label className="relative inline-flex items-center cursor-pointer">
                        <input
                          type="checkbox"
                          id="harvestFullGrown"
                          className="sr-only peer"
                          checked={getParsedSetting('Planters', 'harvestfullgrown', false)}
                          onChange={handleSwitchChange('Planters', 'harvestfullgrown')}
                        />
                        <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                      </label>
                    </div>
                    <div className="flex items-center justify-between">
                      <label htmlFor="harvestAuto" className="text-lg">Auto:</label>
                      <label className="relative inline-flex items-center cursor-pointer">
                        <input
                          type="checkbox"
                          id="harvestAuto"
                          className="sr-only peer"
                          checked={getParsedSetting('Planters', 'harvestauto', false)}
                          onChange={handleSwitchChange('Planters', 'harvestauto')}
                        />
                        <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                      </label>
                    </div>
                    <div className="flex items-center justify-between">
                      <label htmlFor="convertBagFullHarvest" className="text-lg">Convert Bag Full Harvest:</label>
                      <label className="relative inline-flex items-center cursor-pointer">
                        <input
                          type="checkbox"
                          id="convertBagFullHarvest"
                          className="sr-only peer"
                          checked={getParsedSetting('Planters', 'convertbagfull', false)}
                          onChange={handleSwitchChange('Planters', 'convertbagfull')}
                        />
                        <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                      </label>
                    </div>
                    <div className="flex items-center justify-between">
                      <label htmlFor="gatherPlanterLoot" className="text-lg">Gather Planter Loot:</label>
                      <label className="relative inline-flex items-center cursor-pointer">
                        <input
                          type="checkbox"
                          id="gatherPlanterLoot"
                          className="sr-only peer"
                          checked={getParsedSetting('Planters', 'gatherloot', false)}
                          onChange={handleSwitchChange('Planters', 'gatherloot')}
                        />
                        <div className="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                      </label>
                    </div>
                  </div>
                </div>

                {/* Allowed Fields & Planters */}
                <div className="bg-gray-700 p-5 rounded-lg shadow-md">
                  <h3 className="text-xl font-semibold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-orange-300 to-red-400">Allowed Fields & Planters</h3>

                  <div className="mb-6">
                    <h4 className="text-lg font-semibold mb-3">Allowed Fields</h4>
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      {[
                        { label: "Dandelion (COM)", key: "dandelionallowed" },
                        { label: "Sunflower (SAT)", key: "sunflowerallowed" },
                        { label: "Mushroom (MOT)", key: "mushroomallowed" },
                        { label: "Blue Flower (REF)", key: "blueflowerallowed" },
                        { label: "Clover (INV)", key: "cloverallowed" },
                        { label: "Spider (MOT)", key: "spiderallowed" },
                        { label: "Strawberry (REF)", key: "strawberryallowed" },
                        { label: "Bamboo (COM)", key: "bambooallowed" },
                        { label: "Pineapple (SAT)", key: "pineappleallowed" },
                        { label: "Stump (MOT)", key: "stumpallowed" },
                        { label: "Cactus (INV)", key: "cactusallowed" },
                        { label: "Pumpkin (SAT)", key: "pumpkinallowed" },
                        { label: "Pine Tree (COM)", key: "pinetreeallowed" },
                        { label: "Rose (MOT)", key: "roseallowed" },
                        { label: "Mountain Top (INV)", key: "mountaintopallowed" },
                        { label: "Pepper (INV)", key: "pepperallowed" },
                        { label: "Coconut (REF)", key: "coconutallowed" },
                      ].map(item => (
                        <div key={item.key} className="flex items-center justify-between">
                          <label htmlFor={item.key}>{item.label}:</label>
                          <input
                            type="checkbox"
                            id={item.key}
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Planters', item.key, false)}
                            onChange={handleCheckboxChange('Planters', item.key)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h4 className="text-lg font-semibold mb-3">Allowed Planters</h4>
                    <div className="flex items-center justify-between mb-3">
                      <label htmlFor="maxPlanters" className="text-lg">Max Planters:</label>
                      <select
                        id="maxPlanters"
                        className="w-20 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200 text-sm"
                        value={getSetting(settings, 'Planters', 'maxplanters', '3')}
                        onChange={handleSelectChange('Planters', 'maxplanters')}
                      >
                        {maxPlantersOptions.map(option => (
                          <option key={option} value={option}>{option}</option>
                        ))}
                      </select>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      {[
                        { label: "Plastic", key: "plasticallowed" },
                        { label: "Candy", key: "candyallowed" },
                        { label: "Blue Clay", key: "blueclayallowed" },
                        { label: "Red Clay", key: "redclayallowed" },
                        { label: "Tacky", key: "tackyallowed" },
                        { label: "Pesticide", key: "pesticideallowed" },
                        { label: "Heat-Treated", key: "heattreatedallowed" },
                        { label: "Hydroponic", key: "hydroponicallowed" },
                        { label: "Petal", key: "petalallowed" },
                        { label: "PoP", key: "popallowed" },
                        { label: "Paper", key: "paperallowed" },
                        { label: "Ticket", key: "ticketallowed" },
                      ].map(item => (
                        <div key={item.key} className="flex items-center justify-between">
                          <label htmlFor={item.key}>{item.label}:</label>
                          <input
                            type="checkbox"
                            id={item.key}
                            className="form-checkbox h-4 w-4 text-blue-600 bg-gray-600 border-gray-500 rounded focus:ring-blue-500"
                            checked={getParsedSetting('Planters', item.key, false)}
                            onChange={handleCheckboxChange('Planters', item.key)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeSubTab === 'Manual' && (
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <ManualPlanterCycle cycleNum={1} settings={settings} updateSetting={updateSetting} />
                <ManualPlanterCycle cycleNum={2} settings={settings} updateSetting={updateSetting} />
                <ManualPlanterCycle cycleNum={3} settings={settings} updateSetting={updateSetting} />
              </div>
            )}
          </div>
        </>
      )}
      <PlanterTimers />
    </>
  );
}

export default PlanterTab;
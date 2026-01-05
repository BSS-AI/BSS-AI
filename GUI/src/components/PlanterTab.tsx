import React, { useState, useEffect } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import Input from './UI/Input';
import Button from './UI/Button';
import FieldSelect, { getFieldIcon } from './UI/FieldSelect';
import IconSelect from './UI/IconSelect';
import TabSidebarLayout from './layout/TabSidebarLayout';

// --- Constants ---
const planterTypes = [
  "None", "Plastic", "Candy", "Red Clay", "Blue Clay", "Tacky",
  "Pesticide", "Heat-treated", "Hydroponic", "Petal", "PoP",
  "Paper", "Ticket"
];
const fieldOptions = [
  "Sunflower", "Dandelion", "Mushroom", "Blue Flower", "Clover", "Strawberry", "Spider",
  "Bamboo", "Pineapple", "Stump", "Cactus", "Pumpkin", "Pine Tree", "Rose",
  "Mountain Top", "Pepper", "Coconut"
];
const timeOptions = ["30 mins", "1 hour", "1h 30 mins", "2 hours", "2h 30 mins", "3 hours", "3h 30 mins", "4 hours", "4h 30 mins", "5 hours", "5h 30 mins", "6 hours"];
const nectarTypes = ["None", "Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"];
const percentageOptions = ["100", "90", "80", "70", "60", "50", "40", "30", "20", "10"];
const maxPlantersOptions = ["3", "2", "1"];

const nectarIcons: { [key: string]: string } = {
  "Comforting": "Comforting_Vial.webp",
  "Refreshing": "Refreshing_Vial.webp",
  "Satisfying": "Satisfying_Vial.webp",
  "Motivating": "Motivating_Vial.webp",
  "Invigorating": "Invigorating_Vial.webp"
};

const planterIcons: { [key: string]: string } = {
  "Plastic": "Plastic_Planter.webp",
  "Candy": "Candy_Planter.webp",
  "Red Clay": "Red_Clay_Planter.webp",
  "Blue Clay": "Blue_Clay_Planter.webp",
  "Tacky": "Tacky_Planter.webp",
  "Pesticide": "Pesticide_Planter.webp",
  "Heat-treated": "Heat-Treated_Planter.webp",
  "Heat-Treated": "Heat-Treated_Planter.webp",
  "Hydroponic": "Hydroponic_Planter.webp",
  "Petal": "Petal_Planter.webp",
  "PoP": "The_Planter_Of_Plenty.webp",
  "Paper": "Paper_Planter.webp",
  "Ticket": "Ticket_Planter.webp"
};

// --- Helper Functions ---
function formatUnixTime(unix: string) {
  if (!unix || unix === '0') return 'Not set';
  const date = new Date(parseInt(unix, 10) * 1000);
  if (isNaN(date.getTime())) return 'Invalid';
  return date.toLocaleString();
}

function getNectarIcon(nectar: string) {
  return nectarIcons[nectar] ? `/assets/${nectarIcons[nectar]}` : null;
}

function getPlanterIcon(planter: string) {
  return planterIcons[planter] ? `/assets/${planterIcons[planter]}` : null;
}

// --- Sub-Components ---

const ActivePlantersView = () => {
  const { settings: timerSettings, updateSetting, loading, error, readSettings } = useSettings({}, 'timers.ini');

  const handleReset = async (num: number) => {
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

  if (loading) return <div className="p-8 text-center text-text-muted">Loading active planters...</div>;

  const planterKeys = [1, 2, 3].map(num => ({
    id: num,
    name: `PlanterName${num}`,
    field: `PlanterField${num}`,
    nectar: `PlanterNectar${num}`,
    harvestTime: `PlanterHarvestTime${num}`,
  }));

  return (
    <Card title="Active Planters" className="animate-fade-in">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-glass-border text-xs font-bold text-text-muted uppercase tracking-wider">
              <th className="p-4">Slot</th>
              <th className="p-4">Planter</th>
              <th className="p-4">Field</th>
              <th className="p-4">Harvest Time</th>
              <th className="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-glass-border">
            {planterKeys.map((keys) => {
              const planterName = timerSettings.Planters?.[keys.name] || 'None';
              const fieldName = timerSettings.Planters?.[keys.field] || 'None';
              const isActive = planterName !== 'None';

              return (
                <tr key={keys.id} className="group hover:bg-background-tertiary transition-colors">
                  <td className="p-4">
                    <div className="flex items-center gap-3">
                      <div className={`w-2 h-2 rounded-full ${isActive ? 'bg-status-success animate-pulse' : 'bg-white/20'}`} />
                      <span className="font-bold text-white">#{keys.id}</span>
                    </div>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      {getPlanterIcon(planterName) && <img src={getPlanterIcon(planterName)!} alt="" className="w-5 h-5 object-contain" />}
                      <span className={`font-medium ${isActive ? 'text-white' : 'text-text-muted'}`}>{planterName}</span>
                    </div>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      {getFieldIcon(fieldName) && <img src={getFieldIcon(fieldName)!} alt="" className="w-5 h-5 object-contain" />}
                      <span className={`font-medium ${isActive ? 'text-white' : 'text-text-muted'}`}>{fieldName}</span>
                    </div>
                  </td>
                  <td className="p-4">
                    <span className="text-accent-tertiary font-medium">{formatUnixTime(timerSettings.Planters?.[keys.harvestTime])}</span>
                  </td>
                  <td className="p-4 text-right">
                    <Button
                      variant="danger"
                      size="sm"
                      onClick={() => handleReset(keys.id)}
                      className="opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      Reset
                    </Button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </Card>
  );
};

const NectarPriorityView = ({ settings, updateSetting, handleSelectChange, handlePresetChange }: any) => {
  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center gap-4 p-4 rounded-lg bg-accent-primary/5 border border-accent-primary/10">
        <div className="flex-1">
          <h4 className="text-sm font-bold text-white mb-1">Quick Preset</h4>
          <p className="text-xs text-text-secondary">Automatically configure priorities and fields</p>
        </div>
        <div className="w-48">
          <Select
            options={["Blue", "Red", "White"]}
            value={getSetting(settings, 'Planters', 'nectaroption', 'Blue')}
            onChange={handlePresetChange}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-2">
        <div className="grid grid-cols-[40px_1fr_100px] gap-4 px-4 py-2 text-xs font-bold text-text-muted uppercase tracking-wider">
          <div className="text-center">#</div>
          <div>Nectar Type</div>
          <div>Min %</div>
        </div>
        {[1, 2, 3, 4, 5].map(i => {
          const currentNectar = getSetting(settings, 'Planters', `nectarpriority${i}`, 'None');
          return (
            <div key={i} className="grid grid-cols-[40px_1fr_100px] gap-4 items-center p-2 rounded-lg hover:bg-background-tertiary transition-colors">
              <div className="flex items-center justify-center w-8 h-8 rounded-full bg-background-secondary text-sm font-bold text-accent-primary">
                {i}
              </div>
              <IconSelect
                options={nectarTypes}
                value={currentNectar}
                onChange={(val) => updateSetting('Planters', `nectarpriority${i}`, val)}
                getIcon={getNectarIcon}
                className="!mt-0"
              />
              <Select
                options={percentageOptions}
                value={getSetting(settings, 'Planters', `nectarmin${i}`, '70')}
                onChange={handleSelectChange('Planters', `nectarmin${i}`)}
                className="!mt-0"
              />
            </div>
          );
        })}
      </div>
    </div>
  );
};

const HarvestRulesView = ({ settings, getParsedSetting, handleInputChange, handleSwitchChange, handleSelectChange }: any) => {
  return (
    <div className="space-y-6 animate-fade-in">
      <Card title="Harvest Rules">
        <div className="space-y-4">
          <Input
            label="Harvest Interval (hours)"
            type="text"
            value={getSetting(settings, 'Planters', 'harvestevery', '2')}
            onChange={handleInputChange('Planters', 'harvestevery', 'number')}
          />
          <div className="space-y-2">
            {[
              { label: "Harvest when Full Grown", key: "harvestfullgrown" },
              { label: "Smart Auto Harvest", key: "harvestauto" },
              { label: "Convert when Bag Full", key: "convertbagfull" },
              { label: "Gather Loot after Harvest", key: "gatherloot" },
            ].map(opt => (
              <div key={opt.key} className="flex items-center justify-between p-3 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-colors">
                <span className="text-sm font-medium text-text-primary">{opt.label}</span>
                <Switch
                  checked={getParsedSetting('Planters', opt.key, false)}
                  onChange={handleSwitchChange('Planters', opt.key)}
                />
              </div>
            ))}
          </div>
        </div>
      </Card>

      <Card title="Limits">
        <div className="space-y-4">
          <Select
            label="Max Concurrent Planters"
            options={maxPlantersOptions}
            value={getSetting(settings, 'Planters', 'maxplanters', '3')}
            onChange={handleSelectChange('Planters', 'maxplanters')}
          />
          <div className="p-4 rounded-lg bg-status-info/10 border border-status-info/20">
            <p className="text-xs text-status-info leading-relaxed">
              <span className="font-bold">Note:</span> Limiting planters can help save nectar for specific boosts or quests.
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
};

const AutoFieldsView = ({ settings, getParsedSetting, handleCheckboxChange }: any) => {
  const fields = [
    { label: "Dandelion", key: "dandelionallowed" },
    { label: "Sunflower", key: "sunflowerallowed" },
    { label: "Mushroom", key: "mushroomallowed" },
    { label: "Blue Flower", key: "blueflowerallowed" },
    { label: "Clover", key: "cloverallowed" },
    { label: "Spider", key: "spiderallowed" },
    { label: "Strawberry", key: "strawberryallowed" },
    { label: "Bamboo", key: "bambooallowed" },
    { label: "Pineapple", key: "pineappleallowed" },
    { label: "Stump", key: "stumpallowed" },
    { label: "Cactus", key: "cactusallowed" },
    { label: "Pumpkin", key: "pumpkinallowed" },
    { label: "Pine Tree", key: "pinetreeallowed" },
    { label: "Rose", key: "roseallowed" },
    { label: "Mountain Top", key: "mountaintopallowed" },
    { label: "Pepper", key: "pepperallowed" },
    { label: "Coconut", key: "coconutallowed" },
  ];

  return (
    <div className="space-y-6 animate-fade-in">
      <Card title="Allowed Fields">
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
          {fields.map(item => (
            <label key={item.key} className="flex items-center space-x-3 cursor-pointer group p-3 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-all duration-200 border border-transparent hover:border-glass-border">
              <div className="relative flex items-center">
                <input
                  type="checkbox"
                  className="peer sr-only"
                  checked={getParsedSetting('Planters', item.key, false)}
                  onChange={(e) => handleCheckboxChange('Planters', item.key)(e.target.checked)}
                />
                <div className="w-5 h-5 border-2 border-text-primary/20 rounded bg-transparent peer-checked:bg-accent-primary peer-checked:border-accent-primary transition-all duration-200"></div>
                <svg className="absolute w-3 h-3 text-white hidden peer-checked:block left-1 top-1 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div className="flex items-center gap-2">
                {getFieldIcon(item.label) && (
                  <img src={getFieldIcon(item.label)!} alt="" className="w-6 h-6 object-contain" />
                )}
                <span className="text-sm font-medium text-text-primary group-hover:text-text-primary transition-colors">{item.label}</span>
              </div>
            </label>
          ))}
        </div>
      </Card>
    </div>
  );
};

const AutoPlantersView = ({ settings, getParsedSetting, handleCheckboxChange }: any) => {
  const planters = [
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
    { label: "Ticket", key: "ticketallowed" }
  ];

  return (
    <div className="space-y-6 animate-fade-in">
      <Card title="Allowed Planters">
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
          {planters.map(item => (
            <label key={item.key} className="flex items-center space-x-3 cursor-pointer group p-3 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-all duration-200 border border-transparent hover:border-glass-border">
              <div className="relative flex items-center">
                <input
                  type="checkbox"
                  className="peer sr-only"
                  checked={getParsedSetting('Planters', item.key, false)}
                  onChange={(e) => handleCheckboxChange('Planters', item.key)(e.target.checked)}
                />
                <div className="w-5 h-5 border-2 border-text-primary/20 rounded bg-transparent peer-checked:bg-accent-primary peer-checked:border-accent-primary transition-all duration-200"></div>
                <svg className="absolute w-3 h-3 text-white hidden peer-checked:block left-1 top-1 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div className="flex items-center gap-2">
                {getPlanterIcon(item.label) && (
                  <img src={getPlanterIcon(item.label)!} alt="" className="w-6 h-6 object-contain" />
                )}
                <span className="text-sm font-medium text-text-primary group-hover:text-text-primary transition-colors">{item.label}</span>
              </div>
            </label>
          ))}
        </div>
      </Card>
    </div>
  );
};

const ManualCycleView = ({ cycleNum, settings, handleSelectChange, updateSetting }: any) => {
  return (
    <Card title={`Cycle ${cycleNum} Configuration`} className="animate-fade-in">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-glass-border text-xs font-bold text-text-muted uppercase tracking-wider">
              <th className="p-4 w-16 text-center">Slot</th>
              <th className="p-4">Planter Type</th>
              <th className="p-4">Target Field</th>
              <th className="p-4">Duration</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-glass-border">
            {[1, 2, 3].map(planterNum => (
              <tr key={planterNum} className="hover:bg-background-tertiary transition-colors">
                <td className="p-4 text-center">
                  <div className="w-8 h-8 rounded-full bg-background-secondary flex items-center justify-center text-sm font-bold text-accent-primary mx-auto">
                    {planterNum}
                  </div>
                </td>
                <td className="p-4">
                  <IconSelect
                    options={planterTypes}
                    value={getSetting(settings, 'Planters', `cycle${cycleNum}planter${planterNum}`, 'None')}
                    onChange={(val) => updateSetting('Planters', `cycle${cycleNum}planter${planterNum}`, val)}
                    getIcon={getPlanterIcon}
                    className="!mt-0 w-full"
                  />
                </td>
                <td className="p-4">
                  <FieldSelect
                    options={fieldOptions}
                    value={getSetting(settings, 'Planters', `cycle${cycleNum}field${planterNum}`, 'Sunflower')}
                    onChange={(value) => updateSetting('Planters', `cycle${cycleNum}field${planterNum}`, value)}
                    className="w-full"
                  />
                </td>
                <td className="p-4">
                  <Select
                    options={timeOptions}
                    value={getSetting(settings, 'Planters', `cycle${cycleNum}time${planterNum}`, '30 mins')}
                    onChange={handleSelectChange('Planters', `cycle${cycleNum}time${planterNum}`)}
                    className="!mt-0 w-full"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};

const OffView = () => (
  <div className="flex flex-col items-center justify-center h-full text-center p-8 animate-fade-in">
    <div className="flex items-center gap-4 mb-6">
      <img src="/assets/Comforting_Vial.webp" alt="" className="w-12 h-12 opacity-50 animate-bounce" style={{ animationDelay: '0s' }} />
      <img src="/assets/Motivating_Vial.webp" alt="" className="w-16 h-16 opacity-75 animate-bounce" style={{ animationDelay: '0.2s' }} />
      <img src="/assets/Satisfying_Vial.webp" alt="" className="w-12 h-12 opacity-50 animate-bounce" style={{ animationDelay: '0.4s' }} />
    </div>
    <h3 className="text-xl font-bold text-text-primary mb-2">You don't have planters enabled :(</h3>
    <p className="text-text-secondary max-w-md">
      Enable Automatic or Manual mode in the sidebar to start configuring your planter strategies.
    </p>
  </div>
);

// Main Component
function PlanterTab() {
  const { settings, updateSetting, loading, error } = useSettings();
  const [planterMode, setPlanterMode] = useState('off');

  useEffect(() => {
    const mode = getSetting(settings, 'Planters', 'planteroption', 'Off');
    setPlanterMode(mode.toLowerCase() === 'planters +' ? 'automatic' : mode.toLowerCase());
  }, [settings]);

  const getParsedSetting = (section: string, key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  const handleModeChange = (mode: string) => {
    setPlanterMode(mode);
    const iniValue = mode === 'automatic' ? 'Planters +' : mode === 'manual' ? 'Manual' : 'Off';
    updateSetting('Planters', 'planteroption', iniValue);
  };

  const handleSwitchChange = (section: string, key: string) => (checked: boolean) => {
    updateSetting(section, key, boolToIni(checked));
  };

  const handleCheckboxChange = (section: string, key: string) => (checked: boolean) => {
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

  const handlePresetChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
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

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

  // Define Icons
  const Icons = {
    General: <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19.428 15.428a2 2 0 00-1.022-.547l-2.384-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" /></svg>,
    Rules: <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>,
    Fields: <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>,
    Active: <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>,
    Cycle: <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>
  };

  const getSidebarItems = () => {
    const activePlantersItem = {
      id: 'active',
      label: 'Active Planters', content: <ActivePlantersView />
    };

    if (planterMode === 'automatic') {
      return [
        {
          id: 'general',
          label: 'General', content: <NectarPriorityView settings={settings} updateSetting={updateSetting} handleSelectChange={handleSelectChange} handlePresetChange={handlePresetChange} />
        },
        {
          id: 'rules',
          label: 'Harvest Rules', content: <HarvestRulesView settings={settings} getParsedSetting={getParsedSetting} handleInputChange={handleInputChange} handleSwitchChange={handleSwitchChange} handleSelectChange={handleSelectChange} />
        },
        {
          id: 'fields',
          label: 'Fields', content: <AutoFieldsView settings={settings} updateSetting={updateSetting} getParsedSetting={getParsedSetting} handleCheckboxChange={handleCheckboxChange} />
        },
        {
          id: 'planters',
          label: 'Planters', content: <AutoPlantersView settings={settings} updateSetting={updateSetting} getParsedSetting={getParsedSetting} handleCheckboxChange={handleCheckboxChange} />
        },
        activePlantersItem
      ];
    } else if (planterMode === 'manual') {
      return [
        {
          id: 'cycle1',
          label: 'Cycle 1', content: <ManualCycleView cycleNum={1} settings={settings} handleSelectChange={handleSelectChange} updateSetting={updateSetting} />
        },
        {
          id: 'cycle2',
          label: 'Cycle 2', content: <ManualCycleView cycleNum={2} settings={settings} handleSelectChange={handleSelectChange} updateSetting={updateSetting} />
        },
        {
          id: 'cycle3',
          label: 'Cycle 3', content: <ManualCycleView cycleNum={3} settings={settings} handleSelectChange={handleSelectChange} updateSetting={updateSetting} />
        },
        activePlantersItem
      ];
    } else {
      return [
        {
          id: 'overview',
          label: 'Overview', content: <OffView />
        },
        activePlantersItem
      ];
    }
  };
  const sidebarHeader = (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-bold text-text-muted uppercase tracking-wider px-2 mb-1">Mode</label>
      {[
        { id: 'off', label: 'Off' },
        { id: 'automatic', label: 'Automatic' },
        { id: 'manual', label: 'Manual' },
      ].map(mode => (
        <button
          key={mode.id}
          onClick={() => handleModeChange(mode.id)}
          className={`w-full text-left px-3 py-2 rounded-lg text-xs font-bold transition-all duration-200 border ${planterMode === mode.id
            ? 'bg-accent-primary text-white border-accent-primary shadow-sm'
            : 'bg-background-secondary text-text-secondary border-transparent hover:bg-background-tertiary hover:text-text-primary'
            }`}
        >
          {mode.label}
        </button>
      ))}
    </div>
  );

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-hidden">
        <TabSidebarLayout items={getSidebarItems()} sidebarHeader={sidebarHeader} />
      </div>
    </div>
  );
}

export default PlanterTab;

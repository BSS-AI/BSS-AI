import React from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import IconSelect from './UI/IconSelect';
import Input from './UI/Input';
import TabSidebarLayout from './layout/TabSidebarLayout';

const nectarIcons: { [key: string]: string } = {
  "Comforting": "Comforting_Vial.webp",
  "Refreshing": "Refreshing_Vial.webp",
  "Satisfying": "Satisfying_Vial.webp",
  "Motivating": "Motivating_Vial.webp",
  "Invigorating": "Invigorating_Vial.webp"
};

const basicIcons: { [key: string]: string } = {
  "wealthclock": "Ticket.webp",
  "antpass": "antpass_free_dispenser.webp",
  "honeystorm": "honeystorm.webp",
  "gluedispenser": "Glue_Dispenser.webp"
};

const eggIcons: { [key: string]: string } = {
  "Basic": "Basic_Egg.webp",
  "Silver": "Silver_Egg.webp",
  "Gold": "Gold_Egg.webp",
  "Diamond": "Diamond_Egg.webp",
  "Mythic": "Mythic_Egg.webp"
};

const blenderIcons: { [key: string]: string } = {
  "Red Extract": "Red_Extract.webp",
  "Blue Extract": "Blue_Extract.webp",
  "Enzymes": "Enzymes.webp",
  "Oil": "Oil.webp",
  "Glue": "Glue.webp",
  "Tropical Drink": "Tropical_Drink.webp",
  "Gumdrops": "Gumdrops.webp",
  "Moon Charms": "Moon_Charms.webp",
  "Glitter": "Glitter.webp",
  "Star Jelly": "Star_Jelly.webp",
  "Purple Potion": "Purple_Potion.webp",
  "Soft Wax": "Soft_Wax.webp",
  "Hard Wax": "Hard_Wax.webp",
  "Swirled Wax": "Swirled_Wax.webp",
  "Caustic Wax": "Caustic_Wax.webp",
  "Field Dice": "Field_Dice.webp",
  "Smooth Dice": "Smooth_Dice.webp",
  "Loaded Dice": "Loaded_Dice.webp",
  "Super Smoothie": "Super_Smoothie.webp",
  "Turpentine": "Turpentine.webp"
};

const stickerStackIcons: { [key: string]: string } = {
  "Tickets": "Ticket.webp",
  "Stickers": "Smile_sticker_icon.webp",
  "Stickers + Tickets": "Smile_sticker_icon.webp,Ticket.webp"
};

const beesmasIcons: { [key: string]: string } = {
  "stockings": "Stockings.webp",
  "honeywreath": "Honey_Wreath.webp",
  "feast": "Feast.webp",
  "rbpdelevel": "Robo_Party.webp",
  "gingerbread": "Gingerbread.webp",
  "snowmachine": "Snow_Machine.webp",
  "candles": "Candles.webp",
  "samovar": "Samovar.webp",
  "lidart": "Lid_Art.webp",
  "gummybeacon": "Gummy_Beacon.webp"
};

function CollectTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

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

  const getParsedSetting = (section: string, key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  function getNectarIcon(nectar: string) {
    return nectarIcons[nectar] ? `/assets/${nectarIcons[nectar]}` : null;
  }

  function getBasicIcon(key: string) {
    return basicIcons[key] ? `/assets/${basicIcons[key]}` : null;
  }

  function getEggIcon(egg: string) {
    return eggIcons[egg] ? `/assets/${eggIcons[egg]}` : null;
  }

  function getBlenderIcon(item: string) {
    return blenderIcons[item] ? `/assets/${blenderIcons[item]}` : null;
  }

  function getStickerStackIcon(item: string) {
    if (!stickerStackIcons[item]) return null;
    return stickerStackIcons[item].split(',').map(icon => `/assets/${icon}`).join(',');
  }

  function getBeesmasIcon(key: string) {
    return beesmasIcons[key] ? `/assets/${beesmasIcons[key]}` : null;
  }

  const nectarTypes = ["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"];
  const eggTypes = ["None", "Basic", "Silver", "Gold", "Diamond", "Mythic"];
  const stickerStackItems = ["Tickets", "Stickers", "Stickers + Tickets"];
  const blenderItems = [
    "None", "Red Extract", "Blue Extract", "Enzymes", "Oil", "Glue", "Tropical Drink",
    "Gumdrops", "Moon Charms", "Glitter", "Star Jelly", "Purple Potion", "Soft Wax",
    "Hard Wax", "Swirled Wax", "Caustic Wax", "Field Dice", "Smooth Dice", "Loaded Dice",
    "Super Smoothie", "Turpentine"
  ];

  const blenderEnabled = getParsedSetting('Collect', '`blendercheck', false);
  const nectarPotEnabled = getParsedSetting('Collect', 'nectarpot', false);
  const nectarCondenserEnabled = getParsedSetting('Collect', 'nectarconsender', false);
  const stickerPrinterEnabled = getParsedSetting('Collect', 'stickerprinter', false);
  const stickerStackEnabled = getParsedSetting('Collect', 'stickerstack', false);
  const stickerStackItem = getSetting(settings, 'Collect', 'stickerstackitem', 'Tickets');
  const stickerStackTimerDetect = getParsedSetting('Collect', 'stickerstacktimerdetect', false);

  const selectedNectarPot = getSetting(settings, 'Collect', 'nectarpotnectar', 'Comforting');
  const selectedNectarCondenser = getSetting(settings, 'Collect', 'nectarconsendernectar', 'Comforting');

  const BasicContent = (
    <Card title="Basic Collectables" className="h-full">
      <div className="space-y-4">
        {[
          { label: "Wealth Clock", key: "wealthclock" },
          { label: "Ant Pass Dispenser", key: "antpass" },
          { label: "Honeystorm", key: "honeystorm" },
          { label: "Glue Dispenser", key: "gluedispenser" },
        ].map(item => (
          <div key={item.key} className="flex items-center justify-between p-3 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-colors">
            <div className="flex items-center gap-3">
              {getBasicIcon(item.key) && (
                <img src={getBasicIcon(item.key)!} alt={item.label} className="w-8 h-8 object-contain" />
              )}
              <span className="text-sm font-medium text-text-primary">{item.label}</span>
            </div>
            <Switch
              checked={getParsedSetting('Collect', item.key, false)}
              onChange={handleSwitchChange('Collect', item.key)}
            />
          </div>
        ))}
      </div>
    </Card>
  );

  const NectarContent = (
    <Card title="Nectar Systems" className="h-full">
      <div className="space-y-6">
        <div className="p-4 rounded-lg bg-background-secondary border border-glass-border">
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-medium text-text-primary">Nectar Pot</span>
            <Switch
              checked={nectarPotEnabled}
              onChange={handleSwitchChange('Collect', 'nectarpot')}
            />
          </div>
          <IconSelect
            label="Nectar to Store"
            options={nectarTypes}
            value={selectedNectarPot}
            onChange={(value) => updateSetting('Collect', 'nectarpotnectar', value)}
            getIcon={getNectarIcon}
            disabled={!nectarPotEnabled}
            className="w-full"
          />
        </div>

        <div className="p-4 rounded-lg bg-background-secondary border border-glass-border">
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-medium text-text-primary">Nectar Condenser</span>
            <Switch
              checked={nectarCondenserEnabled}
              onChange={handleSwitchChange('Collect', 'nectarconsender')}
            />
          </div>
          <IconSelect
            label="Condense Type"
            options={nectarTypes}
            value={selectedNectarCondenser}
            onChange={(value) => updateSetting('Collect', 'nectarconsendernectar', value)}
            getIcon={getNectarIcon}
            disabled={!nectarCondenserEnabled}
            className="w-full"
          />
        </div>
      </div>
    </Card>
  );

  const BlenderContent = (
    <Card
      title="Blender"
      className="w-full"
      action={
        <Switch
          checked={blenderEnabled}
          onChange={handleSwitchChange('Collect', 'blendercheck')}
        />
      }
    >
      <div className={`transition-all duration-200 ${!blenderEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-glass-border text-xs font-bold text-text-muted uppercase tracking-wider">
                <th className="p-4 w-16 text-center">Slot</th>
                <th className="p-4">Item</th>
                <th className="p-4 w-24">Amount</th>
                <th className="p-4 w-32">Repeat</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-glass-border">
              {[1, 2, 3].map(i => (
                <tr key={i} className="hover:bg-background-tertiary transition-colors">
                  <td className="p-4 text-center">
                    <div className="w-8 h-8 rounded-full bg-background-secondary flex items-center justify-center text-sm font-bold text-accent-primary mx-auto">
                      {i}
                    </div>
                  </td>
                  <td className="p-4">
                    <IconSelect
                      options={blenderItems}
                      value={getSetting(settings, 'Collect', `blenderslot${i}item`, 'None')}
                      onChange={(val) => updateSetting('Collect', `blenderslot${i}item`, val)}
                      getIcon={getBlenderIcon}
                      disabled={!blenderEnabled}
                      className="!mt-0 w-full"
                    />
                  </td>
                  <td className="p-4">
                    <Input
                      type="text"
                      value={getSetting(settings, 'Collect', `blenderslot${i}amount`, '0')}
                      onChange={handleInputChange('Collect', `blenderslot${i}amount`, 'number')}
                      disabled={!blenderEnabled}
                      className="!mt-0"
                    />
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-3">
                      <label className={`relative flex items-center cursor-pointer ${!blenderEnabled ? 'opacity-50 cursor-not-allowed' : ''}`}>
                        <input
                          type="checkbox"
                          className="peer sr-only"
                          checked={getSetting(settings, 'Collect', `blenderslot${i}repeat`, 'Infinite') === 'Infinite'}
                          onChange={(e) => updateSetting('Collect', `blenderslot${i}repeat`, e.target.checked ? 'Infinite' : '1')}
                          disabled={!blenderEnabled}
                        />
                        <div className="w-5 h-5 border-2 border-text-primary/20 rounded bg-transparent peer-checked:bg-accent-primary peer-checked:border-accent-primary transition-all duration-200"></div>
                        <svg className="absolute w-3.5 h-3.5 text-white hidden peer-checked:block left-[3px] top-[3px] pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                        <span className="ml-2 text-sm text-text-secondary select-none">Inf</span>
                      </label>
                      {getSetting(settings, 'Collect', `blenderslot${i}repeat`, 'Infinite') !== 'Infinite' && (
                        <Input
                          type="text"
                          value={getSetting(settings, 'Collect', `blenderslot${i}repeat`, '1')}
                          onChange={(e) => {
                            let val = e.target.value.replace(/[^0-9]/g, '');
                            if (val && parseInt(val) > 999) val = '999';
                            if (val === 'Infinite') val = '1';
                            updateSetting('Collect', `blenderslot${i}repeat`, val);
                          }}
                          disabled={!blenderEnabled}
                          className="!mt-0 w-20"
                          placeholder="1-999"
                        />
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Card>
  );

  const StickerContent = (
    <div className="space-y-6">
      <Card title="Sticker Printer">
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-text-primary">Enable Printer</span>
            <Switch
              checked={stickerPrinterEnabled}
              onChange={handleSwitchChange('Collect', 'stickerprinter')}
            />
          </div>
          <div className={`transition-opacity duration-200 ${!stickerPrinterEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
            <IconSelect
              label="Egg Type"
              options={eggTypes}
              value={getSetting(settings, 'Collect', 'stickerprinteregg', 'None')}
              onChange={(value) => updateSetting('Collect', 'stickerprinteregg', value)}
              getIcon={getEggIcon}
              disabled={!stickerPrinterEnabled}
              className="w-full"
            />
          </div>
        </div>
      </Card>

      <Card title="Sticker Stacker">
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-text-primary">Enable Stacker</span>
            <Switch
              checked={stickerStackEnabled}
              onChange={handleSwitchChange('Collect', 'stickerstack')}
            />
          </div>

          <div className={`space-y-4 transition-opacity duration-200 ${!stickerStackEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
            <IconSelect
              label="Item to Stack"
              options={stickerStackItems}
              value={stickerStackItem}
              onChange={(val) => updateSetting('Collect', 'stickerstackitem', val)}
              getIcon={getStickerStackIcon}
            />

            {(stickerStackItem === 'Stickers' || stickerStackItem === 'Stickers + Tickets') && (
              <div className="p-3 rounded bg-status-warning/10 border border-status-warning/20 flex items-start gap-3">
                <span className="text-lg">⚠️</span>
                <p className="text-xs text-status-warning leading-relaxed">
                  Consider trading all of your valuable stickers to an alternative account to ensure you do not lose them.
                </p>
              </div>
            )}

            <div className="p-4 rounded-lg bg-background-secondary border border-glass-border space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-sm text-text-primary">Timer Detect</span>
                <Switch
                  checked={stickerStackTimerDetect}
                  onChange={handleCheckboxChange('Collect', 'stickerstacktimerdetect')}
                />
              </div>

              <Input
                label="Timer (mins)"
                type="text"
                value={getSetting(settings, 'Collect', 'stickerstacktimer', '0')}
                onChange={handleInputChange('Collect', 'stickerstacktimer', 'number')}
                disabled={stickerStackTimerDetect}
                className={stickerStackTimerDetect ? 'opacity-50' : ''}
              />

              <div>
                <label className="block text-xs font-medium text-text-secondary mb-2 uppercase tracking-wider">Stack Options</label>
                <div className="flex gap-4">
                  {[
                    { key: 'stickerstackhives', label: 'Hives' },
                    { key: 'stickerstackcubs', label: 'Cubs' },
                    { key: 'stickerstackvouches', label: 'Vouches' },
                  ].map(opt => (
                    <label key={opt.key} className="flex items-center space-x-2 cursor-pointer group">
                      <div className="relative flex items-center">
                        <input
                          type="checkbox"
                          className="peer sr-only"
                          checked={getParsedSetting('Collect', opt.key, false)}
                          onChange={(e) => handleCheckboxChange('Collect', opt.key)(e.target.checked)}
                        />
                        <div className="w-4 h-4 border-2 border-text-primary/20 rounded bg-transparent peer-checked:bg-accent-primary peer-checked:border-accent-primary transition-all duration-200"></div>
                        <svg className="absolute w-3 h-3 text-white hidden peer-checked:block left-0.5 top-0.5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                      <span className="text-sm text-text-primary group-hover:text-text-primary transition-colors">{opt.label}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </Card>
    </div>
  );

  const BeesmasContent = (
    <Card title="Beesmas Collectables" className="h-full">
      <div className="space-y-4">
        {[
          { label: "Stockings", key: "stockings" },
          { label: "Honey Wreath", key: "honeywreath" },
          { label: "Feast", key: "feast" },
          { label: "Robo Party De-level", key: "rbpdelevel" },
          { label: "Gingerbread", key: "gingerbread" },
          { label: "Snow Machine", key: "snowmachine" },
          { label: "Candles", key: "candles" },
          { label: "Samovar", key: "samovar" },
          { label: "Lid Art", key: "lidart" },
          { label: "Gummy Beacon", key: "gummybeacon" },
        ].map(item => (
          <div key={item.key} className="flex items-center justify-between p-3 rounded-lg bg-background-secondary hover:bg-background-tertiary transition-colors">
            <div className="flex items-center gap-3">
              {getBeesmasIcon(item.key) && (
                <img src={getBeesmasIcon(item.key)!} alt={item.label} className="w-8 h-8 object-contain" />
              )}
              <span className="text-sm font-medium text-text-primary">{item.label}</span>
            </div>
            <Switch
              checked={getParsedSetting('Collect', item.key, false)}
              onChange={handleSwitchChange('Collect', item.key)}
            />
          </div>
        ))}
      </div>
    </Card>
  );

  const sidebarItems = [
    { id: 'basic', label: 'Dispensers', content: BasicContent },
    { id: 'nectar', label: 'Nectar', content: NectarContent },
    { id: 'blender', label: 'Blender', content: BlenderContent },
    { id: 'stickers', label: 'Stickers', content: StickerContent },
    { id: 'beesmas', label: 'Beesmas', content: BeesmasContent },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default CollectTab;
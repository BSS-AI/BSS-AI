import React, { useState, useEffect, useRef } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';
import Card from './UI/Card';
import Switch from './UI/Switch';
import Select from './UI/Select';
import Input from './UI/Input';
import Button from './UI/Button';
import TabSidebarLayout from './layout/TabSidebarLayout';
import FieldSelect from './UI/FieldSelect';

const fieldOptions = [
  "Sunflower", "Dandelion", "Mushroom", "Blue Flower", "Clover", "Strawberry", "Spider",
  "Bamboo", "Pineapple", "Stump", "Cactus", "Pumpkin", "Pine Tree", "Rose",
  "Mountain Top", "Pepper", "Coconut"
];
const patternOptions = [
  "CornerXSnake", "Fork", "Lines", "Slimline", "Snake", "Squares", "SuperCat", "XSnake",
  "Bowl", "PineDriftRedux"
];
const rotateOptions = ["None", "Left", "Right"];
const toHiveOptions = ["Walk", "Reset"];
const patternLengthOptions = ["XS", "S", "M", "L", "XL"];
const sprinklerLocationOptions = ["Center", "Upper Left", "Upper", "Upper Right", "Right", "Lower Right", "Lower", "Lower Left", "Left"];
const communicationMethodOptions = ["SOCKET", "COM"];

const Tooltip = ({ text, children }: { text: string, children: React.ReactNode }) => {
  const [show, setShow] = useState(false);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const showTooltip = () => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    setShow(true);
  };

  const hideTooltip = () => {
    timeoutRef.current = setTimeout(() => {
      setShow(false);
    }, 100);
  };

  useEffect(() => {
    return () => {
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, []);

  return (
    <span
      className="relative inline-flex items-center justify-center ml-1"
      onMouseEnter={showTooltip}
      onMouseLeave={hideTooltip}
    >
      {children}
      {show && (
        <div className="absolute bottom-full left-1/2 z-50 mb-2 -translate-x-1/2 w-64 p-3 text-sm font-normal text-white bg-gray-900/95 border border-white/10 rounded-lg shadow-xl backdrop-blur-md animate-fade-in pointer-events-none">
          {text}
          <div className="absolute left-1/2 top-full -translate-x-1/2 border-4 border-solid border-x-transparent border-t-gray-900/95" />
        </div>
      )}
    </span>
  );
};

function AIGenericSettings({ settings, updateSetting }: { settings: any, updateSetting: any }) {
  const section = 'AIGather';

  const handleInputChange = (key: string, type = 'text') => (e: React.ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }
    updateSetting(section, key, value);
  };

  const handleSelectChange = (key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
    updateSetting(section, key, e.target.value);
  };

  const openTokenPriority = async () => {
    try {
      const { WebviewWindow } = await import('@tauri-apps/api/webviewWindow');
      const webview = new WebviewWindow('tokenPriority', {
        url: 'token-priority.html',
        title: 'Token Priority Editor',
        width: 600,
        height: 700,
        minWidth: 600,
        maxWidth: 600,
        minHeight: 700,
        maxHeight: 700,
        decorations: false,
        resizable: false,
        center: true,
      });
      webview.once('tauri://created', () => {
        console.log('Token priority window created');
      });
      webview.once('tauri://error', (e) => {
        console.error('Error creating token priority window:', e);
      });
    } catch (err) {
      console.error("Failed to import WebviewWindow or open window", err);
    }
  };

  return (
    <Card title="AI Global Settings" className="mb-8">
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Select
            label={
              <>
                Communication Method
                <Tooltip text="How Python communicates with AutoHotkey. SOCKET is recommended.">
                  <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                </Tooltip>
              </>
            }
            options={communicationMethodOptions}
            value={getSetting(settings, section, 'communication_method', 'SOCKET')}
            onChange={handleSelectChange('communication_method')}
          />
          <Input
            label={
              <>
                Max FPS
                <Tooltip text="Maximum frames per second for token detection. Range: 10 - 60. Default: 30.">
                  <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                </Tooltip>
              </>
            }
            type="text"
            value={getSetting(settings, section, 'max_fps', '30')}
            onChange={handleInputChange('max_fps', 'number')}
            placeholder="30"
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Input
            label={
              <>
                Confidence Threshold
                <Tooltip text="Minimum AI confidence for token detection. Range: 0.1 - 0.9. Default: 0.4.">
                  <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                </Tooltip>
              </>
            }
            type="text"
            value={getSetting(settings, section, 'confidence_threshold', '0.4')}
            onChange={handleInputChange('confidence_threshold', 'number')}
            placeholder="0.4"
          />
          <Input
            label={
              <>
                Sprinkler Confidence
                <Tooltip text="Minimum AI confidence for sprinkler detection. Range: 0.3 - 0.8. Default: 0.5.">
                  <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                </Tooltip>
              </>
            }
            type="text"
            value={getSetting(settings, section, 'sprinkler_confidence_threshold', '0.5')}
            onChange={handleInputChange('sprinkler_confidence_threshold', 'number')}
            placeholder="0.5"
          />
        </div>

        <div className="pt-4 border-t border-white/5">
          <label className="block text-sm font-medium mb-3 text-text-secondary">Token Priority & Ignore List</label>
          <Button
            variant="primary"
            onClick={openTokenPriority}
            className="w-full md:w-auto"
          >
            Edit Token Priority
          </Button>
        </div>
      </div>
    </Card>
  );
}

function AIAdvancedSettings({ settings, updateSetting }: { settings: any, updateSetting: any }) {
  const section = 'AIGather';

  const handleInputChange = (key: string, type = 'text') => (e: React.ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }
    updateSetting(section, key, value);
  };

  return (
    <Card title="AI Advanced Settings" className="mb-8">
      <div className="space-y-8">
        {/* Leash System */}
        <div className="space-y-4">
          <h4 className="text-sm font-semibold text-accent-secondary uppercase tracking-wider border-b border-white/5 pb-2">Leash System</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Input
              label={
                <>
                  Max Leash Dist.
                  <Tooltip text="Hard limit in tiles. Tokens beyond this are ignored. Range: 2.0 - 8.0. Default: 4.0.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'max_leash_distance', '4.0')}
              onChange={handleInputChange('max_leash_distance', 'number')}
              placeholder="4.0"
            />
            <Input
              label={
                <>
                  Soft Leash Dist.
                  <Tooltip text="Soft limit in tiles. Tokens beyond this get heavy penalties. Range: 1.5 - 5.0. Default: 2.5.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'soft_leash_distance', '2.5')}
              onChange={handleInputChange('soft_leash_distance', 'number')}
              placeholder="2.5"
            />
            <Input
              label={
                <>
                  Moves Until Recal.
                  <Tooltip text="Movements before returning to sprinkler to correct drift. Range: 5 - 25. Default: 10.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'movements_before_recalibration', '10')}
              onChange={handleInputChange('movements_before_recalibration', 'number')}
              placeholder="10"
            />
          </div>
        </div>

        {/* Token Selection */}
        <div className="space-y-4">
          <h4 className="text-sm font-semibold text-accent-secondary uppercase tracking-wider border-b border-white/5 pb-2">Token Selection</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Input
              label={
                <>
                  Min Token Dist.
                  <Tooltip text="Ignore tokens closer than this (tiles). Range: 0.1 - 0.5. Default: 0.3.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'min_token_distance', '0.3')}
              onChange={handleInputChange('min_token_distance', 'number')}
              placeholder="0.3"
            />
            <Input
              label={
                <>
                  Max Consider Dist.
                  <Tooltip text="Ignore tokens further than this (tiles). Range: 3.0 - 8.0. Default: 5.0.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'max_token_consideration_distance', '5.0')}
              onChange={handleInputChange('max_token_consideration_distance', 'number')}
              placeholder="5.0"
            />
            <Input
              label={
                <>
                  Cluster Radius
                  <Tooltip text="Distance to consider tokens as a group. Range: 1.0 - 3.0. Default: 2.0.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'cluster_radius', '2.0')}
              onChange={handleInputChange('cluster_radius', 'number')}
              placeholder="2.0"
            />
          </div>
        </div>

        {/* Scoring Weights */}
        <div className="space-y-4">
          <h4 className="text-sm font-semibold text-accent-secondary uppercase tracking-wider border-b border-white/5 pb-2">Scoring Weights</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Input
              label={
                <>
                  Proximity Exp.
                  <Tooltip text="How strongly distance affects scoring. Range: 1.2 - 2.5. Default: 1.8.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'proximity_exponent', '1.8')}
              onChange={handleInputChange('proximity_exponent', 'number')}
              placeholder="1.8"
            />
            <Input
              label={
                <>
                  Toward Home Bonus
                  <Tooltip text="Score multiplier for moving towards sprinkler. Range: 1.0 - 2.0. Default: 1.4.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'toward_home_bonus', '1.4')}
              onChange={handleInputChange('toward_home_bonus', 'number')}
              placeholder="1.4"
            />
            <Input
              label={
                <>
                  Away Penalty
                  <Tooltip text="Score multiplier for moving away from sprinkler. Range: 0.3 - 1.0. Default: 0.6.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'away_from_home_penalty', '0.6')}
              onChange={handleInputChange('away_from_home_penalty', 'number')}
              placeholder="0.6"
            />
            <Input
              label={
                <>
                  Cluster Bonus
                  <Tooltip text="Bonus score percentage per nearby token. Range: 0.05 - 0.3. Default: 0.15.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'cluster_bonus_per_token', '0.15')}
              onChange={handleInputChange('cluster_bonus_per_token', 'number')}
              placeholder="0.15"
            />
            <Input
              label={
                <>
                  Leash Edge Penalty
                  <Tooltip text="Extra penalty when beyond soft leash and moving away. Range: 0.1 - 0.5. Default: 0.3.">
                    <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                  </Tooltip>
                </>
              }
              type="text"
              value={getSetting(settings, section, 'leash_edge_penalty', '0.3')}
              onChange={handleInputChange('leash_edge_penalty', 'number')}
              placeholder="0.3"
            />
          </div>
        </div>

        {/* Idle & Sprinkler */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="space-y-4">
            <h4 className="text-sm font-semibold text-accent-secondary uppercase tracking-wider border-b border-white/5 pb-2">Idle Behavior</h4>
            <div className="grid grid-cols-1 gap-6">
              <Input
                label={
                  <>
                    Idle Return Interval
                    <Tooltip text="Seconds to wait between return attempts when idle. Range: 0.5 - 5.0. Default: 1.5.">
                      <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                    </Tooltip>
                  </>
                }
                type="text"
                value={getSetting(settings, section, 'idle_return_interval', '1.5')}
                onChange={handleInputChange('idle_return_interval', 'number')}
                placeholder="1.5"
              />
              <Input
                label={
                  <>
                    No Token Timeout
                    <Tooltip text="Seconds without tokens before forced recalibration. Range: 5.0 - 30.0. Default: 15.0.">
                      <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                    </Tooltip>
                  </>
                }
                type="text"
                value={getSetting(settings, section, 'no_token_recalibration_timeout', '15.0')}
                onChange={handleInputChange('no_token_recalibration_timeout', 'number')}
                placeholder="15.0"
              />
            </div>
          </div>

          <div className="space-y-4">
            <h4 className="text-sm font-semibold text-accent-secondary uppercase tracking-wider border-b border-white/5 pb-2">Sprinkler Detection</h4>
            <div className="grid grid-cols-1 gap-6">
              <div className="grid grid-cols-2 gap-4">
                <Input
                  label={
                    <>
                      Arrival Thresh.
                      <Tooltip text="Distance to be considered 'at' the sprinkler. Range: 0.3 - 1.5. Default: 0.8.">
                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                      </Tooltip>
                    </>
                  }
                  type="text"
                  value={getSetting(settings, section, 'sprinkler_arrival_threshold', '0.8')}
                  onChange={handleInputChange('sprinkler_arrival_threshold', 'number')}
                  placeholder="0.8"
                />
                <Input
                  label={
                    <>
                      Max Detect Dist.
                      <Tooltip text="Max distance to trust sprinkler detection. Range: 5.0 - 15.0. Default: 10.0.">
                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                      </Tooltip>
                    </>
                  }
                  type="text"
                  value={getSetting(settings, section, 'max_sprinkler_distance', '10.0')}
                  onChange={handleInputChange('max_sprinkler_distance', 'number')}
                  placeholder="10.0"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <Input
                  label={
                    <>
                      Rescan Attempts
                      <Tooltip text="Retries before giving up on sprinkler. Range: 1 - 5. Default: 3.">
                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                      </Tooltip>
                    </>
                  }
                  type="text"
                  value={getSetting(settings, section, 'sprinkler_rescan_attempts', '3')}
                  onChange={handleInputChange('sprinkler_rescan_attempts', 'number')}
                  placeholder="3"
                />
                <Input
                  label={
                    <>
                      Rescan Delay
                      <Tooltip text="Seconds to wait between rescan attempts. Range: 0.1 - 1.0. Default: 0.3.">
                        <span className="text-accent-primary cursor-help hover:text-accent-secondary transition-colors"> (?)</span>
                      </Tooltip>
                    </>
                  }
                  type="text"
                  value={getSetting(settings, section, 'sprinkler_rescan_delay', '0.3')}
                  onChange={handleInputChange('sprinkler_rescan_delay', 'number')}
                  placeholder="0.3"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
}

function GatherCycleSettings({ cycleNum, settings, updateSetting }: { cycleNum: number, settings: any, updateSetting: any }) {
  const section = 'Gather';
  const fieldKey = `gatherfield${cycleNum}`;
  const timeKey = `gathertime${cycleNum}`;
  const bagKey = `maxfillbag${cycleNum}`;
  const rotateKey = `rotate${cycleNum}`;
  const rotateAmountKey = `rotateamount${cycleNum}`;
  const toHiveKey = `tohivebymethod${cycleNum}`;
  const aiGatherKey = `aigather${cycleNum}`;
  const driftCompKey = `driftcomp${cycleNum}`;
  const patternFieldKey = `patternfield${cycleNum}`;
  const patternLengthKey = `patternfield${cycleNum}length`;
  const patternWidthKey = `patternfield${cycleNum}width`;
  const patternShiftlockKey = `patternfield${cycleNum}shiftlock`;
  const invertFBKey = `gatherfield${cycleNum}invertfb`;
  const invertLRKey = `gatherfield${cycleNum}invertlr`;
  const sprinklerLocationKey = `gatherfield${cycleNum}sprinklerlocation`;
  const sprinklerDistanceKey = `gatherfield${cycleNum}sprinklerdistance`;

  const thisField = getSetting(settings, section, fieldKey, 'None');
  const prevField = cycleNum > 1 ? getSetting(settings, section, `gatherfield${cycleNum - 1}`, 'None') : null;

  const getParsedSetting = (key: string, defaultValue: any) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  let fieldSelectEnabled = true;
  if (cycleNum === 1) {
    fieldSelectEnabled = true;
  } else {
    fieldSelectEnabled = prevField !== 'None';
  }

  const isEnabled = thisField !== 'None';
  const isAIGatherEnabled = isEnabled && !getParsedSetting(aiGatherKey, false);

  useEffect(() => {
    if (cycleNum < 3 && thisField === 'None') {
      const nextFieldKey = `gatherfield${cycleNum + 1}`;
      const nextField = getSetting(settings, section, nextFieldKey, 'None');
      if (nextField !== 'None') {
        updateSetting(section, nextFieldKey, 'None');
      }
    }
    if (cycleNum < 2 && thisField === 'None') {
      const next2FieldKey = `gatherfield${cycleNum + 2}`;
      const next2Field = getSetting(settings, section, next2FieldKey, 'None');
      if (next2Field !== 'None') {
        updateSetting(section, next2FieldKey, 'None');
      }
    }
  }, [thisField, cycleNum, settings, section, updateSetting]);

  const handleSwitchChange = (key: string) => (checked: boolean) => {
    updateSetting(section, key, boolToIni(checked));
  };

  const handleInputChange = (key: string, type = 'text') => (e: React.ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }

    if (key === patternWidthKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 9)) return;
    }
    if (key === sprinklerDistanceKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 10)) return;
    }
    if (key === timeKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 0 || num > 9999)) return;
    }
    if (key === bagKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 0 || num > 100)) return;
    }
    if (key === rotateAmountKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 4)) return;
    }

    updateSetting(section, key, value);
  };

  const handleSelectChange = (key: string) => (e: React.ChangeEvent<HTMLSelectElement>) => {
    updateSetting(section, key, e.target.value);
  };

  return (
    <Card title={`Cycle ${cycleNum}`} className={`h-full ${!fieldSelectEnabled ? 'opacity-50' : ''}`}>
      <div className="space-y-6">
        <FieldSelect
          label="Field"
          options={["None", ...fieldOptions]}
          value={getSetting(settings, section, fieldKey, 'None')}
          onChange={(value) => updateSetting(section, fieldKey, value)}
          disabled={!fieldSelectEnabled}
        />

        <div className={`space-y-6 transition-all duration-200 ${!isEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Time (minutes)"
              type="text"
              value={isEnabled ? getSetting(settings, section, timeKey, '0') : ''}
              onChange={handleInputChange(timeKey, 'number')}
              disabled={!isEnabled}
              placeholder="0-9999"
            />
            <Input
              label="Max Fill Bag (%)"
              type="text"
              value={isEnabled ? getSetting(settings, section, bagKey, '100') : ''}
              onChange={handleInputChange(bagKey, 'number')}
              disabled={!isEnabled}
              placeholder="0-100"
            />
          </div>

          <div className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-colors">
            <span className="text-sm font-medium text-text-primary">AI Gather</span>
            <Switch
              checked={isEnabled ? getParsedSetting(aiGatherKey, false) : false}
              onChange={handleSwitchChange(aiGatherKey)}
              disabled={!isEnabled}
            />
          </div>

          <div className={`space-y-6 transition-all duration-200 ${!isAIGatherEnabled ? 'opacity-50 pointer-events-none' : ''}`}>
            <Select
              label="Pattern"
              options={["None", ...patternOptions]}
              value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternFieldKey, 'None') : 'None'}
              onChange={handleSelectChange(patternFieldKey)}
              disabled={!isEnabled || !isAIGatherEnabled}
            />

            <div className="grid grid-cols-2 gap-4">
              <Select
                label="Pattern Length"
                options={patternLengthOptions}
                value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternLengthKey, 'M') : 'M'}
                onChange={handleSelectChange(patternLengthKey)}
                disabled={!isEnabled || !isAIGatherEnabled}
              />
              <Input
                label="Pattern Width"
                type="text"
                value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternWidthKey, '3') : ''}
                onChange={handleInputChange(patternWidthKey, 'number')}
                disabled={!isEnabled || !isAIGatherEnabled}
                placeholder="1-9"
              />
            </div>

            <div className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-colors">
              <span className="text-sm font-medium text-text-primary">Shift Lock</span>
              <Switch
                checked={isEnabled && isAIGatherEnabled ? getParsedSetting(patternShiftlockKey, false) : false}
                onChange={handleSwitchChange(patternShiftlockKey)}
                disabled={!isEnabled || !isAIGatherEnabled}
              />
            </div>
          </div>

          <div className="space-y-3 pt-4 border-t border-white/5">
            <h5 className="text-xs font-semibold text-text-muted uppercase tracking-wider">Movement Modifiers</h5>
            {[
              { label: "Invert F/B", key: invertFBKey },
              { label: "Invert L/R", key: invertLRKey },
              { label: "Drift Compensation", key: driftCompKey },
            ].map(item => (
              <div key={item.key} className="flex items-center justify-between p-2 rounded hover:bg-white/5 transition-colors">
                <span className="text-sm text-text-primary">{item.label}</span>
                <Switch
                  checked={isEnabled ? getParsedSetting(item.key, false) : false}
                  onChange={handleSwitchChange(item.key)}
                  disabled={!isEnabled}
                  className="scale-90"
                />
              </div>
            ))}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Rotate"
              options={rotateOptions}
              value={isEnabled ? getSetting(settings, section, rotateKey, 'None') : 'None'}
              onChange={handleSelectChange(rotateKey)}
              disabled={!isEnabled}
            />
            <Input
              label="Rotate Amount"
              type="text"
              value={isEnabled ? getSetting(settings, section, rotateAmountKey, '1') : ''}
              onChange={handleInputChange(rotateAmountKey, 'number')}
              disabled={!isEnabled}
              placeholder="1-4"
            />
          </div>

          <Select
            label="To Hive By Method"
            options={toHiveOptions}
            value={isEnabled ? getSetting(settings, section, toHiveKey, 'Walk') : 'Walk'}
            onChange={handleSelectChange(toHiveKey)}
            disabled={!isEnabled}
          />

          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Sprinkler Location"
              options={sprinklerLocationOptions}
              value={isEnabled ? getSetting(settings, section, sprinklerLocationKey, 'Center') : 'Center'}
              onChange={handleSelectChange(sprinklerLocationKey)}
              disabled={!isEnabled}
            />
            <Input
              label="Sprinkler Distance"
              type="text"
              value={isEnabled ? getSetting(settings, section, sprinklerDistanceKey, '0') : ''}
              onChange={handleInputChange(sprinklerDistanceKey, 'number')}
              disabled={!isEnabled}
              placeholder="1-10"
            />
          </div>
        </div>
      </div>
    </Card>
  );
}

function GatherTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="flex items-center justify-center h-full"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div></div>;
  if (error) return <div className="p-4 bg-status-error/10 border border-status-error/20 rounded-lg text-status-error">Error loading settings: {error}</div>;

  const sidebarItems = [
    {
      id: 'cycle1',
      label: 'Cycle 1',
      content: <GatherCycleSettings cycleNum={1} settings={settings} updateSetting={updateSetting} />
    },
    {
      id: 'cycle2',
      label: 'Cycle 2',
      content: <GatherCycleSettings cycleNum={2} settings={settings} updateSetting={updateSetting} />
    },
    {
      id: 'cycle3',
      label: 'Cycle 3',
      content: <GatherCycleSettings cycleNum={3} settings={settings} updateSetting={updateSetting} />
    },
    {
      id: 'general',
      label: 'AI Settings',
      content: <AIGenericSettings settings={settings} updateSetting={updateSetting} />
    },
    {
      id: 'ai-advanced',
      label: 'Advanced Settings',
      content: <AIAdvancedSettings settings={settings} updateSetting={updateSetting} />
    },
  ];

  return <TabSidebarLayout items={sidebarItems} />;
}

export default GatherTab;

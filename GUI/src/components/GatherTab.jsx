import React, { useState, useEffect, useRef } from 'react';
import { useSettings, getSetting, boolToIni, parseIniValue } from '../utils/settings';

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
const driftCorrectionMethodOptions = ["AI", "SATURATOR"];

const Tooltip = ({ text, children }) => {
  const [show, setShow] = useState(false);
  const timeoutRef = useRef(null);

  const showTooltip = () => {
    clearTimeout(timeoutRef.current);
    setShow(true);
  };

  const hideTooltip = () => {
    timeoutRef.current = setTimeout(() => {
      setShow(false);
    }, 100);
  };

  useEffect(() => {
    return () => clearTimeout(timeoutRef.current);
  }, []);

  return (
    <span
      className="relative inline-block"
      onMouseEnter={showTooltip}
      onMouseLeave={hideTooltip}
    >
      {children}
      {show && (
        <div
          className="absolute bottom-full left-1/2 z-50 mb-3 -translate-x-1/2 transform rounded-lg bg-gray-900 px-3 py-2 text-sm text-white shadow-lg w-64 text-center"
          onMouseEnter={showTooltip}
          onMouseLeave={hideTooltip}
        >
          {text}
          <div className="absolute left-1/2 top-full -translate-x-1/2 border-4 border-solid border-x-transparent border-t-gray-900" />
        </div>
      )}
    </span>
  );
};

function AIGatherSettings({ settings, updateSetting }) {
  const section = 'AIGather';

  const handleInputChange = (key, type = 'text') => (e) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }
    updateSetting(section, key, value);
  };

  const handleSelectChange = (key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  const openTokenPriority = () => {
    if (window.electron) {
      window.electron.openTokenPriorityWindow();
    }
  };

  const driftMethod = getSetting(settings, section, 'drift_correction_method', 'AI');
  const isDriftMethodAI = driftMethod === 'AI';

  return (
    <div className="bg-gray-700 p-6 rounded-lg shadow-lg">
      <h3 className="text-xl font-semibold mb-4 text-green-400">AI Behavior Settings</h3>

      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Confidence Threshold{' '}
              <Tooltip text="Minimum confidence level (0.0 to 1.0) for the AI to recognize a token.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="0.4"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'confidence_threshold', '0.4')}
              onChange={handleInputChange('confidence_threshold', 'number')}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Max FPS{' '}
              <Tooltip text="How many frames per second the AI analyzes your screen. Higher values use more CPU.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="30"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'max_fps', '30')}
              onChange={handleInputChange('max_fps', 'number')}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Communication Method</label>
            <select
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'communication_method', 'SOCKET')}
              onChange={handleSelectChange('communication_method')}
            >
              {communicationMethodOptions.map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Drift Correction Method{' '}
              <Tooltip text="AI: Works with all sprinklers. SATURATOR: Legacy method, only works with Saturator sprinkler.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <select
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'drift_correction_method', 'AI')}
              onChange={handleSelectChange('drift_correction_method')}
            >
              {driftCorrectionMethodOptions.map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
        </div>

        {isDriftMethodAI && (
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Sprinkler Confidence Threshold{' '}
              <Tooltip text="Minimum confidence level (0.0 to 1.0) for AI to detect sprinklers during drift correction.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="0.45"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'sprinkler_confidence_threshold', '0.45')}
              onChange={handleInputChange('sprinkler_confidence_threshold', 'number')}
            />
          </div>
        )}

        <div className="mt-4">
          <label className="block text-sm font-medium mb-2 text-gray-300">Token Priority & Ignore List</label>
          <button
            onClick={openTokenPriority}
            className="w-full py-2 px-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg shadow-md transition-all duration-200"
          >
            Edit Token Priority
          </button>
        </div>

        <h4 className="text-lg font-semibold mt-6 mb-3 text-green-400">Advanced Settings</h4>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Safe Distance{' '}
              <Tooltip text="Distance in tiles from center point considered safe for token collection without penalties.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="3.0"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'safe_distance', '3.0')}
              onChange={handleInputChange('safe_distance', 'number')}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Penalty Start Distance{' '}
              <Tooltip text="Distance at which scoring penalties begin to apply for tokens.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="3.0"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'penalty_start_distance', '3.0')}
              onChange={handleInputChange('penalty_start_distance', 'number')}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Max Allowed Distance{' '}
              <Tooltip text="Maximum distance the AI can move from the center point before resetting.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="11.0"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'max_allowed_distance', '11.0')}
              onChange={handleInputChange('max_allowed_distance', 'number')}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">
              Distance Penalty Exponent{' '}
              <Tooltip text="Exponent for distance penalty calculation. Higher values penalize distance more heavily.">
                <span className="text-gray-500 cursor-help">(?)</span>
              </Tooltip>
            </label>
            <input
              type="text"
              placeholder="1.5"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={getSetting(settings, section, 'distance_penalty_exponent', '1.5')}
              onChange={handleInputChange('distance_penalty_exponent', 'number')}
            />
          </div>
        </div>

        <div className="flex items-center">
          <input
            type="checkbox"
            id="pre-movement-validation"
            className="mr-3 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
            checked={parseIniValue(getSetting(settings, section, 'pre_movement_validation', 'true'))}
            onChange={(e) => updateSetting(section, 'pre_movement_validation', boolToIni(e.target.checked))}
          />
          <label htmlFor="pre-movement-validation" className="text-sm font-medium text-gray-300">
            Pre-Movement Validation{' '}
            <Tooltip text="Validates movement before execution to prevent exceeding maximum distance.">
              <span className="text-gray-500 cursor-help">(?)</span>
            </Tooltip>
          </label>
        </div>
      </div>
    </div>
  );
}

function GatherCycleSettings({ cycleNum, settings, updateSetting }) {
  const section = 'Gather';
  const fieldKey = `gatherfield${cycleNum}`;
  const timeKey = `gathertime${cycleNum}`;
  const bagKey = `maxfillbag${cycleNum}`;
  const rotateKey = `rotate${cycleNum}`;
  const rotateAmountKey = `rotateammount${cycleNum}`;
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

  const getParsedSetting = (key, defaultValue) => {
    return parseIniValue(getSetting(settings, section, key, defaultValue));
  };

  let fieldSelectEnabled = true;
  if (cycleNum === 1) {
    fieldSelectEnabled = true;
  } else {
    fieldSelectEnabled = prevField !== 'None';
  }
  let fieldSelectOpacity = '';
  if (cycleNum === 1) {
    fieldSelectOpacity = 'opacity-100';
  } else {
    fieldSelectOpacity = prevField !== 'None' ? '' : 'opacity-50';
  }

  const isEnabled = thisField !== 'None';
  const isAIGatherEnabled = isEnabled && !getParsedSetting(aiGatherKey, false);
  const opacityClass = isEnabled ? '' : 'opacity-50';
  const patternOpacityClass = isEnabled && isAIGatherEnabled ? '' : 'opacity-50';

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

  const handleSwitchChange = (key) => (e) => {
    updateSetting(section, key, boolToIni(e.target.checked));
  };

  const handleInputChange = (key, type = 'text') => (e) => {
    let value = e.target.value;
    if (type === 'number') {
      value = value.replace(/[^0-9.]/g, '');
      if (value.split('.').length > 2) {
        value = value.substring(0, value.lastIndexOf('.'));
      }
    }

    if (key === patternWidthKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 9)) {
        return;
      }
    }
    if (key === sprinklerDistanceKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 10)) {
        return;
      }
    }
    if (key === timeKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 0 || num > 9999)) {
        return;
      }
    }
    if (key === bagKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 0 || num > 100)) {
        return;
      }
    }
    if (key === rotateAmountKey) {
      const num = parseInt(value);
      if (value !== '' && (isNaN(num) || num < 1 || num > 4)) {
        return;
      }
    }

    updateSetting(section, key, value);
  };

  const handleSelectChange = (key) => (e) => {
    updateSetting(section, key, e.target.value);
  };

  return (
    <div className="bg-gray-700 p-6 rounded-lg shadow-lg">
      <h3 className="text-xl font-semibold mb-4 text-green-400">Cycle {cycleNum}</h3>

      <div className="space-y-4">
        <div className={fieldSelectOpacity}>
          <label className="block text-sm font-medium mb-2 text-gray-300">Field</label>
          <select
            className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
            value={getSetting(settings, section, fieldKey, 'None')}
            onChange={handleSelectChange(fieldKey)}
            disabled={!fieldSelectEnabled}
          >
            <option value="None">None</option>
            {fieldOptions.map(field => (
              <option key={field} value={field}>{field}</option>
            ))}
          </select>
        </div>

        <div className={`grid grid-cols-2 gap-4 ${opacityClass}`}>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Time (minutes)</label>
            <input
              type="text"
              min="0"
              max="9999"
              placeholder="0-9999"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, timeKey, '0') : ''}
              onChange={handleInputChange(timeKey, 'number')}
              disabled={!isEnabled}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Max Fill Bag (%)</label>
            <input
              type="text"
              min="0"
              max="100"
              placeholder="0-100"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, bagKey, '100') : ''}
              onChange={handleInputChange(bagKey, 'number')}
              disabled={!isEnabled}
            />
          </div>
        </div>

        <div className={`flex items-center ${opacityClass}`}>
          <input
            type="checkbox"
            id={`ai-gather-${cycleNum}`}
            className="mr-3 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
            checked={isEnabled ? getParsedSetting(aiGatherKey, false) : false}
            onChange={handleSwitchChange(aiGatherKey)}
            disabled={!isEnabled}
          />
          <label htmlFor={`ai-gather-${cycleNum}`} className="text-sm font-medium text-gray-300">
            AI Gather
          </label>
        </div>

        <div className={patternOpacityClass}>
          <label className="block text-sm font-medium mb-2 text-gray-300">Pattern</label>
          <select
            className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
            value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternFieldKey, 'None') : 'None'}
            onChange={handleSelectChange(patternFieldKey)}
            disabled={!isEnabled || !isAIGatherEnabled}
          >
            <option value="None">None</option>
            {patternOptions.map(pattern => (
              <option key={pattern} value={pattern}>{pattern}</option>
            ))}
          </select>
        </div>

        <div className={`grid grid-cols-2 gap-4 ${patternOpacityClass}`}>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Pattern Length</label>
            <select
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternLengthKey, 'M') : 'M'}
              onChange={handleSelectChange(patternLengthKey)}
              disabled={!isEnabled || !isAIGatherEnabled}
            >
              {patternLengthOptions.map(length => (
                <option key={length} value={length}>{length}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Pattern Width</label>
            <input
              type="text"
              min="1"
              max="9"
              placeholder="1-9"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled && isAIGatherEnabled ? getSetting(settings, section, patternWidthKey, '3') : ''}
              onChange={handleInputChange(patternWidthKey, 'number')}
              disabled={!isEnabled || !isAIGatherEnabled}
            />
          </div>
        </div>

        <div className={`flex flex-wrap gap-4 ${patternOpacityClass}`}>
          <div className="flex items-center">
            <input
              type="checkbox"
              id={`shiftlock-${cycleNum}`}
              className="mr-2 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
              checked={isEnabled && isAIGatherEnabled ? getParsedSetting(patternShiftlockKey, false) : false}
              onChange={handleSwitchChange(patternShiftlockKey)}
              disabled={!isEnabled || !isAIGatherEnabled}
            />
            <label htmlFor={`shiftlock-${cycleNum}`} className="text-sm font-medium text-gray-300">
              Shift Lock
            </label>
          </div>
          <div className="flex items-center">
            <input
              type="checkbox"
              id={`invertfb-${cycleNum}`}
              className="mr-2 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
              checked={isEnabled ? getParsedSetting(invertFBKey, false) : false}
              onChange={handleSwitchChange(invertFBKey)}
              disabled={!isEnabled}
            />
            <label htmlFor={`invertfb-${cycleNum}`} className="text-sm font-medium text-gray-300">
              Invert F/B
            </label>
          </div>
          <div className="flex items-center">
            <input
              type="checkbox"
              id={`invertlr-${cycleNum}`}
              className="mr-2 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
              checked={isEnabled ? getParsedSetting(invertLRKey, false) : false}
              onChange={handleSwitchChange(invertLRKey)}
              disabled={!isEnabled}
            />
            <label htmlFor={`invertlr-${cycleNum}`} className="text-sm font-medium text-gray-300">
              Invert L/R
            </label>
          </div>
          <div className="flex items-center">
            <input
              type="checkbox"
              id={`driftcomp-${cycleNum}`}
              className="mr-2 w-4 h-4 text-blue-600 bg-gray-600 border-blue-500 rounded focus:ring-blue-400"
              checked={isEnabled ? getParsedSetting(driftCompKey, false) : false}
              onChange={handleSwitchChange(driftCompKey)}
              disabled={!isEnabled}
            />
            <label htmlFor={`driftcomp-${cycleNum}`} className="text-sm font-medium text-gray-300">
              Drift Compensation
            </label>
          </div>
        </div>

        <div className={`grid grid-cols-2 gap-4 ${opacityClass}`}>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Rotate</label>
            <select
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, rotateKey, 'None') : 'None'}
              onChange={handleSelectChange(rotateKey)}
              disabled={!isEnabled}
            >
              {rotateOptions.map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Rotate Amount</label>
            <input
              type="text"
              min="1"
              max="4"
              placeholder="1-4"
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, rotateAmountKey, '1') : ''}
              onChange={handleInputChange(rotateAmountKey, 'number')}
              disabled={!isEnabled}
            />
          </div>
        </div>

        <div className={opacityClass}>
          <label className="block text-sm font-medium mb-2 text-gray-300">To Hive By Method</label>
          <select
            className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
            value={isEnabled ? getSetting(settings, section, toHiveKey, 'Walk') : 'Walk'}
            onChange={handleSelectChange(toHiveKey)}
            disabled={!isEnabled}
          >
            {toHiveOptions.map(option => (
              <option key={option} value={option}>{option}</option>
            ))}
          </select>
        </div>

        <div className={`grid grid-cols-2 gap-4 ${opacityClass}`}>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Sprinkler Location</label>
            <select
              className="w-full p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, sprinklerLocationKey, 'Center') : 'Center'}
              onChange={handleSelectChange(sprinklerLocationKey)}
              disabled={!isEnabled}
            >
              {sprinklerLocationOptions.map(option => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-300">Sprinkler Distance</label>
            <input
              type="text"
              min="1"
              max="10"
              placeholder="1-10"
              className="w-24 p-2 rounded-md bg-gray-600 border border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400 transition-all duration-200"
              value={isEnabled ? getSetting(settings, section, sprinklerDistanceKey, '0') : ''}
              onChange={handleInputChange(sprinklerDistanceKey, 'number')}
              disabled={!isEnabled}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

function GatherTab() {
  const { settings, updateSetting, loading, error } = useSettings();

  if (loading) return <div className="text-center py-8">Loading settings...</div>;
  if (error) return <div className="text-center py-8 text-red-500">Error loading settings: {error}</div>;

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-lime-400">Gather Settings</h2>

      <div className="mb-8">
        <AIGatherSettings settings={settings} updateSetting={updateSetting} />
      </div>

      <div className="bg-gray-800 p-6 rounded-lg shadow-xl grid grid-cols-1 lg:grid-cols-3 gap-8">
        <GatherCycleSettings cycleNum={1} settings={settings} updateSetting={updateSetting} />
        <GatherCycleSettings cycleNum={2} settings={settings} updateSetting={updateSetting} />
        <GatherCycleSettings cycleNum={3} settings={settings} updateSetting={updateSetting} />
      </div>
    </>
  );
}

export default GatherTab;
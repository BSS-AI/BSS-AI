import React, { useState, useEffect } from 'react';
import { useSettings, getSetting } from '../utils/settings';

const hardcodedIgnoreTokens = [
  "Balloon", "bd", "bomb", "scrath", "Golden Balloon",
  "Fuzz Bombs", "Fuzz Bomb", "Falling Coconut"
];

function TokenPriorityWindow() {
  const { settings, updateSetting, loading, error } = useSettings();
  const [tokens, setTokens] = useState([]);
  const [draggedIndex, setDraggedIndex] = useState(null);
  const [dragOverIndex, setDragOverIndex] = useState(null);

  useEffect(() => {
    if (!loading && settings) {
      const priorityTokensStr = getSetting(settings, 'AIGather', 'priority_tokens', '');
      const ignoreTokensStr = getSetting(settings, 'AIGather', 'ignore_tokens', '');
      const allTokensFromSettings = new Set();

      if (priorityTokensStr) {
        priorityTokensStr.split(', ').forEach((tokenStr) => {
          if (!tokenStr) return;
          const [name] = tokenStr.split(':');
          allTokensFromSettings.add(name);
        });
      }

      if (ignoreTokensStr) {
        ignoreTokensStr.split(', ').forEach((tokenName) => {
          if (tokenName) allTokensFromSettings.add(tokenName);
        });
      }

      const allAvailableTokens = Array.from(allTokensFromSettings).filter(
        token => !hardcodedIgnoreTokens.includes(token)
      );

      const priorityMap = new Map();
      if (priorityTokensStr) {
        priorityTokensStr.split(', ').forEach((tokenStr, index) => {
          if (!tokenStr) return;
          const [name, value] = tokenStr.split(':');
          priorityMap.set(name, { value: value || '', priority: index });
        });
      }

      const ignoreSet = new Set(ignoreTokensStr ? ignoreTokensStr.split(', ').filter(Boolean) : []);

      const initialTokens = allAvailableTokens.map(name => ({
        name,
        value: priorityMap.get(name)?.value || '',
        ignored: ignoreSet.has(name),
        priority: priorityMap.get(name)?.priority ?? Infinity,
      }));

      initialTokens.sort((a, b) => {
        if (a.ignored && !b.ignored) return 1;
        if (!a.ignored && b.ignored) return -1;
        return a.priority - b.priority;
      });

      setTokens(initialTokens);
    }
  }, [settings, loading]);

  const handleValueChange = (tokenName, newValue) => {
    const newTokens = tokens.map(t =>
      t.name === tokenName ? { ...t, value: newValue.replace(/[^0-9]/g, '') } : t
    );
    setTokens(newTokens);
  };

  const toggleIgnore = (tokenName) => {
    let tokenToMove;
    const remainingTokens = tokens.filter(t => {
      if (t.name === tokenName) {
        tokenToMove = { ...t, ignored: !t.ignored };
        return false;
      }
      return true;
    });

    if (tokenToMove.ignored) {
      setTokens([...remainingTokens, tokenToMove]);
    } else {
      const firstIgnoredIndex = remainingTokens.findIndex(t => t.ignored);
      if (firstIgnoredIndex === -1) {
        setTokens([...remainingTokens, tokenToMove]);
      } else {
        remainingTokens.splice(firstIgnoredIndex, 0, tokenToMove);
        setTokens(remainingTokens);
      }
    }
  };

  const handleDragStart = (e, index) => {
    setDraggedIndex(index);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e, index) => {
    e.preventDefault();
    if (index !== dragOverIndex) {
      setDragOverIndex(index);
    }
  };

  const handleDragLeave = () => {
    setDragOverIndex(null);
  };

  const handleDrop = () => {
    if (draggedIndex === null || dragOverIndex === null || tokens[dragOverIndex].ignored) {
      setDraggedIndex(null);
      setDragOverIndex(null);
      return;
    };
    const list = [...tokens];
    const draggedItem = list.splice(draggedIndex, 1)[0];
    list.splice(dragOverIndex, 0, draggedItem);
    setTokens(list);
    setDraggedIndex(null);
    setDragOverIndex(null);
  };

  const saveChanges = async () => {
    const priorityList = tokens
      .filter(t => !t.ignored)
      .map(t => (t.value ? `${t.name}:${t.value}` : t.name));

    const userIgnoredTokens = tokens.filter(t => t.ignored).map(t => t.name);
    const combinedIgnoreList = [...new Set([...hardcodedIgnoreTokens, ...userIgnoredTokens])];

    await updateSetting('AIGather', 'priority_tokens', priorityList.join(', '));
    await updateSetting('AIGather', 'ignore_tokens', combinedIgnoreList.join(', '));

    window.electronAPI.closeWindow();
  };

  const cancelChanges = () => window.electronAPI.closeWindow();

  if (loading) return <div className="flex items-center justify-center h-screen text-white">Loading...</div>;
  if (error) return <div className="flex items-center justify-center h-screen text-red-500">Error: {error}</div>;

  const firstIgnoredIndex = tokens.findIndex(t => t.ignored);

  return (
    <div className="h-screen flex flex-col bg-gray-900/50 backdrop-blur-sm text-white font-sans">
      <div className="w-full h-10 bg-gray-800/80 flex items-center justify-between pr-2" style={{ WebkitAppRegion: 'drag' }}>
        <span className="ml-4 text-sm font-semibold">Token Priority Editor</span>
        <div className="flex" style={{ WebkitAppRegion: 'no-drag' }}>
          <button onClick={() => window.electronAPI.minimizeWindow()} className="w-8 h-8 flex items-center justify-center text-gray-400 hover:bg-gray-700 rounded-md transition-colors duration-200">
            —
          </button>
          <button onClick={cancelChanges} className="w-8 h-8 flex items-center justify-center text-gray-400 hover:bg-red-500 hover:text-white rounded-md transition-colors duration-200">
            ✕
          </button>
        </div>
      </div>

      <div className="flex-1 p-6 overflow-y-auto" onDragLeave={handleDragLeave} onDrop={handleDrop}>
        <h1 className="text-2xl font-bold mb-2 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-purple-400">
          Token Priority & Ignore List
        </h1>
        <p className="text-sm text-gray-400 mb-6">
          Drag prioritized tokens to reorder them. Higher is better.
        </p>

        <div className="space-y-2">
          {tokens.map((token, index) => (
            <React.Fragment key={token.name}>
              {index === firstIgnoredIndex && (
                <div className="text-center my-4">
                  <span className="text-sm font-bold text-gray-500 uppercase">Ignored Tokens</span>
                  <div className="w-full h-px bg-gray-700 mt-1"></div>
                </div>
              )}
              <div
                draggable={!token.ignored}
                onDragStart={(e) => handleDragStart(e, index)}
                onDragOver={(e) => handleDragOver(e, index)}
                className={`flex items-center p-2 rounded-lg transition-all duration-150
                  ${token.ignored ? 'bg-gray-800/50' : 'bg-gray-700 shadow-md cursor-grab hover:bg-gray-600/80'}
                  ${draggedIndex === index ? 'opacity-30' : ''}
                  ${dragOverIndex === index && !token.ignored ? 'ring-2 ring-blue-500' : 'ring-2 ring-transparent'}`}
              >
                <div className="flex items-center justify-center w-8 text-gray-400"
                  title={token.ignored ? '' : 'Drag to reorder'}>
                  {!token.ignored && (
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                      <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
                    </svg>
                  )}
                </div>
                <span className={`flex-grow font-medium ${token.ignored ? 'text-gray-500 line-through' : ''}`}>{token.name}</span>

                <div className="flex items-center">
                  <label className="text-xs mr-2 text-gray-400">Value:</label>
                  <input type="text" placeholder="Optional" value={token.value} onChange={(e) => handleValueChange(token.name, e.target.value)}
                    disabled={token.ignored} className="w-24 bg-gray-800 text-white text-sm rounded p-1 border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
                  <button onClick={() => toggleIgnore(token.name)} title={token.ignored ? 'Add to priority list' : 'Ignore this token'}
                    className={`ml-4 w-6 h-6 flex items-center justify-center rounded-full transition-colors duration-200 ${token.ignored ? 'bg-green-600 hover:bg-green-500' : 'bg-red-600 hover:bg-red-500'
                      }`}>
                    {token.ignored ? '+' : '✕'}
                  </button>
                </div>
              </div>
            </React.Fragment>
          ))}
        </div>
      </div>

      <div className="p-4 bg-gray-800/80 flex gap-4 border-t border-gray-700">
        <button onClick={saveChanges} className="flex-1 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-bold text-lg transition-all shadow-lg">
          Save & Close
        </button>
        <button onClick={cancelChanges} className="flex-1 py-3 bg-gray-600 hover:bg-gray-500 text-white rounded-lg font-bold text-lg transition-all">
          Cancel
        </button>
      </div>
    </div>
  );
}

export default TokenPriorityWindow;
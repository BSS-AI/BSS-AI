import React, { useState, useEffect } from 'react';

import HomeTab from './components/HomeTab';
import BoostTab from './components/BoostTab';
import CollectTab from './components/CollectTab';
import GatherTab from './components/GatherTab';
import KillTab from './components/KillTab';
import PlanterTab from './components/PlanterTab';
import QuestTab from './components/QuestTab';
import SettingsTab from './components/SettingsTab';

function App() {
  const [activeTab, setActiveTab] = useState('home');
  const [macroStatus, setMacroStatus] = useState('stopped');

  useEffect(() => {
    if (window.electron) {
      window.electron.onMacroStatus((status) => {
        setMacroStatus(status.status);
        if (status.status === 'error') {
          console.error('Macro Error:', status.message);
          alert(`Macro Error: ${status.message}`);
        }
      });
    }
  }, []);

  const handleStartMacro = () => {
    if (window.electron) {
      window.electron.startMacro();
    }
  };

  const handleStopMacro = () => {
    if (window.electron) {
      window.electron.stopMacro();
    }
  };

  window.addEventListener('contextmenu', e => e.preventDefault());

  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'F1') {
        e.preventDefault();
        handleStartMacro();
      }
      if (e.key === 'F3') {
        e.preventDefault();
        handleStopMacro();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  const renderContent = () => {
    switch (activeTab) {
      case 'home':
        return <HomeTab />;
      case 'boost':
        return <BoostTab />;
      case 'collect':
        return <CollectTab />;
      case 'gather':
        return <GatherTab />;
      case 'kill':
        return <KillTab />;
      case 'planter':
        return <PlanterTab />;
      case 'quest':
        return <QuestTab />;
      case 'settings':
        return <SettingsTab />;
      default:
        return <HomeTab />;
    }
  };

  const handleMinimize = () => {
    if (window.electron) window.electron.minimize();
  };

  const handleMaximize = () => {
    if (window.electron) window.electron.maximize();
  };

  const handleClose = () => {
    if (window.electron) window.electron.close();
  };

  return (
    <div className="flex h-screen bg-gradient-to-br from-gray-900 to-gray-700 text-white overflow-hidden">
      <div className="w-64 bg-gray-800 p-4 shadow-lg flex flex-col">
        <div className="flex items-center mb-8">
          <img src="../assets/bssAiLogo.png" alt="BSS AI Logo" className="w-10 h-10 mr-3" />
          <h1 className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-500">BSS AI</h1>
        </div>
        <nav className="flex-grow">
          <ul>
            <li className="mb-2">
              <button onClick={() => setActiveTab('home')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'home' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/home_dark.png" alt="Home" className="w-6 h-6 mr-3" />
                Home
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('gather')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'gather' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/gather_dark.png" alt="Gather" className="w-6 h-6 mr-3" />
                Gather
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('collect')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'collect' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/collect_dark.png" alt="Collect" className="w-6 h-6 mr-3" />
                Collect
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('kill')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'kill' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/kill_dark.png" alt="Kill" className="w-6 h-6 mr-3" />
                Kill
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('planter')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'planter' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/planter_dark.png" alt="Planter" className="w-6 h-6 mr-3" />
                Planter
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('quest')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'quest' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/quest_dark.png" alt="Quest" className="w-6 h-6 mr-3" />
                Quest
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('boost')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'boost' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/boost_dark.png" alt="Boost" className="w-6 h-6 mr-3" />
                Boost
              </button>
            </li>
            <li className="mb-2">
              <button onClick={() => setActiveTab('settings')} className={`w-full text-left flex items-center p-3 rounded-lg transition-colors duration-200 ${activeTab === 'settings' ? 'bg-gray-700' : 'hover:bg-gray-700'}`}>
                <img src="../assets/setting_dark.png" alt="Settings" className="w-6 h-6 mr-3" />
                Settings
              </button>
            </li>
          </ul>
        </nav>
        <div className="mt-auto">
          <div className={`text-center text-sm mb-2 ${macroStatus === 'started' ? 'text-green-400' : 'text-red-400'}`}>
            Status: {macroStatus.replace(/_/g, ' ')}
          </div>
          <button
            onClick={handleStartMacro}
            className="w-full py-3 mb-2 rounded-lg bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 transition-all duration-300 shadow-lg transform hover:scale-105"
            disabled={macroStatus === 'started'}
          >
            Start Macro (F1)
          </button>
          <button
            onClick={handleStopMacro}
            className="w-full py-3 rounded-lg bg-gradient-to-r from-red-500 to-rose-600 hover:from-red-600 hover:to-rose-700 transition-all duration-300 shadow-lg transform hover:scale-105"
            disabled={macroStatus === 'stopped' || macroStatus === 'not_running'}
          >
            Stop Macro (F3)
          </button>
        </div>
      </div>

      <div className="flex-1 flex flex-col">
        <div className="w-full h-10 bg-gray-800 flex items-center justify-end pr-4" style={{ WebkitAppRegion: 'drag' }}>
          <div className="flex" style={{ WebkitAppRegion: 'no-drag' }}>
            <button onClick={handleMinimize} className="w-8 h-8 flex items-center justify-center text-gray-400 hover:bg-gray-700 rounded-md transition-colors duration-200">
              —
            </button>
            <button onClick={handleMaximize} className="w-8 h-8 flex items-center justify-center text-gray-400 hover:bg-gray-700 rounded-md transition-colors duration-200">
              ◻
            </button>
            <button onClick={handleClose} className="w-8 h-8 flex items-center justify-center text-gray-400 hover:bg-red-500 hover:text-white rounded-md transition-colors duration-200">
              ✕
            </button>
          </div>
        </div>

        <main className="flex-1 p-8 overflow-auto">
          {renderContent()}
        </main>
      </div>
    </div>
  );
}

export default App;
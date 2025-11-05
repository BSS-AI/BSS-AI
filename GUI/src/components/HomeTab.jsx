import React, { useState, useEffect } from 'react';

function HomeTab() {
  const discord = (event) => {
    event.preventDefault();
    window.electron.openExternal('https://discord.gg/bssai');
  };

  return (
    <>
      <h2 className="text-3xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-cyan-400">Home</h2>
      <div className="bg-gray-800 p-6 rounded-lg shadow-xl">
        <h1 className="text-4xl font-bold mb-4" style={{ background: 'linear-gradient(to right, #f472b6, #a855f7, #60a5fa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
          Welcome to BSS AI!
        </h1>
        <div className="mb-6">
          <h2 className="text-3xl font-bold mb-2" style={{ background: 'linear-gradient(to right, #4ade80, #22d3ee, #3b82f6)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Free Edition
          </h2>
        </div>
        <div className="mb-6 p-4 bg-yellow-900/30 border border-yellow-500/50 rounded-lg">
          <p className="text-yellow-200 mb-3">
            <strong>⚠️ Development Notice:</strong> This app is currently in development and you WILL encounter bugs.
            If you find any issues, please report them to our Discord server.
          </p>
          <div className="flex items-center gap-3">
            <a
              onClick={discord}
              className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg transition-colors duration-200"
            >
              <svg
                onClick={discord}
                className="w-4 h-4 text-blue-400"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419-.0189 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z" />
              </svg>
              <span className="text-white font-medium">Join Discord</span>
            </a>
          </div>
        </div>
        <p className="mt-4 text-sm text-gray-400 mb-6">Version: alpha-v0.0.1</p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <div className="bg-gray-700 p-4 rounded-lg shadow-md">
            <h3 className="text-xl font-semibold mb-2 text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-teal-400">
              Updates
            </h3>
            <ul className="list-disc list-inside text-gray-300 text-sm">
              <li>Much improved AI Gathering System™</li>
              <li>Planters Plus</li>
              <li>Sticker Stack & Printer</li>
              <li>Bug Run and Bosses</li>
              <li>Vicous Hop+™</li>
              <li>Nectar Pot & Consender</li>
              <li>Blender</li>
              <li>Autobuff</li>
              <li>Bot Intergration</li>
              <li>Polar Bear Quests</li>
              <li>Huge Bug Fixes</li>
              <li>Major GUI Overhaul</li>
              <li>Active Dev Team??</li>
            </ul>
          </div>

          <div className="bg-gray-700 p-4 rounded-lg shadow-md">
            <h3 className="text-xl font-semibold mb-2 text-transparent bg-clip-text bg-gradient-to-r from-orange-300 to-red-400">
              Contributors
            </h3>
            <ul className="list-disc list-inside text-gray-300 text-sm">
              <li>Lead Dev - Slymi</li>
              <li>Lead Dev - money_mountain</li>
              <li>AI Gather - SniperThrilla</li>
              <li>AI Gather Improved - Slymi</li>
              <li>GUI - money_mountain</li>
              <li>AI Model - lvl18bubblebee</li>
              <li>Founder - dutchrailwayslover</li>
              <li>Testers - money_mountain, pog.01, slymih, xawer5k2k, zenvhm, mini_orphan, poor_cereal, schnu145</li>
              <li>Annotations - schnu145, poor_cereal, billythecooldude, 613ghost, buko0365, cxnnsored, zenvhm, ze_ws, boyboxer, ividdyy, symbol_101, gui64977alt, devkeyboard, mqnke., pog.01, slymih, z_zqcv, money_mountain</li>
            </ul>
          </div>
        </div>
        <p className="mt-4 text-sm text-gray-300 mb-2 text-center">❤ Dedicated to founder Bubble (lvl18bubblebee), who has unfortuantly passed. RIP 💙</p>
      </div>
    </>
  );
}

export default HomeTab;
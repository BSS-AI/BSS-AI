import React from 'react';
import ReactDOM from 'react-dom/client';
import ThemeEditorWindow from './components/ThemeEditorWindow';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <ThemeEditorWindow />
    </React.StrictMode>,
);

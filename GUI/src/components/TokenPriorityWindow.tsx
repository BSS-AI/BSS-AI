import React, { useState, useEffect } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragOverlay,
  DragStartEvent,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
  useSortable,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import Button from './UI/Button';

// List of tokens that should always be ignored and never shown in the UI.
const hardcodedIgnoreTokens = [
  "Balloon", "bd", "bomb", "scrath", "Golden Balloon",
  "Fuzz Bombs", "Fuzz Bomb", "Falling Coconut",
  "Honey Mark", "Falling Stars", "Saturator", "Pollen Mark", "Royal Jelly", "Royal Jelly Token"
];

const DEFAULT_IGNORE_TOKENS =
  "Balloon, bd, bomb, scrath, Treat Token, White Boost, Royal Jelly Token, Red Boost, Red Bomb, Honey Token, Impale, Golden Balloon, Fuzz Bombs, Fuzz Bomb, Festive Mark, Falling Coconut, Buzz Bomb, Beamstorm, Pollen Mark, Saturator, Honey Mark, Falling Stars";

const DEFAULT_PRIORITY_TOKENS =
  "Token Link:100, Focus, Haste, Summon Frog, Surprise Party, Inflate Balloons, Baby Love, Melody, Inspire, Mother Bear Morph, Science Bear Morph, Panda Bear Morph, Black Bear Morph, Brown Bear Morph, Polar Bear Morph, Blue Boost, Blue Bomb, Festive Gift, Beesmas Cheer, Festive Blessing, Blue Pulse, Blueberry Token, Pineapple Token, Strawberry Token, Sunflower Seed Token, Gumdrop Barrage, Honey Mark Token, Pollen Haze, Pollen Mark Token, Tabby Love, Glob, Scratch, Blue Bomb Sync, Snowflake Token, Snowglobe Shake";

const tokenIcons: { [key: string]: string } = {
  "Baby Love": "Baby_Love_Token.webp",
  "Beamstorm": "Beamstorm_Token.webp",
  "Beesmas Cheer": "Beesmas_Cheer_Token.webp",
  "Blue Bomb Sync": "Blue_Bomb_Sync_Token.webp",
  "Festive Blessing": "Festive_Blessing_Token.webp",
  "Festive Gift": "Festive_Gift_Token.webp",
  "Festive Mark": "Festive_Mark_Token.webp",
  "Fetch": "Fetch_Token.webp",
  "Flame Fuel": "Flame_Fuel_Token.webp",
  "Focus": "Focus_Token.webp",
  "Fuzz Bombs": "Fuzz_Bombs_Token.webp",
  "Glitch": "Glitch_Token.webp",
  "Glob": "Glob_Token.webp",
  "Gumdrop Barrage": "Gumdrop_Barrage_Token.webp",
  "Haste": "Haste_Token.webp",
  "Honey Token": "Honey_Token.webp",
  "Impale": "Impale_Token.webp",
  "Inferno": "Inferno_Token.webp",
  "Inflate Balloons": "Inflate_Balloon_Token.webp",
  "Inspire": "Inspire_Token.webp",
  "Map Corruption": "Map_Corruption_Token.webp",
  "Mark Surge": "Mark_Surge_Token.webp",
  "Mind Hack": "Mind_Hack_Token.webp",
  "Pollen Haze": "Pollen_Haze_Token.webp",
  "Puppy Love": "Puppy_Love_Token.webp",
  "Rage": "Rage_Token.webp",
  "Rain Cloud": "Rain_Cloud_Token.webp",
  "Red Boost": "Red_Boost_Token.webp",
  "Scratch": "Scratch_Token.webp",
  "Smile": "Smile_Token.webp",
  "Snowglobe Shake": "Snowglobe_Shake_Token.webp",
  "Summon Frog": "Summon_Frog_Token.webp",
  "Surprise Party": "Surprise_Party_Token.webp",
  "Tabby Love": "Tabby_Love_Token.webp",
  "Target Practice": "Target_Pratice_Token.webp",
  "Token Link": "Token_Link_Token.webp",
  "Tornado": "Tornado_Token.webp",
  "Triangulate": "Triangulate_Token.webp",
  "White Boost": "White_Boost_Token.webp",
  "Blueberry Token": "Blueberry.webp",
  "Melody": "Melody_Token_Repicture.webp",
  "Pineapple Token": "Pineapple.webp",
  "Royal Jelly Token": "Royal_Jelly.webp",
  "Snowflake Token": "Snowflake.webp",
  "Strawberry Token": "Strawberry.webp",
  "Sunflower Seed Token": "Sunflower_Seed.webp",
  "Treat Token": "Treat.webp",
  "Black Bear Morph": "black_bear.webp",
  "Blue Bomb": "blue_bomb.webp",
  "Blue Boost": "blue_boost.webp",
  "Blue Pulse": "blue_pulse.webp",
  "Brown Bear Morph": "brown_bear.webp",
  "Buzz Bomb": "buzz_bomb.webp",
  "Honey Mark Token": "honey_mark_token.webp",
  "Mother Bear Morph": "mother_bear.webp",
  "Panda Bear Morph": "panda_bear.webp",
  "Polar Bear Morph": "polar_bear.webp",
  "Pollen Mark Token": "pollen_mark_token.webp",
  "Red Bomb": "red_bomb.webp",
  "Science Bear Morph": "science_bear.webp"
};

const getTokenIcon = (name: string) => {
  return tokenIcons[name] ? `/assets/${tokenIcons[name]}` : null;
};

interface Token {
  id: string;
  name: string;
  value: string;
  ignored: boolean;
  priority: number;
}

interface Settings {
  [section: string]: {
    [key: string]: string;
  };
}

// Sortable Item Component
function SortableItem(props: { token: Token; toggleIgnore: (name: string) => void; handleValueChange: (name: string, val: string) => void }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: props.token.id, disabled: props.token.ignored });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.3 : 1,
    zIndex: isDragging ? 999 : 'auto',
  };

  const icon = getTokenIcon(props.token.name);
  const isRound = props.token.name.includes("Bear Morph");

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`group flex items-center p-3 rounded-xl transition-all duration-200 border
        ${props.token.ignored
          ? 'bg-background-secondary/50 border-glass-border text-text-muted'
          : 'bg-background-secondary border-glass-border hover:border-accent-primary/50 hover:shadow-lg hover:shadow-accent-primary/10'
        }
        ${!props.token.ignored ? 'cursor-grab active:cursor-grabbing' : ''}`}
      {...attributes}
      {...listeners}
    >
      <div className={`flex items-center justify-center w-8 h-8 transition-colors ${props.token.ignored ? 'text-text-muted' : 'text-text-secondary group-hover:text-accent-primary'}`}>
        {icon ? (
          <img src={icon} alt="" className={`w-8 h-8 object-contain ${props.token.ignored ? 'opacity-50 grayscale' : ''} ${isRound ? 'rounded-full' : ''}`} />
        ) : (
          !props.token.ignored && (
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
              <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
            </svg>
          )
        )}
      </div>
      <span className={`flex-grow font-medium text-sm ml-2 ${props.token.ignored ? 'line-through opacity-70' : 'text-text-primary'}`}>{props.token.name}</span>

      <div className="flex items-center" onPointerDown={(e) => e.stopPropagation()}>
        <div className="relative mr-3">
          <input
            type="text"
            placeholder="Value"
            value={props.token.value}
            onChange={(e) => props.handleValueChange(props.token.name, e.target.value)}
            disabled={props.token.ignored}
            className={`w-20 bg-background-tertiary text-right text-xs rounded-md py-1.5 px-2 border transition-colors focus:outline-none
              ${props.token.ignored
                ? 'border-transparent text-text-muted opacity-50'
                : 'border-glass-border text-accent-primary focus:border-accent-primary focus:ring-1 focus:ring-accent-primary'}`}
          />
        </div>
        <button
          onClick={() => props.toggleIgnore(props.token.name)}
          title={props.token.ignored ? 'Add to priority list' : 'Ignore this token'}
          className={`w-8 h-8 flex items-center justify-center rounded-full transition-all duration-200 shadow-sm
            ${props.token.ignored
              ? 'bg-status-success/10 text-status-success hover:bg-status-success hover:text-white'
              : 'bg-background-tertiary text-text-secondary hover:bg-status-error hover:text-white'}`}
        >
          {props.token.ignored ? (
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z" /></svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16"><path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z" /></svg>
          )}
        </button>
      </div>
    </div>
  );
}

// Item Component for Drag Overlay (Pure visual)
function ItemOverlay({ token }: { token: Token }) {
  const icon = getTokenIcon(token.name);
  const isRound = token.name.includes("Bear Morph");

  return (
    <div className="flex items-center p-3 rounded-xl bg-background-secondary shadow-2xl ring-2 ring-accent-primary scale-105 cursor-grabbing border border-accent-primary/30">
      <div className="flex items-center justify-center w-8 h-8 text-accent-primary">
        {icon ? (
          <img src={icon} alt="" className={`w-8 h-8 object-contain ${isRound ? 'rounded-full' : ''}`} />
        ) : (
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
            <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
          </svg>
        )}
      </div>
      <span className="flex-grow font-medium text-sm ml-2 text-text-primary">{token.name}</span>
      <div className="flex items-center">
        <input disabled type="text" value={token.value} className="w-20 bg-background-tertiary text-right text-xs rounded-md py-1.5 px-2 border border-accent-primary/30 text-accent-primary" />
        <div className="ml-3 w-8 h-8 bg-status-error rounded-full flex items-center justify-center text-white shadow-md">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16"><path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z" /></svg>
        </div>
      </div>
    </div>
  );
}

function TokenPriorityWindow() {
  const [tokens, setTokens] = useState<Token[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeId, setActiveId] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5, // Require slight movement to start drag, preventing accidental clicks
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  useEffect(() => {
    loadSettings();

    // Theme logic
    try {
      const storedTheme = localStorage.getItem('ui-theme') || 'dark';
      document.documentElement.classList.add(`theme-${storedTheme}`);
      document.documentElement.setAttribute('data-ui-theme', storedTheme);

      // Override global transparent background because this window might be opaque or handled differently
      // But actually, we want the BG color from the theme to be applied to the container.
      // The container has bg-background-primary, which relies on the theme class.
    } catch (err) {
      console.error('Failed to load theme:', err);
      document.documentElement.classList.add('theme-dark');
    }
  }, []);

  const loadSettings = async () => {
    try {
      const settings: Settings = await invoke('read_settings', { filePath: 'settings.ini' });

      let priorityTokensStr = settings.AIGather?.priority_tokens || '';
      let ignoreTokensStr = settings.AIGather?.ignore_tokens || '';

      if (!priorityTokensStr && !ignoreTokensStr) {
        priorityTokensStr = DEFAULT_PRIORITY_TOKENS;
        ignoreTokensStr = DEFAULT_IGNORE_TOKENS;
      }

      const allTokensFromSettings = new Set<string>();

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

      const priorityMap = new Map<string, { value: string; priority: number }>();
      if (priorityTokensStr) {
        priorityTokensStr.split(', ').forEach((tokenStr, index) => {
          if (!tokenStr) return;
          const [name, value] = tokenStr.split(':');
          priorityMap.set(name, { value: value || '', priority: index });
        });
      }

      const ignoreSet = new Set(ignoreTokensStr ? ignoreTokensStr.split(', ').filter(Boolean) : []);

      const initialTokens: Token[] = allAvailableTokens.map(name => ({
        id: name, // Use name as ID since it's unique
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
      setLoading(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setLoading(false);
    }
  };

  const handleValueChange = (tokenName: string, newValue: string) => {
    setTokens((items) =>
      items.map((t) => (t.name === tokenName ? { ...t, value: newValue.replace(/[^0-9]/g, '') } : t))
    );
  };

  const toggleIgnore = (tokenName: string) => {
    setTokens((items) => {
      const newItems = items.map(t => t.name === tokenName ? { ...t, ignored: !t.ignored } : t);
      // Re-sort after toggling
      return newItems.sort((a, b) => {
        if (a.ignored && !b.ignored) return 1;
        if (!a.ignored && b.ignored) return -1;
        // Maintain relative order if possible, or fallback to index if needed (simplified here)
        return 0;
      });
    });
  };

  const handleDragStart = (event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      setTokens((items) => {
        const oldIndex = items.findIndex((item) => item.id === active.id);
        const newIndex = items.findIndex((item) => item.id === over.id);

        // Don't allow dropping onto ignored items or moving ignored items (though UI prevents drag start)
        if (items[newIndex].ignored || items[oldIndex].ignored) return items;

        return arrayMove(items, oldIndex, newIndex);
      });
    }

    setActiveId(null);
  };

  const saveChanges = async () => {
    try {
      const priorityList = tokens
        .filter(t => !t.ignored)
        .map(t => (t.value ? `${t.name}:${t.value}` : t.name));

      const userIgnoredTokens = tokens.filter(t => t.ignored).map(t => t.name);
      const combinedIgnoreList = [...new Set([...hardcodedIgnoreTokens, ...userIgnoredTokens])];

      await invoke('write_settings', {
        section: 'AIGather',
        key: 'priority_tokens',
        value: priorityList.join(', '),
        filePath: 'settings.ini'
      });

      await invoke('write_settings', {
        section: 'AIGather',
        key: 'ignore_tokens',
        value: combinedIgnoreList.join(', '),
        filePath: 'settings.ini'
      });

      await getCurrentWindow().close();
    } catch (err) {
      console.error('Failed to save settings:', err);
    }
  };

  const cancelChanges = async () => {
    await getCurrentWindow().close();
  };

  const minimizeWindow = async () => {
    await getCurrentWindow().minimize();
  };

  if (loading) return <div className="flex items-center justify-center h-screen text-white bg-background">Loading...</div>;
  if (error) return <div className="flex items-center justify-center h-screen text-status-error bg-background">Error: {error}</div>;

  const activeToken = activeId ? tokens.find(t => t.id === activeId) : null;
  const firstIgnoredIndex = tokens.findIndex(t => t.ignored);

  return (
    <div className="h-screen flex flex-col bg-background text-text-primary font-sans">
      <div className="w-full h-10 bg-background-secondary flex items-center justify-between pr-2 border-b border-glass-border" data-tauri-drag-region>
        <span className="ml-4 text-sm font-semibold text-text-secondary">Token Priority Editor</span>
        <div className="flex">
          <button onClick={minimizeWindow} className="w-8 h-8 flex items-center justify-center text-text-secondary hover:bg-background-tertiary hover:text-text-primary rounded-md transition-colors duration-200">
            —
          </button>
          <button onClick={cancelChanges} className="w-8 h-8 flex items-center justify-center text-text-secondary hover:bg-status-error hover:text-white rounded-md transition-colors duration-200">
            ✕
          </button>
        </div>
      </div>

      <div className="flex-1 p-6 overflow-y-auto">
        <h1 className="text-2xl font-bold mb-2 text-text-primary tracking-tight">
          Token Priority & Ignore List
        </h1>
        <p className="text-sm text-text-secondary mb-6">
          Drag prioritized tokens to reorder them. Higher is better.
        </p>

        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragStart={handleDragStart}
          onDragEnd={handleDragEnd}
        >
          <SortableContext
            items={tokens.map(t => t.id)}
            strategy={verticalListSortingStrategy}
          >
            <div className="flex flex-col gap-2 pb-4">
              {tokens.map((token, index) => (
                <React.Fragment key={token.id}>
                  {index === firstIgnoredIndex && (
                    <div className="text-center my-4">
                      <span className="text-sm font-bold text-text-muted uppercase tracking-wider">Ignored Tokens</span>
                      <div className="w-full h-px bg-glass-border mt-2"></div>
                    </div>
                  )}
                  <SortableItem
                    token={token}
                    toggleIgnore={toggleIgnore}
                    handleValueChange={handleValueChange}
                  />
                </React.Fragment>
              ))}
            </div>
          </SortableContext>

          <DragOverlay>
            {activeToken ? <ItemOverlay token={activeToken} /> : null}
          </DragOverlay>
        </DndContext>
      </div>

      <div className="p-4 bg-background-secondary flex gap-4 border-t border-glass-border">
        <Button variant="primary" onClick={saveChanges} className="flex-1 py-3 text-lg">
          Save & Close
        </Button>
        <Button variant="secondary" onClick={cancelChanges} className="flex-1 py-3 text-lg">
          Cancel
        </Button>
      </div>
    </div>
  );
}

export default TokenPriorityWindow;

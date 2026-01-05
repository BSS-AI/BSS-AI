import React, { useState } from 'react';
import { createPortal } from 'react-dom';
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

const actionIcons: { [key: string]: string } = {
  "Planters": "planter_dark.webp",
  "Collect": "collect_dark.webp",
  "Kill": "kill_dark.webp",
  "Quest": "quest_dark.webp",
  "Gather": "gather_dark.webp",
  "Vichop": "vichop_dark.webp"
};

function getActionIcon(action: string) {
  return actionIcons[action] ? `/assets/${actionIcons[action]}` : null;
}

interface ActionPriorityListProps {
  actions: string[];
  onChange: (newOrder: string[]) => void;
}

function SortableActionItem(props: { action: string; position: number }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: props.action });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.3 : 1,
    zIndex: isDragging ? 999 : 'auto',
  };

  const icon = getActionIcon(props.action);

  return (
    <div
      ref={setNodeRef}
      style={style}
      className="group flex items-center gap-3 p-3 rounded-lg bg-background-secondary border border-glass-border hover:border-accent-primary/50 transition-all duration-200 cursor-grab active:cursor-grabbing"
      {...attributes}
      {...listeners}
    >
      {/* Number Badge */}
      <div className="w-7 h-7 rounded-full bg-background-tertiary border border-glass-border flex items-center justify-center shrink-0 group-hover:border-accent-primary group-hover:text-accent-primary transition-colors text-xs font-bold text-text-secondary">
        {props.position}
      </div>

      {/* Icon */}
      {icon && (
        <div className="flex items-center justify-center w-8 h-8">
          <img src={icon} alt={props.action} className="w-8 h-8 object-contain" />
        </div>
      )}

      {/* Action Name */}
      <span className="flex-grow font-medium text-sm text-text-primary">
        {props.action}
      </span>

      {/* Drag Handle Icon */}
      <div className="text-text-muted group-hover:text-accent-primary transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
          <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
        </svg>
      </div>
    </div>
  );
}

// Item Component for Drag Overlay
function ActionItemOverlay({ action, position }: { action: string; position: number }) {
  const icon = getActionIcon(action);

  return (
    <div className="flex items-center gap-3 p-3 rounded-lg bg-background-secondary shadow-2xl ring-2 ring-accent-primary scale-105 cursor-grabbing border border-accent-primary/30">
      <div className="w-7 h-7 rounded-full bg-background-tertiary border border-accent-primary flex items-center justify-center shrink-0 text-xs font-bold text-accent-primary">
        {position}
      </div>
      {icon && (
        <div className="flex items-center justify-center w-8 h-8">
          <img src={icon} alt={action} className="w-8 h-8 object-contain" />
        </div>
      )}
      <span className="flex-grow font-medium text-sm text-text-primary">
        {action}
      </span>
      <div className="text-accent-primary">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
          <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
        </svg>
      </div>
    </div>
  );
}

function ActionPriorityList({ actions, onChange }: ActionPriorityListProps) {
  const [activeId, setActiveId] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragStart = (event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      const oldIndex = actions.indexOf(active.id as string);
      const newIndex = actions.indexOf(over.id as string);
      const newOrder = arrayMove(actions, oldIndex, newIndex);
      onChange(newOrder);
    }

    setActiveId(null);
  };

  const activeAction = activeId ? actions.find(a => a === activeId) : null;
  const activePosition = activeId ? actions.indexOf(activeId) + 1 : 0;

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <SortableContext
        items={actions}
        strategy={verticalListSortingStrategy}
      >
        <div className="flex flex-col gap-2">
          {actions.map((action, index) => (
            <SortableActionItem
              key={action}
              action={action}
              position={index + 1}
            />
          ))}
        </div>
      </SortableContext>

      {createPortal(
        <DragOverlay>
          {activeAction ? <ActionItemOverlay action={activeAction} position={activePosition} /> : null}
        </DragOverlay>,
        document.body
      )}
    </DndContext>
  );
}

export default ActionPriorityList;

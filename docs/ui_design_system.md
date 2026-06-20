# UI Design System

## Direction

Use Flutter Material 3 with a simple, modern, stylish, intuitive glassmorphism-inspired interface.

The design should feel calm, readable, and useful. Avoid visual noise.

## Phase 2 implementation status

The mobile scaffold includes:

- Material 3 enabled through `ThemeData(useMaterial3: true)`.
- Green, ink, and light neutral seed palette.
- Soft two-color login background.
- Reusable blurred `GlassPanel` with readable opacity and 8px radius.
- Consistent 8px control/card radius.
- Large accessible sign-in controls and restrained motion.

This is a foundation placeholder, not the final screen system.

## Keywords

- clean
- modern
- simple
- stylish
- glassmorphism
- soft blur
- rounded cards
- subtle gradients
- large readable text
- clear action buttons
- low clutter
- intuitive role-based navigation

## Visual language

Use:

- Soft gradient backgrounds.
- Translucent panels where readability stays strong.
- Rounded cards.
- Subtle shadows.
- Clear Material 3 buttons.
- Consistent spacing.
- High-contrast text.
- Status colors used sparingly.

Avoid:

- Low-contrast blurred panels.
- Tiny text.
- Too many colors.
- Heavy animation.
- Cluttered dashboards.
- Dark text on dark blur.
- Decorative effects that reduce clarity.

## Role styling

Keep one coherent app identity while allowing subtle role cues:

- Passenger: friendly trip-search focus.
- Agency: dense but calm operational views.
- Taxi dispatcher: queue and assignment clarity.
- Taxi driver: large ride actions and minimal distraction.
- Super admin: auditability and system overview.

## Components

Prefer:

- Material 3 `NavigationBar` for bottom navigation.
- Role-specific shells after login.
- Large tappable action buttons.
- Cards for booking, trip, ride, and manifest summaries.
- Chips for statuses and filters.
- Sheets/dialogs for focused tasks.

## Accessibility

- Keep text readable on small Android screens.
- Keep tap targets comfortable.
- Do not rely on color alone for status.
- Maintain strong contrast on translucent surfaces.

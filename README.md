# LCARS.ahk Terminal Interface Engine (v2)
A fully responsive, modular Star Trek LCARS terminal interface and desktop environment manager for Windows built with AutoHotkey v2.

An authentic, fully functional Star Trek LCARS-inspired desktop environment manager built from the ground up using **AutoHotkey v2**. 

Designed as a multi-layered, non-activating GUI stack (`WS_EX_NOACTIVATE`), this engine acts as a custom desktop skin and workstation launcher without stealing keyboard focus or interfering with Windows auto-hide taskbars.

## Key Features

* **Split-Layer GUI Architecture:** Click-through background frame canvas (`+E0x20`) paired with interactive foreground overlay modules.
* **Dynamic Taskbar Dock & Sidebar:** Real-time window process tracking and re-indexing using Windows Shell Hooks with isolated chroma-keying (`COLOR_DOCK_BG`).
* **Drag-and-Drop Shortcut Grid:** Configurable launcher matrix supporting dynamic font scaling, tile color cycling, and interactive deletion zones.
* **GDI+ Vector System Controls:** Crisp, scaled vector UI controls for system termination, viewport snapping, and desktop matrix realignment.
* **System Telemetry Monitoring:** Live WMI performance tracking for CPU, RAM, Network throughput, and Drive space usage.
* **Non-Intrusive Volume & Clock Widgets:** Direct AHK v2 native hardware hooks for audio control and dynamic date/time format toggling.
* **Smart Viewport Snapper:** Automatic active-window caching (`~LButton` hooks) to snap application windows clean into the central LCARS viewing viewport.

# Battle UI Customizer

Install the BattleUICustomizer folder in your gen1recomp mods folder and enable it. Supports Red, Blue, Yellow, Gold, Silver, Crystal, Ruby, Sapphire, Emerald, FireRed and LeafGreen on 0.3.54 through 0.3.x.

In Options, select BATTLE UI (VANILLA / EMERALD) and BATTLE OPACITY (0–100%, in 10% steps). BATTLE MENU WIDTH selects NORMAL / FULL WIDTH. BATTLE MENU ALIGN selects LEFT / CENTER / RIGHT at normal width. FULL WIDTH stretches the entire command panel, its labels and cursor across the bottom. Defaults: vanilla, 100% opacity, normal width, right alignment. Settings persist per game. Disable the mod to restore native rendering.

EMERALD reuses battle frame art from your imported Emerald cache when available, with native text contrast and geometry. Gen 3 single healthboxes also use your imported Emerald art. Import Emerald through the launcher before starting another game to make its art available. Without that cache, an original Emerald-inspired palette and double frame is used. No Emerald command layout or battle rules are transplanted. Text, cursors, HP values and battle behavior stay native. Opacity affects command/message panels; Gen 3 also supports healthbox backplates. Gen 1/2 health HUDs remain native.

KIM1025 can remain enabled: this mod does not replace its background or sprite resolvers. Menu Customizer can also remain enabled; battle panel styling is owned by this mod.

No ROM, save, or extracted game assets are included.

## 1.0.1 rendering fixes

Unused full-width message boxes are removed behind Gen 1/2 command and move selection. Move TYPE/PP panels still display useful move details. Native border-repair tiles and opaque text paper no longer cover the custom frame. Panels are drawn into an opaque intermediate surface and composited once at the selected opacity, so overlapping layers do not accumulate opacity. Text remains opaque. True-color panels bypass inherited palette shaders, and the Gen 1 landscape renderer now uses the same style and transparency settings.

Validation includes 22 all-game KIM1025 sandbox/settings fixtures and 26 real LÖVE pixel checks for overlap opacity, empty box removal, move border cleanup, text opacity, landscape palette handling and graphics state restoration. These fixtures do not replace live testing on iOS.

## 1.0.2

Removes the orphan bottom border of the Gen 1/2 move-info box, which can remain visible beside move selection when the rest of that box is clipped out. Move TYPE/PP text remains native, without a separate backplate. Panels now register as true-color regions for final frame presentation, so the later HUD palette pass cannot recolor them. Other HUD regions retain their native palette handling.

The manifest points to `Bentley734/BattleUICustomizer`. Validation: the 22 all-game fixtures and 30 real LÖVE pixel cases, including transparent pixels in the orphan-border region and color preservation through a simulated final palette pass.

## 1.0.3

Landscape panel color protection now follows the actual target canvas and transformed panel coordinates, including scaled and shifted HUDs. The final palette blit excludes panel regions from its native palette zones and draws each protected region once. This avoids leaving a tinted copy underneath translucent panels. Protection resets each frame and applies to panel regions only. Validation: 22 all-game fixtures and 46 real LÖVE pixel cases, with translated/scaled panels and alpha blending in the final palette pass.

## 1.0.4

Fixes Gen 1's intermediate `BattleState.drawZonePass`, which recolors the battle background canvas before final frame presentation. Protected UI regions are excluded from those native palette zones and redrawn once after the overlapping native zones finish, using premultiplied alpha. The native field palette remains active. Tests now execute the actual engine battle-zone and canvas-blit function bodies, including both UI styles and screen shake, rather than only a simulated final palette pass.

## 1.0.5

Adds BATTLE MENU WIDTH (NORMAL / FULL WIDTH) and BATTLE MENU ALIGN (LEFT / CENTER / RIGHT). NORMAL and RIGHT are the defaults. FULL WIDTH stretches the Fight/PKMN/Item/Run menu across the bottom; at NORMAL width the alignment moves the entire menu without stretching it. Alignment is retained while full width is selected.

Works with VANILLA and EMERALD styles, including Gen 1 landscape, across all eleven games. Labels and the selection cursor follow the panel. Unused action-prompt panels are removed; move selection and message layout stay as before. Gen 1/2 special Safari/contest menus retain their native layout. Opacity and landscape color protection remain supported.

Validation: 22 all-game KIM1025 sandbox/settings fixtures and 146 real LOVE pixel cases, including left/center/right/full-width placement, transformed/scaled menus, opaque text, uniform panel alpha and palette preservation. Fixture validation does not replace live iOS testing.

Replace the previous BattleUICustomizer folder and restart. Enable only one copy.

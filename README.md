# Battle UI Customizer

Install the BattleUICustomizer folder in your gen1recomp mods folder and enable it. Supports Red, Blue, Yellow, Gold, Silver, Crystal, Ruby, Sapphire, Emerald, FireRed and LeafGreen on 0.3.54 through 0.3.x.

In Options, open BATTLE UI CUSTOMIZER, then select BATTLE UI (VANILLA / EMERALD) and BATTLE OPACITY (0â€“100%, in 10% steps). BATTLE MENU WIDTH selects NORMAL / FULL WIDTH. BATTLE MENU ALIGN selects LEFT / CENTER / RIGHT at normal width for command and move selection. FULL WIDTH expands the panel across the available bottom area without stretching text. Command columns spread across the new width. Gen 1/2 move menus put names on the left and selected TYPE and remaining/max PP in an inset on the right. Long names fit proportionally inside normal-width panels. Gen 3 retains its native move grid and PP/type band. Defaults: vanilla, 100% opacity, normal width, right alignment. Settings persist per game. Disable the mod to restore native rendering.

EMERALD reuses battle frame art from your imported Emerald cache when available, with native text contrast and geometry. Gen 3 single healthboxes also use your imported Emerald art. Import Emerald through the launcher before starting another game to make its art available. Without that cache, an original Emerald-inspired palette and double frame is used. No Emerald command layout or battle rules are transplanted. Text, cursors, HP values and battle behavior stay native. Opacity affects command/message panels; Gen 3 also supports healthbox backplates. Gen 1/2 health HUDs remain native.

KIM1025 can remain enabled: this mod does not replace its background or sprite resolvers. Menu Customizer can also remain enabled; battle panel styling is owned by this mod.

No ROM, save, or extracted game assets are included.

## 1.0.1 rendering fixes

Unused full-width message boxes are removed behind Gen 1/2 command and move selection. Move TYPE/PP panels still display useful move details. Native border-repair tiles and opaque text paper no longer cover the custom frame. Panels are drawn into an opaque intermediate surface and composited once at the selected opacity, so overlapping layers do not accumulate opacity. Text remains opaque. True-color panels bypass inherited palette shaders, and the Gen 1 landscape renderer now uses the same style and transparency settings.

Validation includes 22 all-game KIM1025 sandbox/settings fixtures and 26 real LÃ–VE pixel checks for overlap opacity, empty box removal, move border cleanup, text opacity, landscape palette handling and graphics state restoration. These fixtures do not replace live testing on iOS.

## 1.0.2

Removes the orphan bottom border of the Gen 1/2 move-info box, which can remain visible beside move selection when the rest of that box is clipped out. Move TYPE/PP text remains native, without a separate backplate. Panels now register as true-color regions for final frame presentation, so the later HUD palette pass cannot recolor them. Other HUD regions retain their native palette handling.

The manifest points to `Bentley734/BattleUICustomizer`. Validation: the 22 all-game fixtures and 30 real LÃ–VE pixel cases, including transparent pixels in the orphan-border region and color preservation through a simulated final palette pass.

## 1.0.3

Landscape panel color protection now follows the actual target canvas and transformed panel coordinates, including scaled and shifted HUDs. The final palette blit excludes panel regions from its native palette zones and draws each protected region once. This avoids leaving a tinted copy underneath translucent panels. Protection resets each frame and applies to panel regions only. Validation: 22 all-game fixtures and 46 real LÃ–VE pixel cases, with translated/scaled panels and alpha blending in the final palette pass.

## 1.0.4

Fixes Gen 1's intermediate `BattleState.drawZonePass`, which recolors the battle background canvas before final frame presentation. Protected UI regions are excluded from those native palette zones and redrawn once after the overlapping native zones finish, using premultiplied alpha. The native field palette remains active. Tests now execute the actual engine battle-zone and canvas-blit function bodies, including both UI styles and screen shake, rather than only a simulated final palette pass.

## 1.0.5

Adds BATTLE MENU WIDTH (NORMAL / FULL WIDTH) and BATTLE MENU ALIGN (LEFT / CENTER / RIGHT). NORMAL and RIGHT are the defaults. FULL WIDTH stretches the Fight/PKMN/Item/Run menu across the bottom; at NORMAL width the alignment moves the entire menu without stretching it. Alignment is retained while full width is selected.

Works with VANILLA and EMERALD styles, including Gen 1 landscape, across all eleven games. Labels and the selection cursor follow the panel. Unused action-prompt panels are removed; move selection and message layout stay as before. Gen 1/2 special Safari/contest menus retain their native layout. Opacity and landscape color protection remain supported.

Validation: 22 all-game KIM1025 sandbox/settings fixtures and 146 real LOVE pixel cases, including left/center/right/full-width placement, transformed/scaled menus, opaque text, uniform panel alpha and palette preservation. Fixture validation does not replace live iOS testing.

Replace the previous BattleUICustomizer folder and restart. Enable only one copy.

## 1.0.6

BATTLE MENU WIDTH and BATTLE MENU ALIGN now apply to the move-selection panel as well as Fight/PKMN/Item/Run. NORMAL retains the panel width and allows LEFT, CENTER or RIGHT (default). FULL WIDTH fills the available bottom-menu area.

Panel backgrounds expand, but text and selection cursors retain their original size. Command columns are spaced across the wider panel; move names shift with their panel without horizontal distortion. Wide/GBA move layouts that already fill their available area retain the useful PP/type band. VANILLA and EMERALD styles, saved settings, opacity and landscape palette protection are retained.

Validated with 22 eleven-game KIM1025 sandbox/settings fixtures and 218 real LOVE pixel cases, including move-panel alignment, normal-width text inside expanded command/move panels, scaled/translated rendering, opacity and palette preservation. These fixtures do not replace live iOS testing.

Replace the previous BattleUICustomizer folder and restart. Enable only one copy.

## 1.0.7

Gen 1/2 move selection now has one outer moves panel, with names and selection/swap cursors on the left and the selected move type and remaining/max PP in a compact inset on the right. Gen 1 wide mode keeps its native two-column navigation. PP Ups, empty slots, zero PP, custom type names and disabled moves are supported. The list and inset move together with LEFT/CENTER/RIGHT alignment and FULL WIDTH. Long text fits uniformly; no text is stretched horizontally.

The old TYPE/PP overlay, its paper and border patches are completely removed. Gen 1 also bypasses the original move-info sprite clipping, so the player's lower sprite pixels remain visible while selecting a move. Other battle phases, inputs and special menus retain their native behavior. Both VANILLA and EMERALD compose the outer frame and inset once at the selected opacity, with landscape palette protection retained. Gen 3 continues to use its existing bottom move grid and details band.

Validation: 44 eleven-game sandbox/settings cases on engines 0.3.54 and 0.3.58, including KIM1025 1.6.31; 258 real LOVE graphics cases covering both styles, normal/full width, alignment, opacity, selected PP/type, PP Ups, disabled moves, final palette passes and the actual engine sprite-clipping function. Visual review used extracted Blue glyphs locally; no extracted assets are packaged. This is fixture validation, not live iOS testing.

Replace the previous BattleUICustomizer folder and restart. Enable only one copy.

## 1.0.8

Groups BATTLE UI, BATTLE OPACITY, BATTLE MENU WIDTH and BATTLE MENU ALIGN into one BATTLE UI CUSTOMIZER submenu. Gen 1/2 use the native list screen, while Gen 3 uses a child page in its native options menu. Existing setting keys and saved values are retained. B returns to the parent; Gen 1/2 also provide BACK.

Started from GitHub latest 1.0.7 with release/source byte verification. Validation: 22 all-eleven-game sandbox/submenu/settings fixtures with KIM1025 1.7.21, including four controls, setting persistence, menu entry, back navigation, theme and disabling. Rendering code is unchanged.

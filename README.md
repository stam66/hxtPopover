# hxtPopover

A popover for [HyperXTalk](https://github.com/emily-elizabeth/HyperXTalk): a rounded bubble with an arrow that points at something, with text inside it or your own controls on top of it. It is a widget, so everything is set from the property inspector or from script.

![Popovers with arrows on each side, plain and styled text, and one used as a backdrop for a field](docs/popovers.png)

It is the successor to [skPopover](https://github.com/stam66/skPopover), which did the same job with a group of controls.

## Contents

- [Installing](#installing)
- [Two ways to use it](#two-ways-to-use-it)
- [A popover on the card](#a-popover-on-the-card)
- [A popover as a popup](#a-popover-as-a-popup)
- [Text](#text)
- [Properties](#properties)
- [Dark mode](#dark-mode)
- [Building from source](#building-from-source)
- [Limitations](#limitations)

## Installing

1. Download `com.hyperxtalk.widget.popover.lce` from the [latest release](https://github.com/stam66/hxtPopover/releases/latest).
2. In HyperXTalk, open **Tools > Extension Manager** and install the file.
3. Quit and reopen HyperXTalk if you are replacing an earlier version.

Popover then appears in the Tools palette, and its properties are in the Dictionary.

## Two ways to use it

| | On the card | As a popup |
|---|---|---|
| What it is | A widget you place on the card, hidden until needed | A floating window created by the `popup widget` command |
| Content | Its own text, or your controls placed over it | Its own text only |
| Set up | In the property inspector | In script, each time it is shown |
| Shown and hidden by | Your handlers | The command shows it; a click elsewhere closes it |
| Can extend past the stack window | No | Yes |
| Good for | Details panels with fields and buttons, callouts, coach marks | Quick notes and tips with nothing to set up |

## A popover on the card

Drag a Popover from the Tools palette onto the card, set it up in the property inspector, and hide it (untick **Visible**). Your scripts then show it pointing at something and hide it again.

### Handlers to show and hide

Put these in the card or stack script:

```
-- Shows a popover with its arrow pointing at a control.
-- pArrowSide is the side of the popover its arrow is on: "left" puts the
-- popover to the right of the control, "top" below it, and so on.
command showPopover pPopover, pControl, pArrowSide
   if pArrowSide is empty then put "left" into pArrowSide
   set the arrowSide of pPopover to pArrowSide
   set the anchor of pPopover to pControl
   set the layer of pPopover to top
   show pPopover
end showPopover

-- Hides every popover on the card.
command hidePopovers
   repeat with i = 1 to the number of widgets of this card
      if the kind of widget i is "com.hyperxtalk.widget.popover" then
         hide widget i
      end if
   end repeat
end hidePopovers

-- A click on the card dismisses any popover.
on mouseDown
   hidePopovers
   pass mouseDown
end mouseDown
```

Then, in a button:

```
on mouseUp
   showPopover the long id of widget "Popover", the long id of me, "left"
end mouseUp
```

To make the same button close the popover on a second click:

```
on mouseUp
   if the visible of widget "Popover" then
      hide widget "Popover"
   else
      showPopover the long id of widget "Popover", the long id of me, "left"
   end if
end mouseUp
```

The card only receives `mouseDown` for clicks on the card itself and on controls that pass it. If a click on another control should also dismiss the popover, call `hidePopovers` from that control.

### Pointing at something

`anchor` and `arrowLoc` move the popover, without resizing it, so that its arrow points where you want.

**At a control.** Set the `anchor` to a reference to the control. The arrow goes to the middle of the edge that faces the popover:

```
set the arrowSide of widget "Popover" to "left"
set the anchor of widget "Popover" to the long id of button "Info"
```

| Popover appears | `arrowSide` |
|---|---|
| to the right of the control | `left` |
| to the left | `right` |
| below | `top` |
| above | `bottom` |

**At a rectangle.** For things that are not controls, such as a line of a field, give the `anchor` a rectangle:

```
set the anchor of widget "Popover" to the formattedRect of line 3 of field "List"
```

**At a point.** Set the `arrowLoc`; the tip of the arrow lands exactly there:

```
set the arrowLoc of widget "Popover" to the clickLoc
```

Set the `arrowSide` first in each case. The popover is placed once, when the property is set, and does not follow the control if it moves afterwards.

### Staying inside the window

If the popover would run off the card, it is moved back along the arrow's side and the arrow slides along the popover to match, so it still points at the same place. A popover to the right of a row near the bottom of the window ends up higher, with its arrow nearer its bottom corner.

- `arrowPosition` keeps the value you set and is used again the next time the popover is placed.
- The arrow stops where the rounded corner begins, so a target very close to the edge of the card can still leave the popover overhanging.
- The popover is not moved to the other side of its target.
- For a control inside a group, such as a row in a scrolling list, only the visible part of it is pointed at.
- Set `keepInWindow` to false to turn this off.

### Putting your own controls in a popover

A widget cannot contain other controls, so the popover acts as a backdrop: leave its text empty and place your controls over it. The `contentRect` property is the area inside the bubble, in card coordinates.

Put your controls in a group of their own, and show the two together:

```
command showDetails pControl
   showPopover the long id of widget "Popover", pControl, "left"
   set the topLeft of group "Details" to item 1 to 2 of the contentRect of widget "Popover"
   set the layer of group "Details" to top
   show group "Details"
end showDetails

command hideDetails
   hide group "Details"
   hide widget "Popover"
end hideDetails
```

For a single field, `set the rect of field "Details" to the contentRect of widget "Popover"` fits it to the bubble.

## A popover as a popup

The `popup widget` command shows a popover in a floating window of its own, with nothing on the card. Pass its size, text and any other properties in an array:

```
on mouseUp
   local tProps
   put "0,0,240,110" into tProps["rect"]
   put "Details about this item, wrapped to fit the popover." into tProps["text"]
   put "left" into tProps["arrowSide"]
   put the systemAppearance into tProps["hxtAppearance"]

   popup widget "com.hyperxtalk.widget.popover" \
         at (the right of me + 4), item 2 of the loc of me \
         with properties tProps
end mouseUp
```

The location is where the arrow points. For other widgets it is the top left of the popup; the popover moves its window so that no offsets are needed. The `+ 4` leaves a small gap between the button and the arrow.

| Popover appears | `arrowSide` | `at` |
|---|---|---|
| to the right | `left` | `(the right of me + 4), item 2 of the loc of me` |
| to the left | `right` | `(the left of me - 4), item 2 of the loc of me` |
| below | `top` | `item 1 of the loc of me, (the bottom of me + 4)` |
| above | `bottom` | `item 1 of the loc of me, (the top of me - 4)` |

Things to know:

- The popup closes when the user clicks anywhere outside it, and the handler waits until then. There is nothing to hide.
- It shows text only. Use `text` or `styledText` in the array, not both.
- A popup starts with the light colours each time. Pass `hxtAppearance` as above, or set `fillColor` and `fontColor`, to match dark mode.
- It can extend beyond the stack's window, and is not kept on the screen.
- `anchor`, `arrowLoc` and `keepInWindow` have no effect in a popup.

## Text

Type and style the text in the **Contents** tab of the property inspector, as for a field, or set it from script:

```
set the text of widget "Popover" to "Plain text"
set the styledText of widget "Popover" to the styledText of field "Source"
```

- Setting `text` removes any styles.
- Text with no style of its own uses the widget's `textFont`, `textSize` and `textStyle`, and its `fontColor`.
- The font, size, colour, background colour, bold, italic, underline and strikeout of each run are drawn, and the alignment of each paragraph.
- Links, lists, indents, tabs, images and superscript or subscript are kept but not drawn.
- Text is wrapped to the content area and clipped if it does not fit.

## Properties

### Appearance

| Property | Values | Default |
|---|---|---|
| `arrowSide` | `left`, `top`, `right`, `bottom`, `none` | `bottom` |
| `arrowPosition` | 0 to 100, percent along the side | 50 |
| `arrowSize` | pixels: how far the arrow sticks out | 12 |
| `arrowWidth` | pixels: the width of the arrow's base | 24 |
| `cornerRadius` | pixels | 10 |
| `lineSize` | pixels, 0 for no outline | 1 |
| `contentMargin` | pixels between the outline and the content | 10 |
| `showShadow` | `true`, `false` | `true` |
| `fillColor`, `lineColor`, `fontColor` | `r,g,b` or `r,g,b,a`, each 0 to 255 | white, grey, black |
| `followAppearance` | `true`, `false`: whether default colours follow dark mode | `true` |

### Text

| Property | Values | Default |
|---|---|---|
| `text` | plain text | empty |
| `styledText` | array, in the layout of a field's `styledText` | empty |
| `textAlign` | `left`, `center`, `right` | `center` |
| `textVerticalAlign` | `top`, `center`, `bottom` | `center` |

### Placing

| Property | Values | Default |
|---|---|---|
| `anchor` | a control reference or `left,top,right,bottom`: points the arrow at it | |
| `arrowLoc` | `x,y` in card coordinates: the tip of the arrow | |
| `keepInWindow` | `true`, `false`: whether `anchor` and `arrowLoc` keep the popover on the card | `true` |
| `contentRect` | read-only: `left,top,right,bottom` of the area inside the bubble | |
| `hxtAppearance` | `light`, `dark`: see Dark mode | `light` |

`anchor`, `arrowLoc` and `hxtAppearance` are not saved with the stack.

Notes:

- The text colour is `fontColor`. `textColor` is the engine's own synonym for `foregroundColor` and does not reach the widget.
- Sizes and `arrowPosition` are kept as whole numbers; `lineSize` keeps one decimal place, so 0.5 and 1.5 work.
- With `showShadow` on, the bubble is drawn 8 pixels inside the widget's rectangle to leave room for the shadow.

## Dark mode

![The same popovers in a dark appearance](docs/popovers-dark.png)

A popover whose colours are still at their defaults is drawn with dark defaults when its `hxtAppearance` is `dark`. Colours you have set are drawn as set, and default text only turns light while the fill is at its default too. Set `followAppearance` to false to keep the light defaults.

A widget cannot read the system appearance itself, and `hxtAppearance` is not saved, so the stack tells its popovers when it opens and when the appearance changes:

```
on preOpenStack
   updatePopovers the systemAppearance
end preOpenStack

on systemAppearanceChanged pMode
   updatePopovers pMode
   pass systemAppearanceChanged
end systemAppearanceChanged

command updatePopovers pMode
   repeat with i = 1 to the number of widgets of this card
      if the kind of widget i is "com.hyperxtalk.widget.popover" then
         set the hxtAppearance of widget i to pMode
      end if
   end repeat
end updatePopovers
```

While you edit in the IDE, the IDE does this for you only in HyperXTalk builds that include [PR 599](https://github.com/emily-elizabeth/HyperXTalk/pull/599), which is open at the time of writing. In earlier builds a popover stays light in the IDE unless your stack's own handlers set it.

## Building from source

The release file is ready to install, so most people will not need to build. To build it yourself, for example after changing `popover.lcb`:

### With the Extension Builder

1. Clone or download this repository.
2. In HyperXTalk, open **Tools > Extension Builder**.
3. Click **Open an existing extension** and choose `popover.lcb`.
4. Click **Test** to try the widget, **Install** to install it in the IDE, or **Package** to produce a `.lce` file.

### From the command line

`build.sh` does the same without the IDE. It needs a HyperXTalk source checkout with a macOS Release build:

```
HXT=/path/to/HyperXTalk ./build.sh
```

It compiles `popover.lcb` with that checkout's `lc-compile`, generates the dictionary entry (`api.lcdoc`) from the doc comments, and writes `build/com.hyperxtalk.widget.popover.lce`. `HXT` defaults to `~/Developer/HyperXTalk`.

`test/run.sh` then runs the widget in a headless engine: it checks the properties, saves and reloads a stack, and writes snapshots to `build/test`.

## Limitations

- Developed and tested on macOS only.
- On the card, a popover cannot extend beyond the stack's window, and dismissing it is left to your scripts.
- As a popup, it shows text only and cannot take clicks.
- In the IDE, popovers switch to dark mode on their own only in HyperXTalk builds that include [PR 599](https://github.com/emily-elizabeth/HyperXTalk/pull/599).

## Licence

MIT. See [LICENSE](LICENSE).

# Operating System Setup Notes

I reinstall and/or change operating systems a lot, so here are some notes to
help my future self get set up much faster.

## Pop! OS

### Make the system behave like macOS

Install GNOME Shell Extensions using `apt`.

```bash
sudo apt install gnome-shell-extensions
```

Then, install the __Dash to Dock__ and __GPaste__ shell extensions, along
with __GPaste__ itself.

Install the __Multi-Monitors Add On__ from source.

In the __GNOME Tweaks__ application, go to `Windows` and check
`Center New Windows`.

```bash
git clone git://github.com/spin83/multi-monitors-add-on.git
cd multi-monitors-add-on
cp -r multi-monitors-add-on@spin83 ~/.local/share/gnome-shell/extensions/
```

To enable centering windows with a shortcut in GNOME 3, run the
following command

```bash
dconf write "/org/gnome/desktop/wm/keybindings/move-to-center" "['<Control><Super>C']"
```
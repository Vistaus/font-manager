/* FontListControls.vala
 *
 * Copyright (C) 2009 - 2015 Jerry Casiano
 *
 * This file is part of Font Manager.
 *
 * Font Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Font Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Font Manager.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *        Jerry Casiano <JerryCasiano@gmail.com>
*/

namespace FontManager {

    public class FontListControls : Gtk.EventBox {

        public signal void remove_selected ();
        public signal void expand_all (bool expand);
        public signal void show_properties (bool show);

        public bool expanded { get; private set; }
        public Gtk.SearchEntry entry { get; private set; }

        private Gtk.Button _remove;
        private Gtk.Button _expand;
        private Gtk.Arrow arrow;
        private Gtk.Box box;
        private Gtk.ToggleButton show_props;

        public FontListControls () {
            box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
            box.border_width = 2;
            _expand = new Gtk.Button();
            arrow = new Gtk.Arrow(Gtk.ArrowType.RIGHT, Gtk.ShadowType.ETCHED_IN);
            _expand.add(arrow);
            _expand.set_tooltip_text(_("Expand all"));
            _remove = new Gtk.Button();
            _remove.set_image(new Gtk.Image.from_icon_name("list-remove-symbolic", Gtk.IconSize.MENU));
            _remove.set_tooltip_text(_("Remove selected fonts"));
            entry = new Gtk.SearchEntry();
            entry.margin_right = 2;
            entry.set_size_request(0, 0);
            entry.placeholder_text = _("Search Families...");
            show_props = new Gtk.ToggleButton();
        #if GTK_314
            show_props.set_image(new Gtk.Image.from_icon_name("stock-eye-symbolic", Gtk.IconSize.MENU));
        #else
            show_props.set_image(new Gtk.Image.from_resource("/org/gnome/FontManager/icons/16x16/actions/stock-eye-symbolic.svg"));
        #endif
            show_props.set_tooltip_text(_("View font information"));
            box.pack_end(entry, false, false, 0);
            box.pack_end(show_props, false, false, 2);
            box.pack_start(_expand, false, false, 0);
            box.pack_start(_remove, false, false, 0);
            set_default_button_relief(box);
            add(box);
            get_style_context().add_class(Gtk.STYLE_CLASS_VIEW);
            connect_signals();
            set_size_request(0, 0);
        }

        public override void show () {
            entry.show();
            _remove.show();
            arrow.show();
            _expand.show();
            show_props.show();
            box.show();
            base.show();
            return;
        }

        private void connect_signals () {
            _remove.clicked.connect((w) => { remove_selected(); });
            _expand.clicked.connect((w) => {
                expanded = !expanded;
                expand_all(expanded);
                _expand.set_tooltip_text(expanded ? _("Collapse all") : _("Expand all"));
                if (expanded)
                    arrow.set(Gtk.ArrowType.DOWN, Gtk.ShadowType.ETCHED_IN);
                else
                    arrow.set(Gtk.ArrowType.RIGHT, Gtk.ShadowType.ETCHED_IN);
            });
            show_props.toggled.connect(() => {
                show_properties(show_props.active);
                if (show_props.active)
                    show_props.set_tooltip_text(_("Hide font information"));
                else
                    show_props.set_tooltip_text(_("View font information"));

            });
            return;
        }

        public void set_remove_sensitivity (bool sensitive) {
            _remove.set_sensitive(sensitive);
            _remove.set_has_tooltip(sensitive);
            return;
        }

        public void set_properties_sensitivity (bool sensitive) {
            show_props.set_active(false);
            show_props.set_sensitive(sensitive);
            show_props.set_has_tooltip(sensitive);
            return;
        }

    }

}

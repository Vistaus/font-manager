/* ArchiveManager.vala
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

#if HAVE_FILE_ROLLER

[DBus (name = "org.gnome.ArchiveManager1")]
private interface DBusService : Object {

    public signal void progress (double percent, string message);

    public abstract void add_to_archive (string archive, string [] files, bool use_progress_dialog) throws IOError;
    public abstract void compress (string [] files, string destination, bool use_progress_dialog) throws IOError;
    public abstract void extract (string archive, string destination, bool use_progress_dialog) throws IOError;
    public abstract void extract_here (string archive, bool use_progress_dialog) throws IOError;
    /* Valid actions -> "create", "create_single_file", "extract" */
    public abstract HashTable <string, string> [] get_supported_types (string action) throws IOError;

}

public class ArchiveManager : Object {

    public signal void progress (string? message, int processed, int total);

    private DBusService? service = null;
    private Gee.ArrayList <string>? _supported_types = null;

    public void post_error_message (Error e) {
        critical("Archive Manager : %s", e.message);
    }

    private void init () {
        try {
            service = Bus.get_proxy_sync(BusType.SESSION, "org.gnome.ArchiveManager1", "/org/gnome/ArchiveManager1");
            service.progress.connect((p, m) => { progress(m, (int) p, 100); });
            message("Success contacting Archive Manager service.");
            var builder = new StringBuilder();
            foreach (var t in get_supported_types())
                builder.append(t + ", ");
            if (!(builder.str.strip() == ""))
                message("Supported archive types : %s", builder.str);
        } catch (IOError e) {
            warning("Failed to contact Archive Manager service.");
            warning("Features which depend on Archive Manager will not function correctly.");
            post_error_message(e);
        }
        return;
    }

    private DBusService file_roller {
        get {
            init();
            return service;
        }
    }

    public bool add_to_archive (string archive, string [] uris, bool use_progress_dialog = true) {
        Logger.verbose("Archive Manager - Add to archive : %s", archive);
        try {
            file_roller.add_to_archive(archive, uris, use_progress_dialog);
            return true;
        } catch (IOError e) {
            post_error_message(e);
        }
        return false;
    }

    public bool compress (string [] uris, string destination, bool use_progress_dialog = true) {
        Logger.verbose("Archive Manager - Compress : %s", destination);
        try {
            file_roller.compress(uris, destination, use_progress_dialog);
            return true;
        } catch (IOError e) {
            post_error_message(e);
        }
        return false;
    }

    public bool extract (string archive, string destination, bool use_progress_dialog = true) {
        Logger.verbose("Archive Manager - Extract %s to %s", archive, destination);
        try {
            file_roller.extract(archive, destination, use_progress_dialog);
            return true;
        } catch (IOError e) {
            post_error_message(e);
        }
        return false;
    }

    public bool extract_here (string archive, bool use_progress_dialog = true) {
        Logger.verbose("Archive Manager - Extract here : %s", archive);
        try {
            file_roller.extract_here(archive, use_progress_dialog);
            return true;
        } catch (IOError e) {
            post_error_message(e);
        }
        return false;
    }

    public Gee.ArrayList <string> get_supported_types (string action = "extract") {
        Logger.verbose("Archive Manager - Get supported types");
        if (_supported_types != null)
            return _supported_types;
        _supported_types = new Gee.ArrayList <string> ();
        try {
            HashTable <string, string> [] array = file_roller.get_supported_types(action);
            foreach (var hashtable in array)
                _supported_types.add(hashtable.get("mime-type"));
        } catch (Error e) {
            post_error_message(e);
        }
        return _supported_types;
    }

}

#endif /* HAVE_FILE_ROLLER */
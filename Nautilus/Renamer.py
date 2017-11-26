#! /usr/bin/python
#  -*- coding: utf-8 -*-

'''
Copyright (C) 2006-2011 Thura Hlaing <trhura@gmail.com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

'''
import os
import sys
import re
import time
import mmap
import random
import glib
import gettext
import string

from gi.repository import Gtk
from gi.repository import Pango
from gi.repository import GObject
from gi.repository import Notify

try:
    import roman
except ImportError:
    roman = False

# Configuration
DEFAULT_WIDTH   = 550                   # Dialog's default width at startup
DEFAULT_HEIGHT  = 350                   # Dialog's default height at startup
PREVIEW_HEIGHT  = 150                   # Height of preview area
UNDO_LOG_FILE   = '.rlog'               # Name used for Log file
DATA_DIR        = '.rdata/'             #
LOG_SEP         = ' is converted to '   # Log file separator
REC_PATS        = 5                     # Remember up to 5 recent patterns
REC_FILE        = 'recent_patterns'     # filename for recent patterns
NOTIFICATION_TIMEOUT =  -1              # notification timeout, Notify.EXPIRES_DEFAULT
SMALL_FONT_SIZE = Pango.SCALE * 10

# Fake Enums
CASE_NONE, CASE_ALL_CAP, CASE_ALL_LOW, CASE_FIRST_CAP, CASE_EACH_CAP, CASE_CAP_AFTER = range (6)

# dir to store application state, recent patterns ...
CONFIG_DIR = os.path.join (glib.get_user_data_dir (), 'nautilus-renamer')
APP = 'nautilus-renamer'

## init gettext
PO_DIR = None
if os.path.exists(os.path.expanduser('~/.gnome2/nautilus-scripts/.rdata/po')):
    # po dir, when it is installed as a user script
    PO_DIR = os.path.expanduser('~/.gnome2/nautilus-scripts/.rdata/po')

gettext.bindtextdomain(APP, PO_DIR)
gettext.textdomain(APP)
lang = gettext.translation (APP, PO_DIR, fallback=True)
_ = lang.gettext
gettext.install (APP, PO_DIR)

class RenameApplication(Gtk.Application):
    """ The main application """
    def __init__(self):

        self.case_opt = CASE_NONE
        self.recur    = False
        self.ext      = False
        self.pattern  = None
        self.logFile  = None
        self.num_pat = re.compile (r'\/number\|(?P<fill>\d+)(\+(?P<start>\d+))?\/')
        self.roman_pat = re.compile (r'\/roman(\|(?P<start>\d+))?\/')
        self.ran_pat = re.compile (r'\/random\|(?P<start>\d+)-(?P<end>\d+)\/')
        self.name_slice = re.compile (r'\/name\|(?P<offset>-?\d+)(:(?P<length>-?\d+))?\/')
        self.filename_slice = re.compile (r'\/filename\|(?P<offset>-?\d+)(:(?P<length>-?\d+))?\/')
        self.alpha_pat = re.compile (r'\/alphabet\|(?P<length>\d+)\/')
        self.alphau_pat = re.compile (r'\/ALPHABET\|(?P<length>\d+)\/')
        self.a_pattern = re.compile (r'\/.*\/') #used to check invalid patterns
        self.nums = {}
        self.romans = {}
        self.ran_seq = {}
        self.ran_fill = {}
        self.alphas = {}
        self.alphaus = {}
        self.filesRenamed = 0
        self.undo_p = False
        self.pmodel = Gtk.ListStore.new ([GObject.TYPE_STRING, GObject.TYPE_STRING])

        # Toggle Buttons Box
        self.pbutton = Gtk.Button.new_with_mnemonic (_("_Pattern"))
        self.sbutton = Gtk.Button.new_with_mnemonic (_("_Substitute"))
        self.cbutton = Gtk.Button.new_with_mnemonic (_("C_ase"))
        self.ubutton = Gtk.Button.new_with_mnemonic (_("_Undo"))

        buttonbox = Gtk.ButtonBox.new (Gtk.Orientation.HORIZONTAL)
        buttonbox.set_layout (Gtk.ButtonBoxStyle.START)
        buttonbox.pack_start (self.pbutton, False, False, 0)
        buttonbox.pack_start (self.sbutton, False, False, 0)
        buttonbox.pack_start (self.cbutton, False, False, 0)
        buttonbox.pack_start (self.ubutton, False, False, 0)
        buttonbox.set_child_secondary (self.ubutton, True)

        self.options_box   = Gtk.VBox.new  (False, 5)
        options_align  = Gtk.Alignment.new (0.1, 0.1, 1.0, 0.0)
        options_align.add (self.options_box)
        options_align.set_padding (0, 0, 10, 10)
        options_align.set_size_request (-1, 150)

        #Popup Menu for available patterns
        self.pattern_popup  = Gtk.Menu ()
        pattern_fname   = Gtk.MenuItem ('/filename/')
        pattern_dir     = Gtk.MenuItem ('/dir/')
        pattern_name    = Gtk.MenuItem ('/name/')
        pattern_ext     = Gtk.MenuItem ('/ext/')
        pattern_day     = Gtk.MenuItem ('/day/')
        pattern_date    = Gtk.MenuItem ('/date/')
        pattern_month   = Gtk.MenuItem ('/month/')
        pattern_year    = Gtk.MenuItem ('/year/')
        pattern_dname   = Gtk.MenuItem ('/dayname/')
        pattern_dsimp   = Gtk.MenuItem ('/daysimp/')
        pattern_mname   = Gtk.MenuItem ('/monthname/')
        pattern_msimp   = Gtk.MenuItem ('/monthsimp/')
        pattern_num1    = Gtk.MenuItem ('/number|5/')
        pattern_num2    = Gtk.MenuItem ('/number|3+5/')
        pattern_rand    = Gtk.MenuItem ('/random|1-99/')
        pattern_offset  = Gtk.MenuItem ('/filename|0:3/')
        pattern_alpha   = Gtk.MenuItem ('/alphabet|3/')
        pattern_alphau  = Gtk.MenuItem ('/ALPHABET|3/')
        pattern_roman   = Gtk.MenuItem ('/roman/')

        pattern_fname.set_tooltip_text  (_("Original filename"))
        pattern_dir.set_tooltip_text    (_("Parent directory"))
        pattern_name.set_tooltip_text   (_("Filename without extenstion"))
        pattern_ext.set_tooltip_text    (_("File extension"))
        pattern_day.set_tooltip_text    (_("Day of month"))
        pattern_date.set_tooltip_text   (_("Full date, e.g., 24Sep2008"))
        pattern_month.set_tooltip_text  (_("Numerical month of year"))
        pattern_year.set_tooltip_text   (_("Year, e.g., 1990"))
        pattern_mname.set_tooltip_text  (_("Full month name, e.g., August"))
        pattern_msimp.set_tooltip_text  (_("Simple month name, e.g., Aug"))
        pattern_dname.set_tooltip_text  (_("Full day name, e.g., Monday"))
        pattern_dsimp.set_tooltip_text  (_("Simple dayname, e.g., Mon"))
        pattern_num1.set_tooltip_text   (_("/number|5/ => 00001, 00002, 00003 , ..."))
        pattern_num2.set_tooltip_text   (_("/number|3+5/ => 005, 006, 007 , ..."))
        pattern_rand.set_tooltip_text   (_("A random number between 01 and 99"))
        pattern_offset.set_tooltip_text (_("The first three letters of filename."))
        pattern_alpha.set_tooltip_text  (_("/alphabet|3/ => aaa, aab, .. aaaa, aaab .."))
        pattern_alphau.set_tooltip_text (_("/ALPHABET|3/ => AAA, AAB, .. AAAA, AAAB .."))
        pattern_roman.set_tooltip_text (_("/roman|3/ => III, IV, V ..."))

        self.pattern_popup.attach (pattern_fname,   0, 1, 0, 1)
        self.pattern_popup.attach (pattern_dir,     1, 2, 0, 1)
        self.pattern_popup.attach (pattern_name,    0, 1, 1, 2)
        self.pattern_popup.attach (pattern_ext,     1, 2, 1, 2)
        self.pattern_popup.attach (pattern_day,     0, 1, 2, 3)
        self.pattern_popup.attach (pattern_date,    1, 2, 2, 3)
        self.pattern_popup.attach (pattern_month,   0, 1, 3, 4)
        self.pattern_popup.attach (pattern_year,    1, 2, 3, 4)
        self.pattern_popup.attach (pattern_dname,   0, 1, 4, 5)
        self.pattern_popup.attach (pattern_dsimp,   1, 2, 4, 5)
        self.pattern_popup.attach (pattern_mname,   0, 1, 5, 6)
        self.pattern_popup.attach (pattern_msimp,   1, 2, 5, 6)
        self.pattern_popup.attach (pattern_num1,    0, 1, 6, 7)
        self.pattern_popup.attach (pattern_num2,    1, 2, 6, 7)
        self.pattern_popup.attach (pattern_rand,    0, 1, 7, 8)
        self.pattern_popup.attach (pattern_offset,  1, 2, 7, 8)
        self.pattern_popup.attach (pattern_alpha,    0, 1, 8, 9)
        self.pattern_popup.attach (pattern_alphau,  1, 2, 8, 9)
        if roman:
            self.pattern_popup.attach (pattern_roman,  0, 1, 9, 10)
        self.pattern_popup.show_all ()

        # Two checkboxs at the bottoms
        self.extension_cb   = Gtk.CheckButton.new_with_mnemonic (_("_Extension"))
        self.recursive_cb   = Gtk.CheckButton.new_with_mnemonic (_("_Recursive"))
        self.extension_cb.set_tooltip_text (_("Also operate on extensions"))
        self.recursive_cb.set_tooltip_text (_("Also operate on subfolders and files"))

        brbox   = Gtk.HBox.new (False, 5)
        brbox.pack_end (self.recursive_cb, False, False, 0)
        brbox.pack_end (self.extension_cb, False, False, 0)
        ralign = Gtk.Alignment.new (1.0, 0.5, 0.0, 0.0)
        ralign.add (brbox)

        refresh_btn     = Gtk.Button.new_with_mnemonic (_("Refresh Previe_w"))
        bbox    = Gtk.HBox.new (False, 5)
        bbox.pack_start (refresh_btn, False, False, 0)
        bbox.pack_end (ralign, False, False, 0)

        # Preview
        #preview_box    = Gtk.HBox.new (False, 5)
        view    = Gtk.TreeView.new_with_model (self.pmodel)
        view.set_rules_hint (True)

        cell    = Gtk.CellRendererText.new ()
        cell.set_property ('scale', 0.8)
        cell.set_property ('width', 280)
        cell.set_property ('ellipsize', Pango.EllipsizeMode.MIDDLE)
        column  = Gtk.TreeViewColumn (_("Original Name"), cell, text=0)
        column.set_property ('sizing', Gtk.TreeViewColumnSizing.AUTOSIZE)
        column.set_property ('resizable', True)
        view.append_column (column)
        cell    = Gtk.CellRendererText.new ()
        cell.set_property ('scale', 0.8)
        cell.set_property ('width', 280)
        cell.set_property ('ellipsize', Pango.EllipsizeMode.MIDDLE)
        column  = Gtk.TreeViewColumn (_("New Name"), cell, text=1)
        column.set_property ('sizing', Gtk.TreeViewColumnSizing.AUTOSIZE)
        column.set_property ('resizable', True)
        view.append_column (column)

        scrollwin   = Gtk.ScrolledWindow.new (None, None)
        scrollwin.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrollwin.set_size_request (-1, PREVIEW_HEIGHT)
        scrollwin.add (view)

        preview_align  = Gtk.Alignment.new (0.1, 0.1, 1.0, 0.0)
        preview_align.add (scrollwin)
        preview_align.set_padding (0, 0, 10, 10)

        expander = Gtk.Expander.new_with_mnemonic (_("Pre_view"))
        expander.set_use_underline (True)
        expander.set_spacing (5)
        expander.add (preview_align)

        main_box    = Gtk.VBox.new ( False, 8)
        main_box.pack_start (buttonbox, False, False, 0)
        main_box.pack_start (options_align, False, False, 0)
        main_box.pack_start (expander, True, True, 0)
        main_box.pack_start (Gtk.HSeparator(), False, False, 0)
        main_box.pack_end   (bbox, False, False, 0)
        main_align = Gtk.Alignment.new (0.0, 0.0, 1.0, 0.0)
        main_align.set_padding (10, 10, 10, 10)
        main_align.add (main_box)

        self.dialog = Gtk.Dialog ("Renamer", None, Gtk.DialogFlags.MODAL,
                                  (Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK))
        self.dialog.vbox.add (main_align)

        self.dialog.set_default_size (DEFAULT_WIDTH, DEFAULT_HEIGHT)
        self.dialog.set_icon_name (Gtk.STOCK_EDIT)
        self.dialog.show_all ()

        self.pbutton.connect ('clicked', self.pattern_options_cb)
        self.sbutton.connect ('clicked', self.substitute_options_cb)
        self.cbutton.connect ('clicked', self.case_options_cb)
        self.ubutton.connect ('clicked', self.undo_options_cb)

        pattern_dir.connect   ('activate', self.on_popup_activate)
        pattern_ext.connect   ('activate', self.on_popup_activate)
        pattern_day.connect   ('activate', self.on_popup_activate)
        pattern_date.connect  ('activate', self.on_popup_activate)
        pattern_name.connect  ('activate', self.on_popup_activate)
        pattern_year.connect  ('activate', self.on_popup_activate)
        pattern_fname.connect ('activate', self.on_popup_activate)
        pattern_month.connect ('activate', self.on_popup_activate)
        pattern_dname.connect ('activate', self.on_popup_activate)
        pattern_dsimp.connect ('activate', self.on_popup_activate)
        pattern_mname.connect ('activate', self.on_popup_activate)
        pattern_msimp.connect ('activate', self.on_popup_activate)
        pattern_num1.connect ('activate', self.on_popup_activate)
        pattern_num2.connect ('activate', self.on_popup_activate)
        pattern_rand.connect ('activate', self.on_popup_activate)
        pattern_offset.connect ('activate', self.on_popup_activate)
        pattern_alpha.connect  ('activate', self.on_popup_activate)
        pattern_alphau.connect  ('activate', self.on_popup_activate)
        pattern_roman.connect  ('activate', self.on_popup_activate)

        expander.connect ('notify::expanded', self.expander_cb)
        refresh_btn.connect ('clicked', self.prepare_preview)

        self.prepare_pattern_options (self.pbutton)
        self.prepare_substitute_options (self.sbutton)
        self.prepare_case_options (self.cbutton)
        self.prepare_undo_options (self.ubutton)
        self.prepare_cap_after_options (self.ubutton)

    def pattern_options_cb (self, button, data=None):
        self.options_box.foreach (self.remove, None)
        self.options_box.pack_start (self.pattern_label, True, True, 0)
        self.options_box.pack_start (self.pattern_box, True, True, 0)
        self.options_box.show_all ()

    def prepare_pattern_options (self, button, data=None):
        ''' Prepare widgets & options for pattern on startup '''
        self._read_recent_pats ()
        self.pattern_box    = Gtk.HBox (False, 5)
        pattern_combo   = Gtk.ComboBoxText.new_with_entry ()
        self.pats.foreach (lambda m, p, i, d: pattern_combo.append_text (m[i][0]), None)

        self.pattern_entry  = pattern_combo.get_child()
        button  = Gtk.Button.new_with_mnemonic (" _?")

        self.pattern_entry.label = _("Enter the pattern here ... ")
        self.prepare_entry (self.pattern_entry)

        self.pattern_box.pack_start (pattern_combo, True, True, 0)
        self.pattern_box.pack_start (button, False, False, 0)

        pattern_combo.connect ('changed', self.combo_box_changed )
        self.pattern_entry.connect ('activate', self.pattern_entry_activate)
        button.connect ('button-press-event', lambda button, event:
                            self.pattern_popup.popup (None, None, None, None, event.button, event.time))

        self.pattern_label = Gtk.Label.new (_("Enter the base pattern to rename. Click '?' for available patterns."))
        self.pattern_label.set_alignment (0.04, 0.5)

        self.pattern_options_cb (self, button)

    def substitute_options_cb (self, button, data=None):
        self.options_box.foreach (self.remove, None)
        self.options_box.pack_start (self.sub_label, True, True, 0)
        self.options_box.pack_start (self.sub_replee, True, True, 0)
        self.options_box.pack_start (self.sub_repler, True, True, 0)
        self.options_box.show_all ()
        self.undo_p = False

    def prepare_substitute_options (self, button, data=None):

        self.sub_label  = Gtk.Label.new (_("Delete or replace multiple characters and words..."))
        self.sub_label.set_alignment (0.02, 0.5)

        self.sub_replee = Gtk.Entry.new ()
        self.sub_replee.label =  _("Words to be replaced separated by \"/\", e.g., 1/2 ...")
        self.prepare_entry (self.sub_replee)

        self.sub_repler = Gtk.Entry.new ()
        self.sub_repler.label = _("Corresponding words to replace with, e.g., one/two ...")
        self.prepare_entry (self.sub_repler)

        self.sub_replee.set_tooltip_text (_("Enter the characters or words to be replaced, separated by '/'"))
        self.sub_repler.set_tooltip_text (_("Enter the corresponding words to replace with"))

    def case_options_cb (self, button, data=None):
        """ callback when case button is clicked """
        self.options_box.foreach (self.remove, None)
        self.options_box.pack_start (self.case_box, True, True, 0)
        self.options_box.show_all ()
        self.undo_p = False

    def prepare_case_options (self, button, data=None):
        """ prepare widgets & settings for case options """
        store   = Gtk.ListStore ('gboolean', str, int)
        store.append([True,  _("Keep Original Case"), CASE_NONE])
        store.append([False,  _("ALL IN CAPITALS"), CASE_ALL_CAP])
        store.append([False, _("all in lower case"), CASE_ALL_LOW])
        store.append([False, _("First letter upper case"), CASE_FIRST_CAP])
        store.append([False, _("Title Case"), CASE_EACH_CAP])
        store.append([False, _("Capital Case After ..."), CASE_CAP_AFTER])

        self.view   = Gtk.TreeView.new_with_model (store)
        self.view.set_rules_hint (True)
        self.view.connect ('cursor-changed', self.cursor_changed)

        cell    = Gtk.CellRendererToggle.new ()
        cell.set_radio (True)
        cell.set_property ('xalign', 0.1)

        column  = Gtk.TreeViewColumn.new ()
        column.pack_start (cell, False)
        column.set_sizing (Gtk.TreeViewColumnSizing.FIXED)
        column.set_fixed_width (40)
        column.add_attribute (cell, 'active', 0)
        self.view.append_column (column)

        cell    = Gtk.CellRendererText.new ()
        cell.set_property ('scale', 0.8)

        column  = Gtk.TreeViewColumn.new ()
        column.set_title (_("Choose One"))
        column.pack_start (cell, True)
        column.add_attribute (cell, 'text', 1)
        self.view.append_column (column)

        self.scroll_win  = Gtk.ScrolledWindow()
        self.scroll_win.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        self.scroll_win.add(self.view)
        self.scroll_win.set_size_request (-1, 120)

        self.case_label = Gtk.Label.new (_("Choose the casing style you want to apply."))
        self.case_label.set_alignment (0.02, 0.5)

        self.case_box   = Gtk.VBox (False, 5)
        self.case_box.pack_start (self.case_label, False, False, 0)
        self.case_box.pack_start (self.scroll_win, True, True, 0)

    def undo_options_cb (self, button, data=None):
        self.options_box.foreach (self.remove, None)
        self.options_box.pack_start (self.undo_label, True, True, 0)
        self.options_box.show_all ()
        self.undo_p = True

    def prepare_undo_options (self, button, data=None):
        self.undo_label = Gtk.Label ()
        self.undo_label.set_line_wrap (True)
        self.undo_label.set_alignment (0.1, -1)

        if self.log_file_p():
            self.undo_label.set_markup (_("<b>Undo the last operation inside this folder.</b>\n\n <span " +
                                         "size='small'>Note: You cannot undo an undo. ;)</span>"))
        else:
            self.undo_label.set_markup (_("<span color='red' weight='bold'>No log file is found in this folder." +
                                         "</span>\n\n<span size='small'>Note: When it renames files," +
                                         "Renamer writes a log file, in the folder it was launched, which is used for Undo.</span>"))

    def cap_after_options_cb (self):
        self.options_box.foreach (self.remove, None)
        self.options_box.pack_start (self.cap_box, True, True, 0)
        self.options_box.show_all ()

    def prepare_cap_after_options (self, button):
        cap_label = Gtk.Label.new_with_mnemonic (_("Enter a list of letters or words, seperated by '/'."))
        cap_label.set_alignment (0.02, 0.5)
        cap_label.set_line_wrap (True)

        self.cap_entry = Gtk.Entry.new ()
        self.cap_entry.set_text ('-/_/ /[/]/(/)/{/}')
        desc	= self.cap_entry.get_pango_context().get_font_description()
        desc.set_size (SMALL_FONT_SIZE)
        self.cap_entry.modify_font (desc)

        self.cap_first = Gtk.CheckButton.new_with_mnemonic (_("_First Letter"))
        self.cap_first.set_active (False)
        self.cap_entry.set_tooltip_text (_("A list of sequences, separated by '/'. The letters after them will be capitalized."))
        self.cap_first.set_tooltip_text (_("Capitalize the first letter"))

        temp_alignment = Gtk.Alignment.new (1.0, 0.5, 0, 0)
        temp_alignment.add (self.cap_first)

        self.cap_box = Gtk.VBox (False, 5)
        self.cap_box.pack_start (cap_label, False, False, 0)
        self.cap_box.pack_start (self.cap_entry, False, False, 0)
        self.cap_box.pack_start (temp_alignment, False, False, 0)

    def entry_focus_in (self, widget, event, data=None):
        ''' When the entriy is focused for the first time, clear the label text, and reset text style.'''
        if widget.clr_on_focus:
            widget.set_text ("")
            widget.clr_on_focus = False

    def entry_focus_out (self, widget, event, data=None):
        ''' When the entry focus is out without any changes, restore label text and color.'''
        if widget.get_text () == "":
            widget.set_text (widget.label)
            widget.clr_on_focus = True   # Clear current text when the entry is focused

    def prepare_entry (self, entry):
        ''' Helper function for preparing entries in our dialog '''
        entry.set_text (entry.label)
        entry.clr_on_focus = True   # Clear current text when the entry is focused

        #Make the text in entry small
        desc	= entry.get_pango_context().get_font_description()
        desc.set_size (SMALL_FONT_SIZE)
        entry.modify_font (desc)

        entry.connect ('focus-in-event',  self.entry_focus_in)
        entry.connect ('focus-out-event', self.entry_focus_out)

    def combo_box_changed (self, combo, data=None):
        "When patten combo box entry is changed, restore text style"
        self.pattern_entry.clr_on_focus = False

    def pattern_entry_activate (self, entry, data=None):
        "When Return is pressed on pattern entry"
        self.rename (files)
        self.dialog.destroy ()

    def expander_cb (self, widget, data):
        ''' When expander state is changed '''
        if widget.get_expanded ():
            # When preview is expanded, resize the dialog a litter bigger.
            self.dialog.resize (DEFAULT_WIDTH + 100 , DEFAULT_HEIGHT + PREVIEW_HEIGHT)
            self.prepare_preview (widget)
        else:
            # When preview is hidden, restore normal size
            self.dialog.set_size_request (DEFAULT_WIDTH, DEFAULT_HEIGHT)
            self.dialog.resize (DEFAULT_WIDTH, DEFAULT_HEIGHT)

    def on_popup_activate (self, item, data=None):
        ''' When a menutitem on patterns popup menu is clicked, insert the label to pattern entry. '''
        self.entry_focus_in (self.pattern_entry, None, None)
        position = self.pattern_entry.get_position ()
        position = position == 0 and -1 or position
        self.pattern_entry.insert_text (item.get_property('label'),
                                        position)

    def cursor_changed (self, treeview, data=None):
        ''' When selected row in CASE tree view is changed, update the tree model. '''
        model, iter = treeview.get_selection().get_selected ()
        model.foreach (lambda model, path, iter, data: model.set (iter, 0, False), None)
        model.set (iter, 0, True)
        self.case_opt = model.get_value (iter, 2)

        if self.case_opt == CASE_CAP_AFTER:
            self.cap_after_options_cb ()

    def remove (self, child, user_data):
        ''' callback to remove a child from options_box '''
        self.options_box.remove (child)

    def build_preview_model (self, path, vpath=''):
        ''' Base function for building list store for preview '''
        parent, name = os.path.split (path)
        newName = self._get_new_name(name)

        if not newName:
            # If there is any error getting new name, return False
            print "build preview error ...."
            return False

        newPath = os.path.join (os.path.split(vpath)[0],newName)

        if not path == newPath:
            self.pmodel.append ([path, newPath])

        if  os.path.isdir(path) and self.recur:
            for subdir in os.listdir (path):
                if not self.build_preview_model (os.path.join(path, subdir), os.path.join(newPath, subdir)):
                    # If there is any error
                    return False

        return True

    def prepare_preview (self, widget):
        " Wrapper around build_preview_model. Prepare and validate settings."
        self.pmodel.clear ()

        if self.undo_p and self.log_file_p():
            logFile = open (UNDO_LOG_FILE, 'rb')

            for i in xrange(5): logFile.readline () #Skip 5 lines of header

            for line in logFile:
                oldpath, newpath = line.split('\n')[0].split(LOG_SEP)
                #oldp = os.path.join(os.path.dirname(oldpath), os.path.basename(newpath))
                #newp = os.path.join(os.path.dirname(newpath), os.path.basename(oldpath))
                self.pmodel.append ([newpath, oldpath])

            logFile.close ()
            return

        if not self.prepare_data_from_dialog():
        # if there is any error, return
            return

        for file in files:
            if not self.build_preview_model (file):
                # if there is any error
                return

    def prepare_data_from_dialog (self):
        ''' Initialize data require for rename and preview from dailog
            Report and return False.on errors'''

        self.recur = self.recursive_cb.get_active ()
        self.ext   = self.extension_cb.get_active ()

        if not self.undo_p and not files:
            # If it is not undo, and no selected files
            return False

        # prepare patternize related options, and check for possible errors
        self.pattern = self.pattern_entry.get_text ()
        self.nums = {}
        self.romans = {}

        if self.pattern == '' or self.pattern == self.pattern_entry.label:
            #show_error (_("Empty Pattern"), _("Please, enter a valid pattern."))
            self.pattern = '/filename/'

        if self.num_pat.search(self.pattern) or \
            self.roman_pat.search(self.pattern):
            #if the pattern numbering pattern, disable recursion
            self.recur = False

        for index, match in enumerate(self.alpha_pat.finditer (self.pattern)):
            length = match.groupdict ().get ('length')
            self.alphas[str(index)] = AlphabetLowerSeq (int(length))

        for index, match in enumerate(self.alphau_pat.finditer (self.pattern)):
            length = match.groupdict ().get ('length')
            self.alphaus[str(index)] = AlphabetUpperSeq (int(length))

        for index, match in enumerate(self.ran_pat.finditer (self.pattern)):
            # If a random pattern is found, prepare sequence of random numbers
            start = match.groupdict ().get ('start')
            end = match.groupdict ().get ('end')
            self.ran_fill[str(index)] = len(str(end))
            self.ran_seq[str(index)] = [x for x in xrange (int(start), int(end) + 1)]

        # prepare substitute related options, and check for possible errors
        replee = self.sub_replee.get_text ()
        repler = self.sub_repler.get_text ()

        self.substitute_p = True
        if replee == self.sub_replee.label or replee == '':
            # no need to substitute
            self.substitute_p = False

        if repler == self.sub_repler.label:
            repler = ''

        self.replees = replee.split ('/')
        self.replers = repler.split ('/')
        return True

    def rename (self, files):
        ''' Wrapper around _rename (). Prepare and validate settings, and write logs.'''
        if self.undo_p:
            self.undo ()
            return True

        if not files:
            # No files to rename
            show_error (_("No file selected"), _("Please, select some files first."))
            self.exit ()

        if not self.prepare_data_from_dialog():
            # if there is any error, return
            return False

        self.start_log ()

        for file in files:
            app._rename(file)

        self.close_log ()
        self._write_recent_pats ()

        self.notify(_("Rename successful"),
                    _("renamed %d files successfully.") % self.filesRenamed,
                     Gtk.STOCK_APPLY)

        return True

    def _rename (self, path, oldPath=''):
        ''' Base function to rename files
            If self.recur is set, also renames file recursively'''
        parent, oldName = os.path.split (path)
        newName = self._get_new_name (oldName)

        if not newName:
            self.exit ()

        newPath = os.path.join (parent, newName)
        oldPath = os.path.join (oldPath, oldName)

        if not path == newPath:
            # No need to rename if path (old) = newPath
            if os.path.exists (newPath):
                show_error (_("File Already Exists"), newPath + _(" already exists. Use Undo to revert."))
                self.exit()

            os.rename (path, newPath)
            self.logFile.write ('%s%s%s\n' %(oldPath, LOG_SEP,newPath))
            self.filesRenamed = self.filesRenamed + 1

        if  os.path.isdir(newPath) and self.recur:
            for file in os.listdir (newPath):
                self._rename (os.path.join (newPath, file), oldPath)

    def _write_recent_pats (self):
        ''' Store recent patterns '''
        if not os.path.exists(CONFIG_DIR):
            os.makedirs (CONFIG_DIR)

        with open (os.path.join (CONFIG_DIR, REC_FILE), 'w') as file:
            i = 1
            cpat = self.pattern_entry.get_text()
            if cpat != self.pattern_entry.label: # Don't write 'Enter pattern' label ...
                file.write (cpat + '\n' )
            for pat in self.pats:
                if i < REC_PATS and not pat[0] == cpat:
                    file.write (pat[0] + '\n')
                    i = i + 1

    def _read_recent_pats (self):
        ''' Read recent patterns '''
        self.pats = Gtk.ListStore (GObject.TYPE_STRING)

        try:
            with open (os.path.join (CONFIG_DIR, REC_FILE), 'r') as file:
                for pat in file:
                    self.pats.append ([pat[:-1]])
        except:
            pass

    def _get_new_name (self, oldName):
        ''' return a new name, based on the old name, and settings from our dialog. '''
        newName = self.pattern

        ### START PATTERNIZE OPTIONS ###
        #for number substiution
        for index, match in enumerate(self.num_pat.finditer (newName)):
            number = self.nums.get (str(index), 0)
            start = match.groupdict ().get ('start')
            fill  = match.groupdict ().get ('fill')

            if start == None:
                start = 1

            substitute = str(number+int(start)).zfill(int(fill))
            newName    = self.num_pat.sub(substitute, newName, 1)
            self.nums[str(index)]  = number + 1

        # roman pattern
        for index, match in enumerate(self.roman_pat.finditer (newName)):
            if not roman:
                print "python-roman is not installed."
                break

            number = self.romans.get (str(index), 0)
            start = match.groupdict ().get ('start')

            if start == None:
                start = 1

            substitute = roman.toRoman (number+int(start))
            newName    = self.roman_pat.sub(substitute, newName, 1)
            self.romans[str(index)]  = number + 1

        for index, match in enumerate(self.alphau_pat.finditer (self.pattern)):
            nxt = self.alphaus[str(index)].next ()
            subst = ''.join (nxt)
            newName = self.alphau_pat.sub (subst, newName, 1)

        for index, match in enumerate(self.alpha_pat.finditer (self.pattern)):
            nxt = self.alphas[str(index)].next ()
            subst = ''.join (nxt)
            newName = self.alpha_pat.sub (subst, newName, 1)

        # for random number insertion
        for index, match in enumerate(self.ran_pat.finditer (newName)):
            if not self.ran_seq[str(index)]:
                # if random number sequence is None
                print "Not Enought Random Number Range"
                show_error (_("Not Enough Random Number Range"), _("Please, use a larger range"))
                self.exit ()
                #return False

            randint = random.choice (self.ran_seq[str(index)])
            self.ran_seq[str(index)].remove (randint)
            subst = str(randint).zfill(self.ran_fill[str(index)])
            newName = self.ran_pat.sub (subst, newName, 1)

        dir, file = os.path.split (os.path.abspath(oldName))
        name, ext = os.path.splitext (file)
        dirname = os.path.basename(dir)

        #replace filename related Tags
        newName = newName.replace('/filename/',oldName)
        newName = newName.replace('/dir/', dirname)
        newName = newName.replace('/name/', name)
        newName = newName.replace('/ext/', ext)

        #for /name,offset(:length)/
        for match in self.name_slice.finditer (newName):
            offset = match.groupdict ().get ('offset')
            length = match.groupdict ().get ('length')

            if length == None:
                offset = int(offset)
                substitute = name[offset:]
            else:
                offset = int(offset)
                length = int(length)
                if length < 0:
                    if offset  == 0:
                        substitute = name[offset+length:]
                    else:
                        substitute = name[offset+length:offset]
                else:
                    if (len(name[offset:]) > length):
                        substitute = name[offset:offset+length]
                    else:
                        substitute = name[offset:]
            newName    = self.name_slice.sub (substitute, newName, 1)

        #for /filename|offset(:length)/
        for match in self.filename_slice.finditer (newName):
            offset = match.groupdict ().get ('offset')
            length = match.groupdict ().get ('length')

            if length == None:
                offset = int(offset)
                substitute = oldName[offset:]
            else:
                offset = int(offset)
                length = int(length)
                if length < 0:
                    if offset  == 0:
                        substitute = oldName[offset+length:]
                    else:
                        substitute = oldName[offset+length:offset]
                else:
                    if (len(name[offset:]) > length):
                        substitute = name[offset:offset+length]
                    else:
                        substitute = name[offset:]

            newName    = self.filename_slice.sub(substitute, newName, 1)

        #Some Time/Date Replacements
        newName = newName.replace('/date/', time.strftime('%d%b%Y', time.localtime()))
        newName = newName.replace('/year/', time.strftime('%Y', time.localtime()))
        newName = newName.replace('/month/', time.strftime('%m', time.localtime()))
        newName = newName.replace('/monthname/', time.strftime('%B', time.localtime()))
        newName = newName.replace('/monthsimp/', time.strftime('%b', time.localtime()))
        newName = newName.replace('/day/', time.strftime('%d', time.localtime()))
        newName = newName.replace('/dayname/', time.strftime('%A', time.localtime()))
        newName = newName.replace('/daysimp/', time.strftime('%a', time.localtime()))
        ### END PATTERNIZE OPTIONS ###

        if not self.ext:
            name, ext = os.path.splitext (newName)
        else:
            name = newName

        # Handle Substitute
        if self.substitute_p:
            for i in xrange (0, len(self.replees)):
                if i < len (self.replers):
                    name = name.replace (self.replees[i], self.replers[i])
                else:
                    # if there is no corresponding word to replace, use the last one
                    name = name.replace (self.replees[i], self.replers[-1])
                # pattern = re.compile (self.replees[i])
                # if i < len (self.replers):
                #     name = pattern.sub (self.replers[i], name)
                # else:
                #     name = pattern.sub (self.replers[-1], name)

        # Handle Case
        if self.case_opt == CASE_ALL_CAP:
            name = name.upper ()

        elif self.case_opt == CASE_ALL_LOW:
            name = name.lower()

        elif self.case_opt == CASE_FIRST_CAP:
            name = name.capitalize()

        elif self.case_opt == CASE_EACH_CAP:
            name = name.title ()

        elif self.case_opt == CASE_CAP_AFTER:
            if self.cap_first.get_active():
                name = name.capitalize()

            seps  = self.cap_entry.get_text ()
#            print name, seps
            for sep in seps.split ('/'):
                if not sep == '':
                    lst = [ l for l in name.split(sep)]
                for i in xrange(1, len(lst)):
                    if lst[i] is not '':
                        lst[i] = lst[i][0].upper() + lst[i][1:]
                name = sep.join (lst)

        if self.ext:
            return name
        else:
            return name + ext

    def undo (self):
        ''' Restore previously renamed files back according to the log file. '''
        if not self.log_file_p ():
            show_error (_("Undo Failed"), _("Log file not found"))
            self.exit()

        logFile = open (UNDO_LOG_FILE, 'rb')
        for i in range(5): logFile.readline () #Skip 5 lines of header

        for line in logFile:
            oldpath, newpath = line.split('\n')[0].split(LOG_SEP)
            oldpath = os.path.abspath (oldpath)
            #print os.path.join(os.path.dirname(oldpath),os.path.basename(newpath)),oldpath
            os.rename(os.path.join(os.path.dirname(oldpath),os.path.basename(newpath)),oldpath)
            self.filesRenamed = self.filesRenamed + 1

        logFile.close ()

        os.remove (UNDO_LOG_FILE)
        self.notify(_("Undo successful"),
                    _("%d files restored.") % self.filesRenamed,
                    Gtk.STOCK_APPLY)

    def log_file_p (self):
        ''' Check for log file in current folder,
            return True if found, else False '''
        return os.path.exists (UNDO_LOG_FILE) and True or False

    def start_log (self):
        ''' Open log and write header. '''
        self.logFile = open (UNDO_LOG_FILE, 'wb', 1)

        self.logFile.write (' Renamer Log '.center (80, '#'))
        self.logFile.write ('\n')

        self.logFile.write ('# File :  files\n')
        self.logFile.write ('# Time : ')
        self.logFile.write (time.strftime('%a, %d %b %Y %H:%M:%S\n'))
        self.logFile.write ('#'.center (80, '#'))
        self.logFile.write ('\n\n')

    def close_log (self):
        ''' Close log file, and insert total files renamed.'''
        if not self.logFile:
            return

        self.logFile.close ()

        with open (UNDO_LOG_FILE, 'r+b') as file:
            m = mmap.mmap(file.fileno(), os.path.getsize(UNDO_LOG_FILE))
            str = '%d' % self.filesRenamed
            l = len(str) #len
            s = m.size() #size
            o = 90       #offset
            m.resize (s + l)
            m[(o+l) : ] = m [o : s]
            m[o : (o+l)] = str
            m.close ()

    def exit (self):
        ''' Exit Application if there is an error.'''
        self.close_log ()
        self._write_recent_pats ()

        sys.exit (1)

    def notify(self, title,text,icon):
        ''' Wrapper to display notifications with timeout time. '''
        notification = Notify.Notification.new (text, title, icon)
        notification.set_timeout (3 * 1000)
        notification.set_urgency (Notify.Urgency.CRITICAL)
        notification.show ()

class SequenceIterator (object):
    def __init__ (self, sequence,length):
        if len(sequence) > len(set(sequence)): #any(sequence.count(x) > 1 for x in sequence):
            raise ValueError ('Sequence must be unique.')

        self.seq    = list(sequence)
        self.first  = sequence[0]
        self.lastIndex = len(sequence) - 1
        self.cur    = [self.first for x in range (length)]

    def __iter__ (self):
        return self

    def next (self):
        i = 0
        ret = list(self.cur)

        while i < len(self.cur):
            index = self.seq.index (self.cur[i])
            if index < self.lastIndex:
                self.cur[i] = self.seq[index+1]
                break
            self.cur[i] = self.first
            i += 1
        else:
            self.cur.append(self.first)

        return list(reversed(ret))

class AlphabetLowerSeq (SequenceIterator):
    def __init__ (self, length):
        super (AlphabetLowerSeq, self).__init__ (string.ascii_lowercase, length)

class AlphabetUpperSeq (SequenceIterator):
    def __init__ (self, length):
        super (AlphabetUpperSeq, self).__init__ (string.ascii_uppercase, length)


def show_error (title, message):
    "help function to show an error dialog"
    dialog = Gtk.MessageDialog (type=Gtk.MessageType.ERROR, buttons=Gtk.ButtonsType.CLOSE)
    dialog.set_markup ("<b>%s</b>\n\n%s"%(title, message))
    dialog.run ()
    dialog.destroy ()

if __name__ == '__main__':
    files = [file for file in sys.argv[1:]]
    app = RenameApplication ()

    Notify.init (APP)
    while (app.dialog.run () == Gtk.ResponseType.OK):
        if app.rename (files):
            break



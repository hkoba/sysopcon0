#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require ctext
package require snit

snit::widgetadaptor ctext-tcl {
    delegate method * to hull
    delegate option * to hull

    constructor args {
        installhull using ctext -background \#eee
        $self install-highlight
        $self configurelist $args
    }

    method install-highlight {} {
        # Stolen from EXAMPLE section of ctext document.
        # https://core.tcl.tk/tklib/doc/trunk/embedded/www/tklib/files/modules/ctext/ctext.html#section6
        
	ctext::addHighlightClass $win widgets purple  [list ctext button label text frame toplevel  scrollbar checkbutton canvas listbox menu menubar menubutton  radiobutton scale entry message tk_chooseDir tk_getSaveFile  tk_getOpenFile tk_chooseColor tk_optionMenu]
	ctext::addHighlightClass $win flags orange  [list -text -command -yscrollcommand  -xscrollcommand -background -foreground -fg -bg  -highlightbackground -y -x -highlightcolor -relief -width  -height -wrap -font -fill -side -outline -style -insertwidth  -textvariable -activebackground -activeforeground -insertbackground  -anchor -orient -troughcolor -nonewline -expand -type -message  -title -offset -in -after -yscroll -xscroll -forward -regexp -count  -exact -padx -ipadx -filetypes -all -from -to -label -value -variable  -regexp -backwards -forwards -bd -pady -ipady -state -row -column  -cursor -highlightcolors -linemap -menu -tearoff -displayof -cursor  -underline -tags -tag]
	ctext::addHighlightClass $win stackControl red  {proc uplevel namespace while for foreach if else}
	ctext::addHighlightClassWithOnlyCharStart $win vars mediumspringgreen "\$"
	ctext::addHighlightClass $win variable_funcs gold {set global variable unset}
	ctext::addHighlightClassForSpecialChars $win brackets green {[]{}}
	ctext::addHighlightClassForRegexp $win paths lightblue {\.[a-zA-Z0-9\_\-]+}
	ctext::addHighlightClassForRegexp $win comments khaki {\#[^\n\r]*}
    }
}

if {![info level] && [info script] eq $::argv0} {
    apply {{} {
        pack [ctext-tcl .win] -fill both -expand yes
        if {$::argv ne ""} {
            set fh [open [lindex $::argv 0]]
            .win insert end [read $fh]
            close $fh
        }
    }}
}

#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require snit
package require sqlite3
package require widget::scrolledwindow

source [file dirname [info script]]/ctext_tcl.tcl
source [file dirname [info script]]/rotext.tcl

namespace eval cmdlistener {
    proc string-or {str args} {
	foreach str [list $str {*}$args] {
	    if {$str ne ""} {
		return $str
	    }
	}
    }
}

snit::widgetadaptor cmdlistener {
    delegate method * to hull
    delegate option * to hull

    option -command ""

    option -store-type sqlite
    option -store-options ""

    variable myHistIdx ""

    component myListener -public text
    variable myListenerStatus ""
    component myMinibuffer -public entry
    component myStore -public history
    component myResultView

    typevariable ourTextBindings CmdListner

    typevariable ourHistKind -array [list command command]

    constructor args {
        installhull using ttk::panedwindow -orient vertical

        set storeType [from args -store-type sqlite]
        install myStore using cmdlistener::store-$storeType $self.store \
            {*}[from args -store-options ""]

        $self configurelist $args

        set myHistIdx [$myStore histno max]

        #----------------------------------------
        # Listener
        $hull add [set lf [ttk::labelframe $win.v[incr i] -text Input]]
        pack [set sw [widget::scrolledwindow $lf.sw]] -fill both -expand yes
        install myListener using ctext_tcl $sw.ctext -linemap 0 -undo yes -autoseparator yes -height 3
        $sw setwidget $myListener

        #----------------------------------------
        # Status bar and Minibuffer
        pack [set status [ttk::frame $lf.status]] -fill x -expand no
        pack [ttk::label $status.label -textvariable [myvar myListenerStatus]] -fill none -expand no -side left
        install myMinibuffer using ttk::entry $status.entry -width 0
        pack $myMinibuffer -fill x -expand yes -side left

        pack [ttk::label [set w $status.l[incr i]] -text "#"] -fill none -expand no -side left


        pack [ttk::label $status.l[incr i] -textvariable [myvar myHistIdx]] -fill none -expand no -side left
        $status configure -height [winfo reqheight $w]

        #----------------------------------------
        # ResultView
        $hull add [set lf [ttk::labelframe $win.v[incr i] -text Result]]
        pack [set sw [widget::scrolledwindow $lf.sw]] -fill both -expand yes
        install myResultView using rotext $sw.result -height 10
        $sw setwidget $myResultView
        $myResultView tag configure separator -borderwidth 2 -relief sunken

        #----------------------------------------
        $self setup keybind
    }

    method {setup keybind} {} {
        bindtags $myListener.t [list $myListener $myListener.t $ourTextBindings . all]
        bind $myListener <Control-Return> "$self Submit; break"
        bind $myListener <Control-p> "$self up-line-or-history; break"
        bind $myListener <Control-n> "$self down-line-or-history; break"
        bind $myListener <Alt-p> "$self history up; break"
        bind $myListener <Alt-n> "$self history down; break"

        # Start reverse incremental search
        bind $myListener <Control-r> "$self minibuffer open-for search-back; break"

        # Keybind for backward search mode minibuffer
        bind search-back#$myMinibuffer-then <Key> \
            [list $self search back]
        bind search-back#$myMinibuffer-then <Control-r> \
            [list $self search back]
        # bind search-back#$myMinibuffer-then <Control-s> \
        #     [list $self search forward]
        bind search-back#$myMinibuffer-then <Key-Escape> \
            [list $self minibuffer normal]
    }

    method up-line-or-history {} {
        if {[$myListener compare "insert linestart" == 1.0]} {
            $self history up
        } else {
            tk::TextSetCursor $myListener.t [tk::TextUpDownLine $myListener.t -1]
        }
    }

    method down-line-or-history {} {
        if {[$myListener compare insert == end-1c]} {
            $self history down
        } else {
            tk::TextSetCursor $myListener.t [tk::TextUpDownLine $myListener.t 1]
        }
    }

    method {history up} {} {
        $self history replace-by $myHistIdx -1 end
    }
    method {history down} {} {
        $self history replace-by $myHistIdx +1 "1.0 lineend"
    }

    method {history replace-by} {histIx offset cursorIx} {
        if {$histIx eq ""} return
        if {$offset < 0 && $histIx <= 0} return
        if {$offset > 0 && [$myStore histno max] <= $histIx} return
        incr histIx $offset
        set text [$myStore get $ourHistKind(command) $histIx]
        $myListener delete 1.0 end
        $myListener edit reset
        $myListener insert end $text
        $myListener mark set insert $cursorIx
        set myHistIdx $histIx
    }

    method Submit {} {
        set script [$myListener get 1.0 end-1c]
        set result [if {$options(-command) ne ""} {
            {*}$options(-command) $script
        } else {
            uplevel #0 $script
        }]
        $self result append $result
        set myHistIdx [$self history add $ourHistKind(command) $script]
    }

    method {result append} result {
        $myResultView insert end "\n" "" "\n" separator
        $myResultView see insert
        $myResultView insert end $result result
    }

    method {search back} {} {
        if {[set found [$myStore search back *[$myMinibuffer get]* $myHistIdx]] eq ""} {
            set myListenerStatus "failing $myMinibufferMode: "
        } else {
            $self history replace-by $found 0 end
        }
    }

    variable myMinibufferMode ""
    method {minibuffer normal} {} {
        set myMinibufferMode ""
        set myListenerStatus ""
        $myMinibuffer delete 0 end
        bindtags $myMinibuffer [list $myMinibuffer [winfo class $myMinibuffer] \
                                    . all]
        focus $myListener.t
    }

    method {minibuffer open-for} {mode} {
        set myMinibufferMode $mode
        set myListenerStatus "$mode: "
        focus $myMinibuffer
        bindtags $myMinibuffer [list $mode#$myMinibuffer \
                                    $myMinibuffer [winfo class $myMinibuffer] \
                                    $mode#$myMinibuffer-then\
                                    . all]
    }

    typeconstructor {
        foreach ev [bind Text] {
            bind $ourTextBindings $ev [bind Text $ev]
        }

        bind $ourTextBindings <Key-space> {
            tk::TextInsert %W %A
            if {[%W cget -autoseparators]} {
                %W edit separator
            }
        }
    }
}

snit::type cmdlistener::store-sqlite {
    option -store-filename sysopcon.db3
    option -store-dir ""

    option -debug yes

    component myDB
    method get {kind rowid} {
        # XXX: $kind is useless this time.
        $self DB onecolumn {
            select script from history where kind = $kind and rowid = $rowid
        }
    }
    method add {kind script} {
        set at [clock seconds]
        $self DB eval {
            insert into history(at, kind, script)
            values($at, $kind, $script)
        }
        $self DB last_insert_rowid
    }
    method {search back} {text from} {
        $self DB onecolumn {
            select hist_id from history where script glob $text
            and hist_id <= $from
            order by hist_id desc
            limit 1
        }
    }

    method {histno max} {} {
        $self DB eval {select max(rowid) from history}
    }
    method DB args {
        if {$myDB eq ""} {
            set myDB $self.db
            set dbFile [cmdlistener::string-or $options(-store-dir) [pwd]]/$options(-store-filename)
            if {$options(-debug)} {puts "opening db $dbFile..."}
            sqlite3 $myDB $dbFile
            $self create-tables $myDB
        }
        if {$args ne ""} {
            uplevel 1 [list $myDB {*}$args]
        } else {
            set myDB
        }
    }
    method create-tables {DB} {
        $DB transaction {
            foreach {name DDL} {
                history {
                    create table history
                    (hist_id integer primary key
                     , at integer not null default 0
                     , kind text not null default ''
                     , script text not null default ''
                     )
                }
            } {
                if {[$DB exists {
                    select * from sqlite_master where name = $name and type = 'table'
                }]} continue
                $DB eval $DDL
            }
        }
    }
}

if {![info level] && [info script] eq $::argv0} {
    
    pack [cmdlistener .win] -fill both -expand yes

}

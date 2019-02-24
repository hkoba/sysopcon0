#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require snit
package require sqlite3
package require widget::scrolledwindow

source [file dirname [info script]]/ctext_tcl.tcl

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
    
    component myListener -public text
    component myStore -public history
    component myHistView

    typevariable ourTextBindings CmdListner

    constructor args {
        installhull using ttk::panedwindow -orient vertical

        set storeType [from args -store-type sqlite]
        install myStore using cmdlistener::store-$storeType $self.store \
            {*}[from args -store-options ""]
        
        $self configurelist $args

        #----------------------------------------
        set sw [widget::scrolledwindow $win.sw[incr w]]
        install myHistView using listbox $sw.histview -height 3 -background #eee
        $sw setwidget $myHistView
        bind $myHistView <<ListboxSelect>> [list $self hist-insert active]

        #----------------------------------------
        $hull add [set sw [widget::scrolledwindow $win.sw[incr w]]]
        install myListener using ctext_tcl $sw.ctext -linemap 0 -undo yes -autoseparator yes
        $sw setwidget $myListener
        
        bindtags $myListener.t [list $myListener $myListener.t $ourTextBindings . all]
        bind $myListener <Control-Return> "$self Submit; break"
        bind $myListener <Control-p> "$self prev-or-openhist; break"
    }
    
    method prev-or-openhist {} {
        scan [$myListener index insert] %d.%d line char
        if {$line == 1} {
            $self openhist end
            $self hist-insert active
        } else {
            tk::TextSetCursor $myListener.t [tk::TextUpDownLine $myListener.t -1]
        }
    }

    method hist-insert index {
        set loggedScript [$myHistView get $index]
        # XXX: modified なら…
        $myListener delete 1.0 end
        $myListener edit reset
        $myListener insert end [regsub {^[\d:]+ } $loggedScript {}]
    }

    method openhist {{index ""}} {
        if {$index eq ""} {
            if {![winfo ismapped $myHistView]} {
                $hull insert 0 [winfo parent $myHistView]
            }
        } else {
            focus $myHistView
            $myHistView activate $index
            $myHistView selection set $index
        }
    }

    method Submit {} {
        set script [$myListener get 1.0 end-1c]
        if {$options(-command) ne ""} {
            {*}$options(-command) $script
        } else {
            puts [list submit $script]
        }
        $self history add command $script
        $self openhist
        $myHistView insert end "[clock format [clock seconds] -format {%H:%M:%S}] $script"
        $myHistView see end
        $myListener delete 1.0 end
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
    method add {kind script} {
        set at [clock seconds]
        $self DB eval {
            insert into history(at, kind, script)
            values($at, $kind, $script)
        }
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
    
    pack [cmdlistener .win]

}

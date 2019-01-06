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

snit::widget cmdlistener {
    option -command ""

    option -store-type sqlite
    option -store-options ""
    
    component myView

    component myStore -public history

    typevariable ourClass CmdListner

    constructor args {
        set storeType [from args -store-type sqlite]
        install myStore using cmdlistener::store-$storeType $self.store \
            {*}[from args -store-options ""]
        
        $self configurelist $args

        pack [set sw [widget::scrolledwindow $win.sw]] -fill both -expand yes
        install myView using ctext_tcl $sw.ctext -linemap 0 -undo yes -autoseparator yes
        $sw setwidget $myView
        
        bindtags $myView.t [list $myView $myView.t $ourClass . all]

        bind $myView <Control-Return> "$self Submit; break"
    }
    
    method Submit {} {
        set script [$myView get 1.0 end-1c]
        $self history add command $script
        if {$options(-command) ne ""} {
            {*}$options(-command) $script
        } else {
            puts [list submit $script]
        }
    }

    typeconstructor {
        foreach ev [bind Text] {
            bind $ourClass $ev [bind Text $ev]
        }

        bind $ourClass <Key-space> {
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

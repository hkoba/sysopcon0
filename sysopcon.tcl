#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require fileutil
package require snit
package require widget::scrolledwindow

apply {{realScriptFn} {
    
    if {[info commands ::console] eq ""} {
        if {![catch {package require tclreadline}]} {
            proc ::console method {
                if {[info exists ::tclreadline::_in_loop]} return
                set ::tclreadline::_in_loop 1
                switch $method {
                    show {
                        after idle tclreadline::Loop
                    }
                }
            }
        }
    }

    set appDir [file dirname $realScriptFn]

    namespace eval ::sysopcon \
        [list ::variable appDir $appDir]
    
    source $appDir/libtcl/minhtmltk0/minhtmltk0.tcl

}} [fileutil::fullnormalize [info script]]


snit::widget sysopcon {

    option -view-dir ""

    typemethod defaultViewDir {} {return [set ${type}::appDir]/view}

    component myMenu
    component myTopHPane
    component myInputVPane
    component myOutputVPane

    component myInputEditor
    
    component myOutputView

    constructor args {
        $self build-gui

        $self configurelist $args

        $self Redraw
    }
    
    method build-gui {} {
        install myMenu using menu [winfo toplevel $win].menu
        [winfo toplevel $win] configure -menu $myMenu

        #----------------------------------------
        install myTopHPane using ttk::panedwindow $win.toph -orient horizontal
        
        install myInputVPane using ttk::panedwindow $myTopHPane.inputv -orient vertical

        $myInputVPane add [set sw [widget::scrolledwindow $myInputVPane.w[incr i]]]
        install myInputEditor using text $sw.edit
        $sw setwidget $myInputEditor

        #----------------------------------------

        install myOutputVPane using ttk::panedwindow $myTopHPane.outputv -orient vertical
        
        $myOutputVPane add [set sw [widget::scrolledwindow $myOutputVPane.w[incr i]]]

        install myOutputView using text $sw.output
        $sw setwidget $myOutputView
    }
    
    method Redraw {} {

        $myMenu delete 0 end
        $myMenu add cascade -label File -menu [set m [menu $myMenu.m[incr M]]]
        $m add separator
        $m add command -label Quit -command [list exit]; #XXX confirm

        $myMenu add cascade -label Debug -menu [set m [menu $myMenu.m[incr M]]]
        $m add command -label {Open Readline on TTY} \
            -command [list console show]

        $myTopHPane add $myInputVPane
        $myTopHPane add $myOutputVPane

        pack $myTopHPane -fill both -expand yes
    }

    method open-view viewFn {
        
        $myView replace_location_html $viewFn \
            [$myView read_file $viewFn]
    }
}

if {![info level] && [info script] eq $::argv0} {
    
    apply {{} {

        set opts [::minhtmltk::utils::parsePosixOpts ::argv]

        pack [sysopcon .win {*}$opts] -fill both -expand yes
        
        if {$::argv ne ""} {
            puts [.win {*}$::argv]
        }
    }}
}

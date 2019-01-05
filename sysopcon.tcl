#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require fileutil
package require snit
package require widget::scrolledwindow

apply {{realScriptFn} {
    
    set appDir [file dirname $realScriptFn]

    namespace eval ::sysopcon \
        [list ::variable appDir $appDir]
    
    source $appDir/libtcl/minhtmltk0/minhtmltk0.tcl

}} [fileutil::fullnormalize [info script]]


snit::widget sysopcon {

    option -view-dir ""

    typemethod defaultViewDir {} {return [set ${type}::appDir]/view}

    component myTopHPane
    component myInputVPane
    component myOutputVPane

    component myInputEditor

    constructor args {

        install myTopHPane using ttk::panedwindow $win.toph -orient horizontal
        
        install myInputVPane using ttk::panedwindow $myTopHPane.inputv -orient vertical

        $myInputVPane add [set sw [widget::scrolledwindow $myInputVPane.w[incr i]]]
        install myInputEditor using text $sw.edit
        $sw setwidget $myInputEditor

        install myOutputVPane using ttk::panedwindow $myTopHPane.outputv -orient vertical

        $self Redraw

    }
    
    method Redraw {} {

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

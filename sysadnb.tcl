#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require fileutil
package require snit

apply {{realScriptFn} {
    
    set appDir [file dirname $realScriptFn]

    namespace eval ::sysadmin-notebook \
        [list ::variable appDir $appDir]
    
    source $appDir/libtcl/minhtmltk0/minhtmltk0.tcl

}} [fileutil::fullnormalize [info script]]


snit::widget sysadmin-notebook {

    option -view default.html
    option -view-dir ""

    typemethod defaultViewDir {} {return [set ${type}::appDir]/view}

    component myView -public view

    constructor args {

        install myView using minhtmltk $win.html

        $self configurelist $args
        
        if {$options(-view-dir) eq ""} {
            set options(-view-dir) [$type defaultViewDir]
        }

        $self Redraw

    }
    
    method Redraw {} {

        if {$options(-view) ne ""} {
            $self open-view $options(-view-dir)/$options(-view)
        }

        pack $myView -fill both -expand yes
    }

    method open-view viewFn {
        
        $myView replace_location_html $viewFn \
            [$myView read_file $viewFn]

    }
}

if {![info level] && [info script] eq $::argv0} {
    
    apply {{} {

        set opts [::minhtmltk::utils::parsePosixOpts ::argv]

        pack [sysadmin-notebook .win {*}$opts] -fill both -expand yes
        
        if {$::argv ne ""} {
            puts [.win {*}$::argv]
        }
    }}
}

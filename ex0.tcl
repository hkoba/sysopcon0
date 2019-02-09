#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require fileutil

apply {{realScriptFn} {
    set appDir [file dirname $realScriptFn]

    
    source $appDir/libtcl/minhtmltk0/minhtmltk0.tcl

    source $appDir/libtcl/yatt_tcl/yatt_tcl.tcl
    source $appDir/libtcl/TclTask/TclTaskRunner.tcl
    
    source $appDir/libtcl/minhtmltk0/navigator/common_macro.tcl
    source $appDir/libtcl/minhtmltk0/navigator/scheme/file.tcl

}}  [fileutil::fullnormalize [info script]]


snit::type yattnav {

    ::minhtmltk::navigator::common_macro
    ::minhtmltk::navigator::file_scheme

    typevariable ourExtension .ytcl
    typevariable ourProtocol htcl 

    component myYatt -inherit yes

    constructor args {
        $self location-init

        install myYatt using yatt_tcl $self.yatt \
            -template-ext $ourExtension -tcl-namespace ${selfns}::yatt

        $self configurelist $args
    }
    destructor {
        $self location-forget
    }

    method {scheme htcl read_from} {uriObj opts} {
        set ext [file extension [$uriObj path]]

        set meth [list filetype $ext render]
        set html [if {[$self info methods $meth] ne ""} {
            $self {*}$meth [$uriObj path]
        } else {
            $self read_text [$uriObj path]
        }]

        $myBrowser replace_location_html [$uriObj get] $html $opts
    }
    
    method {filetype .ytcl render} path {
        $myYatt render_file $path
    }
}

snit::widget ex0 {
    
    component myView -inherit yes
    component myNavigator
    delegate option -doc-root to myNavigator
    
    constructor args {
        install myNavigator using yattnav $self.nav
        install myView using minhtmltk $win.html -navigator $myNavigator
        
        $self configurelist $args

        pack $myView -fill both -expand yes
    }
}

if {![info level] && [info script] eq $::argv0} {
    apply {{} {
        set opts [::minhtmltk::utils::parsePosixOpts ::argv]
        
        pack [ex0 .win {*}$opts] -fill both -expand yes

        if {$::argv ne ""} {
            # まずここで一回 event loop へ
            after idle {puts [.win {*}$::argv]}
        }
    }}
}


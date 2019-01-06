#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require fileutil
package require snit
package require widget::scrolledwindow

# thread?

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
    source $appDir/libtcl/sshcomm/sshcomm.tcl
    source $appDir/libtcl/rotext.tcl
    source $appDir/libtcl/cmdlistener.tcl

    source $appDir/libtcl/TclTask0/TclTaskRunner.tcl
    # XXX: Not worked. ::sshcomm::register-plugin ::TaskRunner

}} [fileutil::fullnormalize [info script]]


snit::widget sysopcon {

    option -view-dir ""

    typemethod defaultViewDir {} {return [set ${type}::appDir]/view}

    component myMenu
    component myTopHPane
    component myInputVPane
    component myOutputVPane

    component myListener
    
    component myOutputView

    component myRunner
    component myRunCommand

    constructor args {
        $self build-gui

        $self configurelist $args

        $self interactive

        $self Redraw
    }
    
    method build-gui {} {
        install myMenu using menu [winfo toplevel $win].menu -tearoff 0
        [winfo toplevel $win] configure -menu $myMenu

        #----------------------------------------
        install myTopHPane using ttk::panedwindow $win.toph -orient horizontal

        #----------------------------------------        
        $myTopHPane add [set vf [ttk::labelframe $myTopHPane.input -text Input]]
        install myInputVPane using ttk::panedwindow $vf.pane -orient vertical
        pack $myInputVPane -fill both -expand yes

        install myListener using cmdlistener $myInputVPane.listener \
            -command [list $self runner run]
        $myInputVPane add $myListener

        #----------------------------------------
        $myTopHPane add [set vf [ttk::labelframe $myTopHPane.output -text Output]]
        install myOutputVPane using ttk::panedwindow $vf.pane -orient vertical
        pack $myOutputVPane -fill both -expand yes
        
        $myOutputVPane add [set sw [widget::scrolledwindow $myOutputVPane.w[incr i]]]

        install myOutputView using rotext $sw.output
        $sw setwidget $myOutputView
    }
    
    method interactive {} {
        
        bind [winfo toplevel $win] WM_DELETE_WINDOW [list after idle exit]

    }

    method Redraw {} {

        $myMenu delete 0 end
        ::tk::AmpMenuArgs $myMenu add cascade -label &File -menu [set m [menu $myMenu.m[incr M] -tearoff 0]] 
        
        $m add separator
        ::tk::AmpMenuArgs $m add command -label &Quit -command [list exit]; #XXX confirm

        $myMenu add cascade -label Debug -menu [set m [menu $myMenu.m[incr M]]]
        $m add command -label {Open Readline on TTY} \
            -command [list console show]

        $myOutputView tag configure $ourOutputTag(result) \
            -background #eee
        $myOutputView tag configure $ourOutputTag(separator) \
            -borderwidth 2 -relief sunken

        $myOutputView tag raise sel

        pack $myTopHPane -fill both -expand yes
    }

    typevariable ourOutputTag -array \
        [apply {args {set ls []; foreach i $args {lappend ls $i $i}; set ls}} \
             result separator]

    method {runner run} script {
        if {$myRunCommand eq ""} {
            error "Not yet connected!"
        }
        set result [{*}$myRunCommand $script]
        $myOutputView see end
        $myOutputView insert end $result $ourOutputTag(result)
        if {![regexp {\n$} $result]} {
            $myOutputView insert end "\n"
        }
        $myOutputView insert end "\n" $ourOutputTag(separator)
    }

    method ssh host {
        if {$myRunner ne ""} {
            error "Already connected!"
        }
        # コマンド行から ssh $host で起動した場合、
        # ここでもう一度 event loop に戻らないと、exit 呼んでも終了しなくなる
        # XXX: なぜ二回？
        after idle [list $self connect $host]
        return ""
    }
    method connect host {
        set myRunner [sshcomm::connection $self.%AUTO% -host $host \
                          -plugins [list ::TclTaskRunner]]
        set cid [$myRunner comm new]
        set myRunCommand [list apply {{cid script} {
            comm::comm send $cid $script
        }} $cid]
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
            # まずここで一回 event loop へ
            after idle {puts [.win {*}$::argv]}
        }
    }}
}

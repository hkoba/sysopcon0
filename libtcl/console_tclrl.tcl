#!/usr/bin/tclsh
# -*- coding: utf-8; mode: tcl; tab-width: 4 -*-

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


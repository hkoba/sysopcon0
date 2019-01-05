#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require snit

snit::widgetadaptor rotext {
    typevariable ourROEvents {}

    delegate method * to hull
    delegate option * to hull

    constructor args {
        
        installhull using text
        
        $self configurelist $args

        bindtags $win [list $win ROText . all]
    }

    typeconstructor {
        set ourROEvents []
        foreach ev [bind Text] {
            if {[lsearch -sorted $ourKnownWritingEvents $ev] >= 0} continue
            set handler [bind Text $ev]
            if {[lmap pat $ourKnownWritingPattern {
                if {![regexp $pat $handler]} continue
                list found
            }] ne ""} {
                continue
            }
            
            lappend ourROEvents $ev
        }

        foreach ev $ourROEvents {
            bind ROText $ev [bind Text $ev]
        }
    }

    typevariable ourKnownWritingEvents [lsort {
        <Control-Key-h>
        <Meta-Key-Delete>
        <Meta-Key-BackSpace>
        <Meta-Key-d>
        <<Redo>>
        <<Undo>>
        <Control-Key-t>
        <Control-Key-o>
        <Control-Key-k>
        <Control-Key-d>
        <Key>
        <Key-Insert>
        <<PasteSelection>>
        <<Clear>>
        <<Paste>>
        <<Cut>>
        <Key-BackSpace>
        <Key-Delete>
        <Key-Return>
        <Control-Key-i>
        <Key-Tab>
    }]
    
    typevariable ourKnownWritingPattern {
        {%W delete}
        {%W edit redo}
        {%W edit undo}
        {tk::TextTranspose %W}
        {%W insert insert}
        {tk::TextInsert %W}
        {tk::TextPasteSelection %W}
        {tk_textPaste %W}
        {tk_textCut %W}
    }
}

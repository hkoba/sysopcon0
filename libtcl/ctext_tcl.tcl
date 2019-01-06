#!/usr/bin/wish
# -*- coding: utf-8; mode: tcl -*-

package require ctext
package require snit

snit::widgetadaptor ctext-tcl {
    delegate method * to hull
    delegate option * to hull

    constructor args {
        installhull using ctext -background \#eee
        $self install-highlight
        $self configurelist $args
    }

    method install-highlight {} {
        # See also
        # https://core.tcl.tk/tklib/doc/trunk/embedded/www/tklib/files/modules/ctext/ctext.html#section6
        
	ctext::addHighlightClass $win commands blue \
            [list {*}$ourTclBuiltinList]

	ctext::addHighlightClass $win typewords \#228b22 \
            [list {*}$ourTclTypewordList]

	ctext::addHighlightClass $win keywords purple \
            [list {*}$ourTclKeywordList ]

	ctext::addHighlightClassWithOnlyCharStart $win vars \#a0522d "\$"
	ctext::addHighlightClassForSpecialChars $win square_brackets green {[]}
	ctext::addHighlightClassForRegexp $win comments brown {\#[^\n\r]*}
	ctext::addHighlightClassForRegexp $win string red {".*"}

    }

    typevariable ourTclBuiltinList {
        after
        append
        apply
        array
        auto_execok
        auto_import
        auto_load
        auto_mkindex
        auto_path
        auto_qualify
        auto_reset
        bgerror
        binary
        break
        catch
        cd
        chan
        clock
        close
        concat
        continue
        coroutine
        dde
        dict
        encoding
        eof
        error
        eval
        exec
        exit
        expr
        fblocked
        fconfigure
        fcopy
        file
        fileevent
        filename
        flush
        for
        foreach
        format
        gets
        glob
        global
        history
        http
        if
        incr
        info
        interp
        join
        lappend
        lassign
        lindex
        linsert
        list
        llength
        lmap
        load
        lrange
        lrepeat
        lreplace
        lreverse
        lsearch
        lset
        lsort
        memory
        msgcat
        my
        namespace
        next
        nextto
        oo::class
        oo::copy
        oo::define
        oo::objdefine
        oo::object
        open
        package
        parray
        pid
        pkg_create
        pkg_mkIndex
        proc
        puts
        pwd
        read
        regexp
        registry
        regsub
        rename
        return
        scan
        seek
        self
        set
        socket
        source
        split
        string
        subst
        switch
        tailcall
        tcl_endOfWord
        tcl_findLibrary
        tcl_startOfNextWord
        tcl_startOfPreviousWord
        tcl_wordBreakAfter
        tcl_wordBreakBefore
        tcltest
        tell
        throw
        time
        tm
        trace
        try
        unknown
        unload
        unset
        update
        uplevel
        upvar
        variable
        vwait
        while
        yield
        yieldto
    }

    typevariable ourTclTypewordList {
alias
aliases
anchor
anymore
append
appname
args
aspect
atime
atom
atomname
attributes
bbox
bgerror
bind
blocked
body
bytelength
cancel
caret
cascade
cells
channels
children
class
clicks
client
close
cmdcount
code
colormapfull
colormapwindows
columnconfigure
command
commands
common
compare
complete
component
configure
containing
copy
create
current
debug
default
deiconify
delete
depth
dirname
donesearch
ensemble
eof
equal
eval
event
executable
exists
export
expose
extension
filter
first
flush
focusmodel
for
forget
format
fpixels
frame
functions
geometry
get
gets
global
globals
grid
group
height
hidden
hide
hostname
hulltype
iconbitmap
iconify
iconmask
iconname
iconphoto
iconposition
iconwindow
id
idle
import
inactive
incr
index
info
inherit
inscope
interps
invokehidden
is
isdirectory
isfile
ismapped
issafe
itk_option
join
keys
lappend
last
length
level
library
limit
link
loaded
locals
location
lstat
manage
manager
map
marktrusted
match
maxsize
merge
microseconds
milliseconds
minsize
mkdir
mtime
name
nameofexecutable
names
nativename
nextelement
normalize
option
origin
overrideredirect
owned
pack
parent
patchlevel
path
pathname
pathtype
pending
photo
pixels
place
pointerx
pointerxy
pointery
positionfrom
postevent
private
procs
propagate
protected
protocol
public
puts
qualifiers
range
read
readable
readlink
recursionlimit
remove
rename
repeat
replace
reqheight
reqwidth
resizable
reverse
rgb
rootname
rootx
rooty
rowconfigure
scaling
scan
screen
screencells
screendepth
screenheight
screenmmheight
screenmmwidth
screenvisual
screenwidth
script
seconds
seek
separator
server
set
share
sharedlibextension
show
size
sizefrom
slaves
split
stackorder
startsearch
stat
state
statistics
style
system
tail
target
tclversion
tell
title
tolower
toplevel
totitle
toupper
transfer
transient
trim
trimleft
trimright
truncate
type
unknown
unset
update
upvar
useinputmethods
values
variable
vars
viewable
visual
visualid
visualsavailable
volumes
vrootheight
vrootwidth
vrootx
vrooty
which
width
windowingsystem
with
withdraw
wordend
wordstart
writable
x
y
nil
    }

    typevariable ourTclKeywordList {
require

configure configurelist cget
itemconfigure itemcget

insert end see index
delete destroy add
create

auto cr crlf lf

first last
chars indices lines linestart lineend wordstart wordend

method constructor
snit::type
snit::method
snit::widget
snit::widgetadaptor
onconfigure
oncget
typevariable
typeconstructor
typemethod

mymethod
mytypemethod
myvar
myproc
mytypevar

install
installhull
delegate

to using as except hull

tag eq ne in ni

on off yes no
okcancel yesno retrycancel yesnocancel abortretryignore

flat solid ridge groove sunken raised
horizontal vertical

x y both left right center
top bottom baseline

normal active disabled

cp860 cp861 cp862 cp863 cp864 tis-620 cp865 cp866 gb12345 gb2312-raw cp950 cp949 cp869 dingbats ksc5601 cp874 macCentEuro macUkraine gb2312 jis0201 euc-cn euc-jp iso8859-10 macThai iso2022-jp jis0208 macIceland iso2022 iso8859-13 jis0212 iso8859-14 iso8859-15 cp737 iso8859-16 big5 euc-kr macRomania iso2022-kr macTurkish gb1988 macGreek cp437 ascii macRoman iso8859-1 iso8859-2 iso8859-3 ebcdic koi8-r macCroatian iso8859-4 iso8859-5 cp1250 macCyrillic iso8859-6 cp1251 cp1252 iso8859-7 macDingbats koi8-u cp1253 iso8859-8 iso8859-9 cp1254 cp850 cp1255 cp1256 cp932 cp1257 cp852 identity cp1258 macJapan shiftjis utf-8 cp855 cp936 symbol cp775 unicode cp857

WM_DELETE_WINDOW
WM_TAKE_FOCUS
WM_SAVE_YOURSELF
    }

}

if {![info level] && [info script] eq $::argv0} {
    apply {{} {
        pack [ctext-tcl .win] -fill both -expand yes
        if {$::argv ne ""} {
            set fh [open [lindex $::argv 0]]
            .win insert end [read $fh]
            close $fh
        }
    }}
}

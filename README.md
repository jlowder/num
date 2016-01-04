# Num

This is a simple interactive tool for the command line that converts between 
hex, decimal, and binary. It also can also apply several binary operations to
the current value (invert, reverse, shifting left/right, etc). This makes it
useful for experimenting with hex dump data where the format is unknown, or
where the data may be inverted or bit shifted. When entering data, extraneous
characters such as spaces and punctuation are ignored, which makes it easy to
paste values from other applications.

The interface uses the current mode (decimal, hex, or binary) as the prompt and
displays the current value in all three bases. A "?" displays the help menu:


    $ num
    DEC> ?
    Usage:
    
    w: change register width (default 32)
    b: binary entry mode
    h: hexadecimal entry mode
    d: decimal entry mode
    e: display english words
    i: invert bits
    l: shift left one bit
    r: shift right one bit
    v: reverse bit order
    c: copy current mode's value to the clipboard (requires xsel command)
    m: display roman numerals
    q: quit
    DEC> 
    


(defsystem num
    :name "Num"
    :version "0.9.0"
    :author "Jason Lowdermilk <jlowdermilk@gmail.com>"
    :license "MIT"
    :description "Interactive decimal/hex/binary converter"
    :long-description "Simple command-line tool for converting and manipulating numbers"
    :depends-on (:cl-ppcre
                 :prompt)
    :components ((:file "num")))

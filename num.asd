(defsystem num
    :name "com.lowdermilk.num"
    :version "1.0.0"
    :author "Jason Lowdermilk"
    :description "Interactive decimal/hex/binary converter"
    :long-description "Simple command-line tool for converting and manipulating numbers"
    :serial t
    :depends-on (:cl-ppcre
                 :prompt)
    :components ((:file "num")))

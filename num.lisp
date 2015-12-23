(in-package :cl-user)

(defpackage :com.lowdermilk.num
  (:use :common-lisp
        :com.lowdermilk.prompt)
  (:export :main))

(in-package :com.lowdermilk.num)

(defparameter *mode* :dec)
(defparameter *number* 0)
(defparameter *modenames* '(:dec "DEC" :hex "HEX" :bin "BIN"))
(defparameter *radixes* '(:dec 10 :hex 16 :bin 2))
(defparameter *bitwidth* 32)
(defparameter *prompts* '())

(defun bit-vector->integer (bit-vector)
  "Create a positive integer from a bit-vector."
  (reduce #'(lambda (first-bit second-bit)
              (+ (* first-bit 2) second-bit))
          bit-vector))

(defun integer->bit-vector (integer)
  "Create a bit-vector from a positive integer."
  (labels ((integer->bit-list (int &optional accum)
             (cond ((> int 0)
                    (multiple-value-bind (i r) (truncate int 2)
                      (integer->bit-list i (push r accum))))
                   ((null accum) (push 0 accum))
                   (t accum))))
    (coerce (integer->bit-list integer) 'bit-vector)))

(defun pad (bv bits)
  (loop for x from 1 to (- bits (length bv))
       do (setf bv (concatenate 'bit-vector #*0 bv)))
  bv)

(defun getval (mode)
  (cond 
    ((eql mode :dec) "~A: ~A~%")
    ((eql mode :hex) (format nil "~~A: 0x~~~A,'0x~~%" (truncate (fceiling (/ *bitwidth* 4)))))
    ((eql mode :bin) (format nil "~~A: ~~~A,'0b~~%" *bitwidth*))))
  
(defun display (num)
  (setf *number* num)
  (loop for mode in '(:dec :hex :bin)
     for str = (getval mode)
     do (format t str (getf *modenames* mode) num)))

(defun show-english ()
  (format t "~:(~r~)~%" *number*))

(defun show-roman ()
  (format t "~@r~%" *number*))

(defun invert ()
  (let ((bv (bit-not (pad (integer->bit-vector *number*) *bitwidth*))))
    (display (bit-vector->integer bv))))

(defun shift-right ()
  (let ((bv (pad (integer->bit-vector *number*) *bitwidth*)))
    (display (bit-vector->integer (subseq (concatenate 'vector #*0 bv) 0 *bitwidth*)))))
  
(defun shift-left ()
  (let ((bv (pad (integer->bit-vector *number*) *bitwidth*)))
    (display (bit-vector->integer (concatenate 'vector (subseq bv 1) #*0)))))

(defun reverse-num ()
  (let ((bv (pad (integer->bit-vector *number*) *bitwidth*)))
    (display (bit-vector->integer (reverse bv)))))
  
(defmacro with-shell-command ((cmd line) &body body)
  `(let ((out (sb-ext:process-output (sb-ext:run-program "/bin/sh" (list "-c" ,cmd) :wait nil :output :stream))))
     (with-open-stream (out out)
       (loop for ,line = (read-line out nil)
          while ,line do
            ,@body))))

(defun clipboard ()
  (let* ((str1 (subseq (getval *mode*) 4))
         (str (reverse (subseq (reverse str1) 2)))
         (val (format nil str *number*)))
    (with-shell-command ((format nil "echo -n '~A' | xsel -i" val) line)
      (format t "~A~%" line))
    (with-shell-command ((format nil "echo -n '~A' | xsel -i -b" val) line)
      (format t "~A~%" line))))

(defprompt ("q" "quit" *prompts*)
  (end-prompt))

(defprompt ("m" "display roman numerals" *prompts*)
  (show-roman))

(defprompt ("c" "copy current mode's value to the clipboard" *prompts*)
  (clipboard))

(defprompt ("v" "reverse bit order" *prompts*)
  (reverse-num))

(defprompt ("r" "shift right one bit" *prompts*)
  (shift-right))

(defprompt ("l" "shift left one bit" *prompts*)
  (shift-left))

(defprompt ("i" "invert bits" *prompts*)
  (invert))

(defprompt ("e" "display english words" *prompts*)
  (show-english))

(defprompt ("d" "decimal entry mode" *prompts*)
  (setf *mode* :dec)
  (setf (get 'prompt *prompts*) (concatenate 'string (getf *modenames* *mode*) "> ")))

(defprompt ("h" "hexadecimal entry mode" *prompts*)
  (setf *mode* :hex)
  (setf (get 'prompt *prompts*) (concatenate 'string (getf *modenames* *mode*) "> ")))

(defprompt ("b" "binary entry mode" *prompts*)
  (setf *mode* :bin)
  (setf (get 'prompt *prompts*) (concatenate 'string (getf *modenames* *mode*) "> ")))

(defprompt ("w" "change register width (default 32)" *prompts*)
  (setf *bitwidth* (parse-integer (poparg) :junk-allowed t))
  (display *number*))

;            (cl-ppcre:regex-replace-all " " (cl-ppcre:regex-replace-all " - " command "") "")
(defdefault (*prompts*)
  (display (parse-integer
            (cl-ppcre:regex-replace-all "[^0-9a-fA-F]" command "")
            :radix (getf *radixes* *mode*) :junk-allowed t)))

(defun main ()
  (prompt 
   (format nil "~A> " (getf *modenames* *mode*))
   *prompts* :helpname "?"))


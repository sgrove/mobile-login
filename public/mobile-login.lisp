(defun js-output ()
  (parenscript:ps
    (ps:chain console (log "Whatever, we're loading up some scripts now."))
    (alert "At least alert?")
    (ps:chain ($ document)
              (ready #'(lambda ()
                         (setf (ps:chain $ mobile-loginify)
                               #'(lambda (element-id)
                                   (let* ((is-iphone           (not (= (ps:chain navigator user-agent (index-of "iPhone")) 1)))
                                          ($element            ($ element-id))
                                          (temp-canvase-element (ps:chain $element (append "<canvas id='mobile-login-canvas'>This login methods requires a browser with &gt;canvas&lt; support</canvas>")))
                                          ($canvas             ($ "canvas#mobile-login-canvas"))
                                          (ctx                 (ps:chain (ps:@ $canvas 0) (get-context "2d")))
                                          (width               (ps:chain $canvas (offset) left))
                                          (height              (ps:chain $canvas (offset) top))
                                          (button-count        5)
                                          (inactive            0)
                                          (active              1)
                                          (dead                2)
                                          (buttons             (ps:array))
                                          (button-width        nil)
                                          (button-height       nil)
                                          (last-button-touched nil)
                                          (last-button-active  nil)
                                          (move-list           (ps:array))
                                          (password            nil))

                                     (defun is-null (item)
                                       (ps:=== item null))

                                     (defun elog (item)
                                       (ps:chain console (log item))
                                       true)

                                     (defun inspect (item)
                                       (ps:chain console (inspect item))
                                       true)

                                     (elog $element)
                                     
                                     (defun recursive-log (arr level)
                                       (let ((log-string ""))
                                         (setf level (or level 0))
                                         (dotimes (counter level)
                                           (incf log-string #\Tab))
                                         
                                         (dotimes (counter (length arr))
                                           (if (ps:instanceof (aref arr counter) *Array)
                                               (recursive-log (aref arr counter) (+ level 1))
                                               (progn
                                                 (incf log-string (ps:chain (aref arr counter) (to-string)))
                                                 (incf log-string "\n"))))
                                         (ps:chain console (log log-string))))

                                     (defun log-array (item)
                                       (ps:chain console (log (recursive-log item))))

                                     (defun log-moves ()
                                       (log-array move-list))

                                     (defun array-clone (arr)
                                       (log-array arr)
                                       (let ((a (ps:array)))
                                         (ps:for-in (property  arr)
                                                    (setf (aref a property) (if (ps:instanceof (aref arr property) *array)
                                                                                (array-clone (aref arr property))
                                                                                (aref arr property))))
                                         a))

                                     (defun array-push-unique (arr value)
                                       (dotimes (counter (length arr))
                                         (if (or (= (aref arr counter) value)
                                                 (array-equal (aref arr counter) value))
                                             (return arr)))
                                       (ps:chain arr (push value)))

                                       (defun array-equal (a b)
                                         (when (not (= (length a)
                                                           (length b)))
                                           (return false))
                                         
                                         (dotimes (counter (length a))
                                           (when (not (= (aref a counter)
                                                             (aref b counter)))
                                             (return false)))
                                         true)

                                       (defun ugly-recurse-arrays-equal-hack (a b)
                                         (when (not (= (length a)
                                                           (length b)))
                                           (return false))
                                         
                                         (dotimes (counter (length a))
                                           (when (not (array-equal (aref a counter)
                                                                   (aref b counter)))
                                             (return false)))
                                         
                                         true)

                                     (defun check-login (call-back)
                                       (let ((temp-move-list (array-clone move-list))
                                             (temp-last-button-active last-button-active))

                                         (log-moves)
                                         
                                        ; clear the board
                                         (reset-buttons)
                                         (draw-window)
                                         
                                        ; Don't worry about accidental taps
                                         (when (< (length temp-move-list) 0)
                                           (return))
                                         
                                        ; Set password first time through for demo purposes
                                         (when (is-null password)
                                           (alert "Setting password")
                                           (setf password temp-move-list)
                                           (return))
                                         
                                         (if (ugly-recurse-arrays-equal-hack temp-move-list password)
                                             (call-back true)
                                             (call-back false)))))

                                        ; Make entering combo a bit easier by restricting branching options
                                   (defun move-contiguous? (last-move current-move)
                                     (when ((is-null last-move)) (return true)) ; First move is always fine
                                     
                                     (when (and (not (= (aref last-move 0)
                                                            (aref current-move 0)))
                                                (not (= (aref last-move 1)
                                                            (aref current-move 1))))
                                       (return false)) ; Easy check
                                     
                                     (when (and (= (aref last-move 1)
                                                       (aref current-move 1))
                                                (not (= 1 (abs (- (aref last-move 0)
                                                                      (aref current-move 0))))))
                                       (return false)) ; horizontal move?
                                     
                                     (when (and (= (aref last-move 0)
                                                       (aref current-move 0))
                                                (not (= 1 (abs (- (aref last-move 1)
                                                                      (aref current-move 1))))))
                                       (return false)) ; vertical move?
                                     
                                     true)


                               (defun touch-move ($event)
                                 (ps:chain $event (prevent-default))
                                 (if (= (ps:@ $event original-event length) 1)
                                     (let* ((event (ps:@ $event original-event))
                                            (touch (aref (ps:@ event touches) 0))
                                            ($node ($ (ps:@ touch target)))
                                            (button-id (position-to-button (ps:@ touch page-x)
                                                                           (ps:@ touch page-y))))
                                       
                                       (when ((is-null button-id)) (return null))
                                       
                                       (when (move-contiguous? last-button-active button-id)
                                         (progn
                                           (setf last-button-touched (or last-button-touched button-id))
                                           
                                           (if (not (array-equal last-button-touched button-id))
                                               (progn
                                                 (set-button-state last-button-touched dead)
                                                 (setf lash-button-touched button-id)))
                                           
                                           (when (is-button-active button-id)
                                             (progn
                                               (setf last-button-active button-id)
                                               (set-button-state button-id active true)
                                               (array-push-unique move-list button-id))))))))

                         (defun set-resolution ()
                           (setf (ps:@ ctx canvas width) (ps:@ ctx canvas client-width))
                           (setf (ps:@ ctx canvas height) (ps:@ ctx canvas client-height))
                           true)

                         (defun draw-scene ()
                           (let* ((line-width 2)
                                  (line-height 2)
                                  (x 0)
                                  (y 0)
                                  (button-width  (- (floor (/ (ps:@ ctx canvas width)  button-count)) line-width))
                                  (button-height (- (floor (/ (ps:@ ctx canvas height) button-count)) line-height)))
                             
                             (dotimes (i button-count)
                               (dotimes (j button-count)
                                 (setf x (+ line-width (* button-width i)))
                                 (setf y (+ line-height (* button-height j)))
                                 (let ((active-gradient   (ps:chain ctx (create-linear-gradient x y x (+ y button-height))))
                                       (dead-gradient     (ps:chain ctx (create-linear-gradient x y x (+ y button-height))))
                                       (inactive-gradient (ps:chain ctx (create-linear-gradient x y x (+ y button-height)))))
                                   (ps:chain active-gradient   (add-color-stop 0 "#5555FF"))
                                   (ps:chain active-gradient   (add-color-stop 1 "#6670FF"))
                                   (ps:chain dead-gradient     (add-color-stop 0 "#FF5555"))
                                   (ps:chain dead-gradient     (add-color-stop 1 "#552222"))
                                   (ps:chain inactive-gradient (add-color-stop 0 "#667077"))
                                   (ps:chain inactive-gradient (add-color-stop 1 "#222222"))
                                   
                                   
                                   (cond ((= active (aref buttons i j)) (setf (ps:@ ctx fill-style) active-gradient))
                                         ((= dead (aref buttons i j))   (setf (ps:@ ctx fill-style) dead-gradient))
                                         (t (setf (ps:@ ctx fill-style) inactive-gradient)))
                                   
                                   (ps:chain ctx (fill-rect x y button-width button-height)))))
                             
                             (setf (ps:@ ctx fill-style) "#99B9CC")
                             (dotimes (counter button-count)
                               (ps:chain ctx (fill-rect 0 (* button-height counter) (ps:chain ctx canvas width) line-height))
                               (ps:chain ctx (fill-rect (* button-width counter) 0 line-width (ps:chain ctx canvas height))))
                             
                             (setf (ps:@ ctx font) "bold 2em san-serif")
                             (setf (ps:@ ctx fill-style) "white")
                             
                             (dotimes (i button-count)
                               (dotimes (j button-count)
                                 (ps:chain ctx (fill-text "*" 
                                                          (- (+ line-height (* button-width i) (/ button-width 2)) 9)
                                                          (- (+ line-height (* button-height j) (/ button-height 2)) 10)))))))

                     (defun draw-window ()
                       (set-resolution)
                       (draw-scene))

                     (defun position-to-button (x y)
                       (let ((i (floor (/ x button-width)))
                             (j (floor (/ y button-height))))
                         (ps:array i j)))

                     (defun reset-buttons ()
                       (setf buttons (ps:array))
                       (setf move-list (ps:array))
                       (setf last-button-touched nil)
                       (setf last-button-active nil)
                         
                         (dotimes (i button-count)
                           (let ((row (ps:array)))
                             (dotimes (j button-count)
                               (ps:chain row (push inactive)))
                             (ps:chain buttons (push row)))))

                       (let* ((is-button #'(lambda (position state)
                                             (= state (aref buttons (aref position 0) (aref position 1)))))
                              (is-button-maker #'(lambda (value)
                                                   #'(lambda (position)
                                                       (is-button position value))))
                              (is-button-dead (is-button-maker dead))
                              (is-button-active (is-button-maker active))
                              (is-button-inactive (is-button-maker inactive))
                              (set-button-state #'(lambda (position state redraw)
                                                    (setf (aref buttons (aref position 0) (aref position 1)) state)
                                                    (when (ps:=== redraw true)
                                                      (draw-window)))))
                         
                         (ps:chain ($ "window") (bind "resize" draw-window))
                         (ps:chain ($ "#container") (bind "touchmove" touch-move))
                         (ps:chain ($ "#container") (bind "touchend" #'(lambda ()
                                                                         (check-login #'(lambda (result)
                                                                                          (if result
                                                                                              (alert "Logged in!")
                                                                                              (alert "Couldn't log in.")))))))
                         
                         (reset-buttons)
                         (draw-window))))

                         (ps:chain $ (mobile-loginify "div#login-container"))

                         (log-moves))))))

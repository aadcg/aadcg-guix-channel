(define-module (packages aadcg-emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages texinfo)
  #:use-module ((guix licenses) #:prefix license:))

(define-public aadcg-emacs-maxima
  (package
    (name "aadcg-emacs-maxima")
    (version "0.7.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.com/sasanidas/maxima")
             (commit version)))
       (file-name
        (git-file-name name version))
       (sha256
        (base32 "17m9x3yy0k63j59vx1sf25jcfb6b9yj0ggp2jiq1mih4b62rp97d"))))
    (build-system emacs-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         ;; These files depend on other packages and its functionality
         ;; is orthogonal to maxima.el
         (add-after 'unpack 'move-source-files
           (lambda _
             (delete-file "company-maxima.el")
             (delete-file "poly-maxima.el")
             #t)))))
    (propagated-inputs
     (list emacs-s emacs-test-simple))
    (home-page "https://gitlab.com/sasanidas/maxima")
    (synopsis "Major mode for the computer algebra system Maxima.")
    (description "Some of the features include font highlight, smart
indentation, help functions, imenu integration, latex support,
autocompletion support and maxima subprocess integration.")
    (license license:gpl3+)))

(define-public aadcg-emacs-exwm
  (package
    (inherit emacs-exwm)
    (name "aadcg-emacs-exwm")
    (propagated-inputs (list emacs-xelb font-iosevka))
    (arguments
     `(#:emacs ,emacs
       #:phases
       (modify-phases %standard-phases
         (add-after 'build 'install-xsession
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (xsessions (string-append out "/share/xsessions"))
                    (bin (string-append out "/bin"))
                    (exwm-executable (string-append bin "/exwm")))
               ;; Add a .desktop file to xsessions
               (mkdir-p xsessions)
               (mkdir-p bin)
               (make-desktop-entry-file (string-append xsessions "/exwm.desktop")
                                        #:name "Lisp Machine (Emacs)"
                                        #:exec exwm-executable
                                        #:try-exec exwm-executable)
               ;; Add a shell wrapper to bin
               (with-output-to-file exwm-executable
                 (lambda _
                   (format #t "#!~a ~@
                     ~a +SI:localuser:$USER ~@
                     exec ~a --exit-with-session ~a \"$@\" -mm --debug-init -fn iosevka-20 ~%"
                           (search-input-file inputs "/bin/sh")
                           (search-input-file inputs "/bin/xhost")
                           (search-input-file inputs "/bin/dbus-launch")
                           (search-input-file inputs "/bin/emacs"))))
               (chmod exwm-executable #o555)
               #t))))))))

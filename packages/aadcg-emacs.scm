(define-module (packages aadcg-emacs)
  #:use-module (guix)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages acl)
  #:use-module (gnu packages web)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module ((guix licenses) #:prefix license:))

(define-public aadcg-emacs
  (package
    (inherit emacs)
    (name "aadcg-emacs")
    (version "28.2")
    (source
     (origin (method url-fetch)
             (uri (string-append "mirror://gnu/emacs/emacs-" version ".tar.xz"))
             (sha256 (base32 "12144dcaihv2ymfm7g2vnvdl4h71hqnsz1mljzf34cpg6ci1h8gf"))
             (patches
              (parameterize
                  ((%patch-path
                    (map (lambda (directory)
                           (string-append directory "/packages/patches"))
                         %load-path)))
                ;; TODO doesn't work...
                (search-patches "emacs-exec-path.patch"
                                "emacs-fix-scheme-indent-function.patch"
                                "emacs-source-date-epoch.patch"
                                "emacs-ditch-leim.patch"
                                "emacs-ditch-iswitchb.patch"
                                ;; "emacs-ditch-cedet.patch")
                                )))

             (modules '((guix build utils)))
             (snippet
              '(with-directory-excursion "lisp"
                 (for-each delete-file-recursively
                           '("emulation"
                             "obsolete"
                             "play"
                             "leim"
                             "erc"      ;rcirc is much smaller
                             ;; sly relies on cedet/pulse.el
                             ;; "cedet"
                             ))

                 ;; Delete bloat
                 (for-each delete-file
                           '("emacs-lisp/eieio-datadebug.el" ; depends on cedet
                             "org/ol-irc.el" ; depends on erc

                             "progmodes/xscheme.el"
                             "progmodes/verilog-mode.el"
                             "progmodes/vera-mode.el"
                             "progmodes/tcl.el"
                             "progmodes/modula2.el"
                             "progmodes/cfengine.el"
                             "progmodes/dcl-mode.el"
                             "progmodes/pascal.el"
                             "progmodes/opascal.el"
                             "progmodes/bat-mode.el"
                             "progmodes/vhdl-mode.el"
                             "progmodes/simula.el"

                             "textmodes/remember.el"
                             "textmodes/underline.el"
                             "textmodes/tildify.el"

                             "net/newsticker.el"
                             "net/newst-backend.el"
                             "net/newst-plainview.el"
                             "net/newst-reader.el"
                             "net/newst-treeview.el"

                             ;; "autoarg.el"
                             ;; "dos-fns.el"
                             ;; "dos-w32.el"
                             ;; "dos-vars.el"
                             ;; "descr-text.el"
                             ;; "windmove.el"
                             ;; "pixel-scroll.el"
                             ;; "xt-mouse.el"
                             ;; "t-mouse.el"
                             ;; "vt100-led.el"
                             ;; "vt-control.el"
                             ;; "w32-fns.el"
                             ;; "w32-vars.el"
                             ;; "strokes.el"
                             ;; "tab-bar.el"
                             ;; "talk.el"
                             ;; "linum.el"
                             ;; "lpr.el"
                             ;; "ido.el"
                             ;; "buff-menu.el"
                             ;; "cmuscheme.el"
                             ;; "isearchb.el"
                             ;; "dabbrev.el"

                             "international/ogonek.el"
                             "international/quail.el"
                             "international/titdic-cnv.el"
                             "international/rfc1843.el"
                             "international/ucs-normalize.el"
                             "international/ccl.el"
                             "international/ja-dic-cnv.el"
                             "international/kinsoku.el"
                             "international/kkc.el"
                             "international/ja-dic-utl.el"))

                 ;; Delete the bundled byte-compiled elisp files and generated
                 ;; autoloads.
                 (for-each delete-file
                           (append (find-files "." "\\.elc$")
                                   (find-files "." "loaddefs\\.el$")
                                   (find-files "eshell" "^esh-groups\\.el$")))

                 ;; Make sure Tramp looks for binaries in the right places on
                 ;; remote Guix System machines, where 'getconf PATH' returns
                 ;; something bogus.
                 (substitute* "net/tramp.el"
                   ;; Patch the line after "(defcustom tramp-remote-path".
                   (("\\(tramp-default-remote-path")
                    (format #f "(tramp-default-remote-path ~s ~s ~s ~s "
                            "~/.guix-profile/bin" "~/.guix-profile/sbin"
                            "/run/current-system/profile/bin"
                            "/run/current-system/profile/sbin")))

                 ;; Make sure Man looks for C header files in the right
                 ;; places.
                 (substitute* "man.el"
                   (("\"/usr/local/include\"" line)
                    (string-join
                     (list line
                           "\"~/.guix-profile/include\""
                           "\"/var/guix/profiles/system/profile/include\"")
                     " ")))))))))

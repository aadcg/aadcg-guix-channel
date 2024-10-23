(define-module (packages aadcg-nyxt)
  #:use-module (guix build-system gnu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages c)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web-browsers)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module ((guix licenses) #:prefix license:))

(define-public aadcg-nyxt
  (package
    (name "aadcg-nyxt")
    (version "3.12.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/atlas-engineer/nyxt")
             (commit version)
             (recursive? #t)))
       (sha256
        (base32
         "0nilfqcsily1y7x641cby5wsbh5va6jcfn8bx3fr90gjgccwvay0"))
       (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags (list "nyxt"
                          (string-append "DESTDIR=" (assoc-ref %outputs "out"))
                          "PREFIX=")
       #:strip-binaries? #f             ; Stripping breaks SBCL binaries.
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'fix-so-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "_build/cl-plus-ssl/src/reload.lisp"
               (("libssl.so" all)
                (string-append (assoc-ref inputs "openssl") "/lib/" all))
               (("libcrypto.so" all)
                (string-append (assoc-ref inputs "openssl") "/lib/" all)))
             (substitute* "_build/iolib/src/syscalls/ffi-functions-unix.lisp"
               (("\\(:default \"libfixposix\"\\)")
                (string-append "(:default \""
                               (assoc-ref inputs "libfixposix")
                               "/lib/libfixposix\")")))
             (substitute* "_build/cl-sqlite/sqlite-ffi.lisp"
               (("libsqlite3" all)
                (string-append (assoc-ref inputs "sqlite") "/lib/" all)))
             (substitute* "_build/cl-gobject-introspection/src/init.lisp"
               (("libgobject-2\\.0\\.so")
                (search-input-file inputs "/lib/libgobject-2.0.so"))
               (("libgirepository-1\\.0\\.so")
                (search-input-file inputs "/lib/libgirepository-1.0.so")))
             (substitute* "_build/cl-webkit/webkit2/webkit2.init.lisp"
               (("libwebkit2gtk" all)
                (string-append (assoc-ref inputs "webkitgtk-for-gtk3") "/lib/" all)))
             (substitute* "_build/cl-cffi-gtk/glib/glib.init.lisp"
               (("libglib-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all)))
               (("libgthread-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/gobject/gobject.init.lisp"
               (("libgobject-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/gio/gio.init.lisp"
               (("libgio-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/cairo/cairo.init.lisp"
               (("libcairo\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/pango/pango.init.lisp"
               (("libpango-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all)))
               (("libpangocairo-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/gdk-pixbuf/gdk-pixbuf.init.lisp"
               (("libgdk_pixbuf-[0-9.]*\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/gdk/gdk.init.lisp"
               (("libgdk-[0-9]\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))
             (substitute* "_build/cl-cffi-gtk/gdk/gdk.package.lisp"
               (("libgtk-[0-9]\\.so" all)
                (search-input-file inputs (string-append "/lib/" all))))))
         (add-after 'unpack 'fix-clipboard-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "_build/trivial-clipboard/src/text.lisp"
               (("\"xsel\"")
                (string-append "\"" (assoc-ref inputs "xsel") "/bin/xsel\""))
               (("\"wl-copy\"")
                (string-append "\"" (assoc-ref inputs "wl-clipboard") "/bin/wl-copy\""))
               (("\"wl-paste\"")
                (string-append "\"" (assoc-ref inputs "wl-clipboard") "/bin/wl-paste\"")))))
         (add-before 'build 'fix-common-lisp-cache-folder
           (lambda _ (setenv "HOME" "/tmp")))
         (add-before 'check 'configure-tests
           (lambda _ (setenv "NASDF_TESTS_NO_NETWORK" "1")))
         (add-after 'install 'wrap-program
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((gsettings (assoc-ref inputs "gsettings-desktop-schemas")))
               (wrap-program (string-append (assoc-ref outputs "out") "/bin/nyxt")
                 `("GIO_EXTRA_MODULES" prefix
                   (,(string-append (assoc-ref inputs "glib-networking")
                                    "/lib/gio/modules")))
                 `("GI_TYPELIB_PATH" prefix (,(getenv "GI_TYPELIB_PATH")))
                 `("LD_LIBRARY_PATH" ":" prefix (,(string-append gsettings "/lib")))
                 `("XDG_DATA_DIRS" ":" prefix (,(string-append gsettings "/share"))))))))))
    (native-inputs (list cl-lisp-unit2 sbcl))
    (inputs (list cairo
                  git
                  glib
                  glib-networking
                  gobject-introspection
                  gsettings-desktop-schemas
                  gst-libav
                  gst-plugins-bad
                  gst-plugins-base
                  gst-plugins-good
                  gst-plugins-ugly
                  gtk+
                  gdk-pixbuf
                  libfixposix
                  openssl
                  pango
                  pkg-config
                  sqlite
                  webkitgtk-for-gtk3
                  wl-clipboard
                  xsel))
    (synopsis "Extensible web-browser in Common Lisp")
    (home-page "https://nyxt-browser.com/")
    (description "Nyxt is a keyboard-oriented, extensible web-browser designed
for power users.  The application has familiar Emacs and VI key-bindings and
is fully configurable and extensible in Common Lisp.")
    (license license:bsd-3)))

(define-public aadcg-nyxt-latest
  (let ((commit "bac6949eb149ed91763c25afe29a63aed8f5b395")
        (revision "0"))
    (package
      (name "aadcg-nyxt-latest")
      (version (git-version "4.0.0" revision commit))
      (source
       (origin (method git-fetch)
               (uri (git-reference (url "https://github.com/atlas-engineer/nyxt")
                                   (commit commit)
                                   (recursive? #t)))
               (file-name (git-file-name name version))
               (sha256 (base32 "17smln9d2dzs8zgqfsa15ybqpz5schdgm90yq8zpcxjfb3kkzkf5"))))
      (build-system gnu-build-system)
      (arguments
       `(#:make-flags (list "nyxt"
                            (string-append "DESTDIR=" (assoc-ref %outputs "out"))
                            "PREFIX=")
         #:strip-binaries? #f           ; Stripping breaks SBCL binaries.
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)
           (add-after 'unpack 'fix-so-paths
             (lambda* (#:key inputs #:allow-other-keys)
               (substitute* "_build/cl-plus-ssl/src/reload.lisp"
                 (("libssl.so" all)
                  (string-append (assoc-ref inputs "openssl") "/lib/" all))
                 (("libcrypto.so" all)
                  (string-append (assoc-ref inputs "openssl") "/lib/" all)))
               (substitute* "_build/iolib/src/syscalls/ffi-functions-unix.lisp"
                 (("\\(:default \"libfixposix\"\\)")
                  (string-append "(:default \""
                                 (assoc-ref inputs "libfixposix")
                                 "/lib/libfixposix\")")))
               (substitute* "_build/cl-sqlite/sqlite-ffi.lisp"
                 (("libsqlite3" all)
                  (string-append (assoc-ref inputs "sqlite") "/lib/" all)))
               (substitute* "_build/cl-gobject-introspection/src/init.lisp"
                 (("libgobject-2\\.0\\.so")
                  (search-input-file inputs "/lib/libgobject-2.0.so"))
                 (("libgirepository-1\\.0\\.so")
                  (search-input-file inputs "/lib/libgirepository-1.0.so")))
               (substitute* "_build/cl-webkit/webkit2/webkit2.init.lisp"
                 (("libwebkit2gtk" all)
                  (string-append (assoc-ref inputs "webkitgtk-for-gtk3") "/lib/" all)))
               (substitute* "_build/cl-cffi-gtk/glib/glib.init.lisp"
                 (("libglib-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all)))
                 (("libgthread-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/gobject/gobject.init.lisp"
                 (("libgobject-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/gio/gio.init.lisp"
                 (("libgio-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/cairo/cairo.init.lisp"
                 (("libcairo\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/pango/pango.init.lisp"
                 (("libpango-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all)))
                 (("libpangocairo-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/gdk-pixbuf/gdk-pixbuf.init.lisp"
                 (("libgdk_pixbuf-[0-9.]*\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/gdk/gdk.init.lisp"
                 (("libgdk-[0-9]\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))
               (substitute* "_build/cl-cffi-gtk/gdk/gdk.package.lisp"
                 (("libgtk-[0-9]\\.so" all)
                  (search-input-file inputs (string-append "/lib/" all))))))
           (add-after 'unpack 'fix-clipboard-paths
             (lambda* (#:key inputs #:allow-other-keys)
               (substitute* "_build/trivial-clipboard/src/text.lisp"
                 (("\"xsel\"")
                  (string-append "\"" (assoc-ref inputs "xsel") "/bin/xsel\""))
                 (("\"wl-copy\"")
                  (string-append "\"" (assoc-ref inputs "wl-clipboard") "/bin/wl-copy\""))
                 (("\"wl-paste\"")
                  (string-append "\"" (assoc-ref inputs "wl-clipboard") "/bin/wl-paste\"")))))
           (add-before 'build 'fix-common-lisp-cache-folder
             (lambda _ (setenv "HOME" "/tmp")))
           (add-before 'check 'configure-tests
             (lambda _ (setenv "NASDF_TESTS_NO_NETWORK" "1")))
           (add-after 'install 'wrap-program
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (let ((gsettings (assoc-ref inputs "gsettings-desktop-schemas")))
                 (wrap-program (string-append (assoc-ref outputs "out") "/bin/nyxt")
                   `("GIO_EXTRA_MODULES" prefix
                     (,(string-append (assoc-ref inputs "glib-networking")
                                      "/lib/gio/modules")))
                   `("GI_TYPELIB_PATH" prefix (,(getenv "GI_TYPELIB_PATH")))
                   `("LD_LIBRARY_PATH" ":" prefix (,(string-append gsettings "/lib")))
                   `("XDG_DATA_DIRS" ":" prefix (,(string-append gsettings "/share"))))))))))
      (native-inputs (list sbcl))
      (inputs (list cairo
                    gdk-pixbuf
                    glib
                    glib-networking
                    gobject-introspection
                    gsettings-desktop-schemas
                    gst-libav
                    gst-plugins-bad
                    gst-plugins-base
                    gst-plugins-good
                    gst-plugins-ugly
                    gtk+
                    libfixposix
                    openssl
                    pango
                    pkg-config
                    sqlite
                    webkitgtk-for-gtk3
                    wl-clipboard
                    xsel))
      (synopsis "Extensible web-browser in Common Lisp")
      (home-page "https://nyxt-browser.com/")
      (description "Nyxt is a keyboard-oriented, extensible web-browser designed
for power users.  The application has familiar Emacs and VI key-bindings and
is fully configurable and extensible in Common Lisp.")
      (license license:bsd-3))))

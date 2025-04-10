(define-module (packages aadcg-lisp-xyz)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system asdf)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module ((guix licenses) #:prefix license:))

(define-public sbcl-cl-cffi-cairo
  (let ((commit "d6d16cdae23c707ea138cc4305e802963a44eeb4")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-cairo")
      (version (git-version "0.0.5" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-cairo/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-cairo" version))
         (sha256
          (base32 "1v512538hiv60rq52dn5aw6skk3y432a0zr6326w0g3wf6dmfsfm"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list cairo
                    sbcl-cffi
                    sbcl-iterate))
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/cairo.init.lisp"
                  (("libcairo\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-cairo/")
      (synopsis "Common Lisp binding for Cairo")
      (description
       "@command{cl-cffi-cairo} is a Lisp binding to the Cairo library.")
      (license license:expat))))

(define-public cl-cffi-cairo
  (sbcl-package->cl-source-package sbcl-cl-cffi-cairo))

(define-public ecl-cl-cffi-cairo
  (sbcl-package->ecl-package sbcl-cl-cffi-cairo))

(define-public sbcl-cl-cffi-glib
  (let ((commit "daccbbef184073d31f850517d952d6d17c6e5dbf")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-glib")
      (version (git-version "0.0.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-glib/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-glib" version))
         (sha256
          (base32 "1i5wlraabbk6d0qcqy5vy43xzhb472fb7mw9q1l6y8xidx282cf7"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam
                           sbcl-local-time
                           sbcl-cl-setlocale))
      (inputs (list glib
                    sbcl-bordeaux-threads
                    sbcl-cffi
                    sbcl-closer-mop
                    sbcl-iterate
                    sbcl-trivial-garbage))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "cl-cffi-glib-init.lisp"
                  (("libglib-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))
                  (("libgthread-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))
                  (("libgobject-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))
                  (("libgio-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-glib/")
      (synopsis "Common Lisp binding for GLib, GObject and GIO libraries.")
      (description
       "@command{cl-cffi-glib} is a Lisp binding to parts of the GLib, GObject
and GIO libraries, which is the basis for projects like GTK and Pango.")
      (license license:expat))))

(define-public cl-cffi-glib
  (sbcl-package->cl-source-package sbcl-cl-cffi-glib))

(define-public ecl-cl-cffi-glib
  (sbcl-package->ecl-package sbcl-cl-cffi-glib))

(define-public sbcl-cl-cffi-pango
  (let ((commit "737db774008340845896f8a01d2a401adb7cd627")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-pango")
      (version (git-version "0.0.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-pango/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-pango" version))
         (sha256
          (base32 "1ljq8xp3hd96hxy7zlahjxa4gmb1zz3r4scxlgr91cyfbz7vsp77"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list pango
                    sbcl-iterate
                    sbcl-cl-cffi-glib
                    sbcl-cl-cffi-cairo))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/pango.init.lisp"
                  (("libpango-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))
                  (("libpangocairo-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-pango/")
      (synopsis "Common Lisp binding for Pango")
      (description
       "@command{cl-cffi-pango} is a Lisp binding to the internationalized text
layout and rendering Pango library.")
      (license license:expat))))

(define-public cl-cffi-pango
  (sbcl-package->cl-source-package sbcl-cl-cffi-pango))

(define-public ecl-cl-cffi-pango
  (sbcl-package->ecl-package sbcl-cl-cffi-pango))

(define-public sbcl-cl-cffi-gdk-pixbuf
  (let ((commit "0a7e0b35b8f2efcbc3098f275c28c28db28b5ef0")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-gdk-pixbuf")
      (version (git-version "0.0.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-gdk-pixbuf/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-gdk-pixbuf" version))
         (sha256
          (base32 "0w004faf0wkh0mx566lpvw9d8835896lyxilyznxc69gdcms7b3x"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list gdk-pixbuf
                    sbcl-cffi
                    sbcl-cl-cffi-glib))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/gdk-pixbuf.init.lisp"
                  (("libgdk_pixbuf-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-gdk-pixbuf/")
      (synopsis "Common Lisp binding for GdkPixbuf")
      (description
       "@command{cl-cffi-gdk-pixbuf} is a Lisp binding to to the image loading
GdkPixbuf library.")
      (license license:expat))))

(define-public cl-cffi-gdk-pixbuf
  (sbcl-package->cl-source-package sbcl-cl-cffi-gdk-pixbuf))

(define-public ecl-cl-cffi-gdk-pixbuf
  (sbcl-package->ecl-package sbcl-cl-cffi-gdk-pixbuf))

(define-public sbcl-cl-cffi-graphene
  (let ((commit "e2c0cb5f7bdb0f47dd7bdd6072bac1030301b4e9")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-graphene")
      (version (git-version "0.0.3" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-graphene")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-graphene" version))
         (sha256
          (base32 "1f658zm022zixkhcz2zw4lky6w1hsnldfarznanvi36biv6gs9nh"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list graphene
                    sbcl-cffi
                    sbcl-iterate))
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/graphene.init.lisp"
                  (("libgraphene-[0-9.]*\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-graphene/")
      (synopsis "Common Lisp binding for Graphene")
      (description
       "@command{cl-cffi-graphene} is a Lisp binding to the Graphene library.")
      (license license:expat))))

(define-public cl-cffi-graphene
  (sbcl-package->cl-source-package sbcl-cl-cffi-graphene))

(define-public ecl-cl-cffi-graphene
  (sbcl-package->ecl-package sbcl-cl-cffi-graphene))

(define-public sbcl-cl-cffi-gtk4
  (let ((commit "3b9cfb78c0d9df1ed91ca49b02c5b28b6031dd21")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-gtk4")
      (version (git-version "0.0.5" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-gtk4/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-gtk4" version))
         (sha256
          (base32 "0w5dlci97n4p7apvwkrsn9gfkscd0y94hagmxkbjdq1w0d6hfgjh"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list gtk
                    sbcl-cffi
                    sbcl-cl-cffi-glib
                    sbcl-cl-cffi-cairo
                    sbcl-cl-cffi-pango
                    sbcl-cl-cffi-graphene
                    sbcl-cl-cffi-gdk-pixbuf
                    sbcl-bordeaux-threads
                    sbcl-closer-mop
                    sbcl-iterate
                    sbcl-trivial-features
                    sbcl-split-sequence))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "cl-cffi-gtk4-init.lisp"
                  (("libgtk-[0-9]\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-gtk4/")
      (synopsis "Common Lisp binding for GTK4")
      (description
       "@command{cl-cffi-gtk4} is a Lisp binding to GTK4 which is a library for
creating graphical user interfaces.")
      (license license:expat))))

(define-public cl-cffi-gtk4
  (sbcl-package->cl-source-package sbcl-cl-cffi-gtk4))

(define-public ecl-cl-cffi-gtk4
  (sbcl-package->ecl-package sbcl-cl-cffi-gtk4))

(define-public sbcl-cl-cffi-gtk3
  (let ((commit "ed807278bc2be3f85f6b7dd96caf9d247a3c6d47")
        (revision "0"))
    (package
      (name "sbcl-cl-cffi-gtk3")
      (version (git-version "0.0.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/crategus/cl-cffi-gtk3/")
               (commit commit)))
         (file-name (git-file-name "cl-cffi-gtk3" version))
         (sha256
          (base32 "1fzb4jgaj72fs8iq223fm5778ibfh5ym4zvzs5wsk89yfym37cb8"))))
      (build-system asdf-build-system/sbcl)
      (native-inputs (list sbcl-fiveam))
      (inputs (list gtk+
                    sbcl-cffi
                    sbcl-cl-cffi-glib
                    sbcl-cl-cffi-cairo
                    sbcl-cl-cffi-pango
                    sbcl-cl-cffi-gdk-pixbuf
                    sbcl-split-sequence))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-paths
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "cl-cffi-gtk3-init.lisp"
                  (("libgtk-[0-9]\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))
                  (("libgdk-[0-9]\\.so" all)
                   (search-input-file inputs (string-append "/lib/" all)))))))))
      (home-page "https://github.com/crategus/cl-cffi-gtk3/")
      (synopsis "Common Lisp binding for GTK3")
      (description
       "@command{cl-cffi-gtk3} is a Lisp binding to GTK3 which is a library for
creating graphical user interfaces.")
      (license license:expat))))

(define-public cl-cffi-gtk3
  (sbcl-package->cl-source-package sbcl-cl-cffi-gtk3))

(define-public ecl-cl-cffi-gtk3
  (sbcl-package->ecl-package sbcl-cl-cffi-gtk3))

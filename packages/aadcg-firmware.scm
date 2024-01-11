(define-module (packages aadcg-firmware)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix licenses)
  #:use-module (nonguix licenses)
  #:use-module (nongnu packages linux))

(define (select-firmware keep)
  "Modify linux-firmware copy list to retain only files matching KEEP regex."
  `(lambda _
     (use-modules (ice-9 regex))
     (substitute* "WHENCE"
       (("^(File|Link): *([^ ]*)(.*)" _ type file rest)
        (string-append (if (string-match ,keep file) type "Skip") ": " file rest)))))

(define-public bcm4350-firmware
  (package
    (inherit linux-firmware)
    (name "bcm4350-firmware")
    (arguments
     `(#:license-file-regexp "LICENCE.broadcom_bcm43xx"
       ,@(substitute-keyword-arguments (package-arguments linux-firmware)
           ((#:phases phases)
            `(modify-phases ,phases
               (add-after 'unpack 'select-firmware
                 ,(select-firmware "brcmfmac4350-pcie.bin")))))))
    (home-page "https://wireless.wiki.kernel.org/en/users/drivers/brcm80211")
    (synopsis "Nonfree firmware for the Broadcom BCM4350 wifi chips")
    (description "Nonfree firmware for the Broadcom BCM4350 wifi chips")
    (license
     (nonfree (string-append
               "https://git.kernel.org/pub/scm/linux/kernel/git/firmware"
               "/linux-firmware.git/plain/LICENCE.broadcom_bcm43xx")))))

(define-public intel-i915
  (package
    (inherit linux-firmware)
    (name "intel-i915")
    (arguments
     `(#:license-file-regexp "LICENCE.i915"
       ,@(substitute-keyword-arguments (package-arguments linux-firmware)
           ((#:phases phases)
            `(modify-phases ,phases
               (add-after 'unpack 'select-firmware
                 ,(select-firmware "skl_dmc_ver1_27.bin")))))))
    (home-page "http://lkml.iu.edu/hypermail/linux/kernel/0408.1/2238.html")
    (synopsis "Nonfree firmware for Intel HD Graphics")
    (description "Nonfree firmware for Intel HD Graphics")
    (license
     (nonfree (string-append
               "https://git.kernel.org/pub/scm/linux/kernel/git/firmware"
               "/linux-firmware.git/plain/LICENCE.i915")))))

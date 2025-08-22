;; ---------- project.el ----------
(require 'org)
(require 'ox-html)

;; Paths
(defvar my-website-base-dir
  (file-name-as-directory
   (file-name-directory
    (directory-file-name
     (file-name-directory (or load-file-name buffer-file-name))))))

(defvar my-website-out-dir
  (or (getenv "WEBSITE_OUT_DIR")
      (file-name-concat my-website-base-dir "www")))

;; GH Pages project site at https://USERNAME.github.io/website/
(defvar my-website-baseurl "/website/")

;; Export settings
(setq org-export-time-stamp-file nil
      org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-htmlize-output-type 'css
      org-export-html-coding-system 'utf-8-unix
      org-html-link-org-files-as-html t
      org-link-file-path-type 'relative)

;; Custom link type that does NOT try to resolve files in the source tree.
;; Usage in org: [[abs:papers/desynt.pdf][paper]]
(org-link-set-parameters
 "abs"
 :follow (lambda (path) (browse-url (concat my-website-baseurl path)))
 :export (lambda (path desc backend _)
           (let* ((href (concat my-website-baseurl path))
                  (label (or desc path)))
             (pcase backend
               ('html (format "<a href=\"%s\">%s</a>" href label))
               (_ href)))))

(setq org-publish-project-alist
      `(
        ("website" :components ("pages" "assets-css" "assets-papers"))

        ;; Org pages -> www/
        ("pages"
         :base-directory ,(file-name-concat my-website-base-dir "pages")
         :base-extension "org"
         :recursive t
         :publishing-directory ,my-website-out-dir
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-head ,(format "<link rel=\"stylesheet\" href=\"%scss/style.css\" type=\"text/css\" />"
                             my-website-baseurl)
         :html-preamble t
         :html-postamble nil)

        ;; css/js/images -> www/css/
        ("assets-css"
         :base-directory ,(file-name-concat my-website-base-dir "css")
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|ico"
         :recursive t
         :publishing-directory ,(file-name-concat my-website-out-dir "css")
         :publishing-function org-publish-attachment)

        ;; PDFs/images -> www/papers/
        ("assets-papers"
         :base-directory ,(file-name-concat my-website-base-dir "papers")
         :base-extension "pdf\\|png\\|jpg\\|svg"
         :recursive t
         :publishing-directory ,(file-name-concat my-website-out-dir "papers")
         :publishing-function org-publish-attachment)
        ))

(defun build-site (&optional force)
  "Publish the whole site. With C-u, force rebuild."
  (interactive "P")
  (let ((forcep (or force t))) ;; always force in batch
    (when (fboundp 'org-publish-remove-all-timestamps)
      (org-publish-remove-all-timestamps))
    (when (fboundp 'org-publish-clear-timestamps)
      (org-publish-clear-timestamps))
    (org-publish "website" forcep)))
;; ---------- end project.el ----------

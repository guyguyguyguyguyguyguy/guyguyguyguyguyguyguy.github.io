;; Basic project setup for org-mode static site generator
(require 'org)
(require 'ox-html)

;; Project directories
(defvar my-website-base-dir
  (file-name-as-directory
   (file-name-directory
    (directory-file-name
     (file-name-directory (or load-file-name buffer-file-name))))))

(defvar my-website-out-dir
  (or (getenv "WEBSITE_OUT_DIR")
      (file-name-concat my-website-base-dir "www")))

;; Basic org-export settings
(setq org-export-html-coding-system 'utf-8-unix)
(setq org-html-htmlize-output-type 'css)
(setq org-html-doctype "html5")
(setq org-html-html5-fancy t)
(setq org-export-time-stamp-file nil)
(setq org-html-link-org-files-as-html t)   ;; rewrite .org → .html on export
(setq org-link-file-path-type 'relative)


;; Custom sitemap function (simplified)
(defun my-blog-sitemap (title list)
  "Generate the blog landing page."
  (concat "#+TITLE: " title "\n\n"
          (mapconcat
           (lambda (li)
             (format "* %s" (car li)))
           (cdr list) "\n")))

;; Project configuration
(setq org-publish-project-alist
      `(("website"
         :components ("blog-pages" "blog-static" "website-static" "website-js"))

        ("blog-pages"
         :base-directory ,(file-name-concat my-website-base-dir "pages")
         :base-extension "org"
         :publishing-directory ,my-website-out-dir
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\" />"
         :html-preamble t
         :html-postamble nil)

        ("blog-static"
         :base-directory ,(file-name-concat my-website-base-dir "css")
         :base-extension "css\\|js\\|png\\|jpg\\|gif"
         :publishing-directory ,(file-name-concat my-website-out-dir "css")
         :publishing-function org-publish-attachment
         :recursive t)

        ("website-static"
         :base-directory ,(file-name-concat my-website-base-dir "papers")
         :base-extension "pdf\\|png\\|jpg\\|jpeg"
         :publishing-directory ,(file-name-concat my-website-out-dir "papers")
         :publishing-function org-publish-attachment
         :recursive t)

        ;; JS files (manually written)
        ("website-js"
         :base-directory ,(file-name-concat my-website-base-dir "js")
         :base-extension "js"
         :publishing-directory ,(file-name-concat my-website-out-dir "js")
         :publishing-function org-publish-attachment
         :recursive t)))

;; Function to build the site
(defun build-site (&optional force)
  "Build the website. With prefix argument, force rebuild everything."
  (interactive "P")
  (if force
      (org-publish "website" t)
    (org-publish "website")))

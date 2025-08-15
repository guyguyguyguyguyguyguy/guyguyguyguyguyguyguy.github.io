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
         :components ("blog-articles" "blog-pages" "blog-static"))

        ("blog-articles"
         :base-directory ,(file-name-concat my-website-base-dir "blog")
         :base-extension "org"
         :publishing-directory ,(file-name-concat my-website-out-dir "blog")
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Blog Posts"
         :sitemap-function my-blog-sitemap
         :sitemap-sort-files anti-chronologically
         :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\" />"
         :html-preamble t
         :html-postamble nil)

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
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf"
         :publishing-directory ,(file-name-concat my-website-out-dir "css")
         :publishing-function org-publish-attachment
         :recursive t)))

;; Function to build the site
(defun build-site (&optional force)
  "Build the website. With prefix argument, force rebuild everything."
  (interactive "P")
  (if force
      (org-publish "website" t)
    (org-publish "website")))

(defvar my-website-baseurl
  (or (getenv "SITE_BASEURL")
      "/REPO/"))  ;; e.g. "/my-site/"; for user/org root site use "/"

(setq org-export-global-macros
      `(("baseurl" . ,my-website-baseurl)))

(setq org-html-link-org-files-as-html t)
(setq org-link-file-path-type 'relative)

;; Also use baseurl for CSS so styles load on GH Pages:
(setq org-publish-project-alist
      `(("website"
         :components ("blog-pages" "blog-static" "website-static"))

        ("blog-pages"
         :base-directory ,(file-name-concat my-website-base-dir "pages")
         :base-extension "org"
         :publishing-directory ,my-website-out-dir
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-head ,(format "<link rel=\"stylesheet\" href=\"%scss/style.css\" type=\"text/css\" />"
                             my-website-baseurl)
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
         :base-extension "pdf\\|png\\|jpg"
         :publishing-directory ,(file-name-concat my-website-out-dir "papers")
         :publishing-function org-publish-attachment
         :recursive t)))

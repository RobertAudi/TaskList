require_relative "./task-list/exceptions"
require_relative "./task-list/version"
require_relative "./task-list/parser"

module TaskList
  EXCLUDED_EXTENSIONS = [
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".svg",
    ".sqlite3",
    ".log",
    ".rbc",
    ".sassc",
    ".gem"
  ]

  EXCLUDED_DIRECTORIES = [
    ".git",
    "coverage",
    "config",
    "tmp",
    "cache",
    "log",
    "logs"
  ]

  EXCLUDED_GLOBS = [
    "*~",
    ".DS_Store",
    ".AppleDouble",
    ".LSOverride",
    "Icon",
    "._*",
    ".Spotlight-V100",
    ".Trashes",
    "Thumbs.db",
    "ehthumbs.db",
    "Desktop.ini",
    "$RECYCLE.BIN/",
    "*.cab",
    "*.msi",
    "*.msm",
    "*.msp",
    ".svn/",
    "/CVS/*",
    "*/CVS/*",
    ".cvsignore",
    "*/.cvsignore"
  ]

  VALID_TASKS = [
    "TODO",
    "FIXME",
    "NOTE",
    "BUG",
    "CHANGED",
    "OPTIMIZE",
    "XXX",
    "!!!",
    "???"
  ]
end

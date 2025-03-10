# sqlite3-sqls

This repository contains a custom SQLite3 amalgamation build with pre-enabled compilation options (and possible other customized functions/extensions/options in the future to be added).

The main purpose of this project is to support the [SQLiteStudio project](https://github.com/pawelsalawa/sqlitestudio/), but it may also be useful for others seeking a pre-configured SQLite3 setup. The primary motivation behind creating this repository was the need to properly enable the `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` compilation option (https://sqlite.org/compile.html#enable_update_delete_limit), which requires the amalgamation to be generated correctly. This repository simplifies the process by providing a ready-to-use amalgamation build, as well as pre-built binaries for some platforms.

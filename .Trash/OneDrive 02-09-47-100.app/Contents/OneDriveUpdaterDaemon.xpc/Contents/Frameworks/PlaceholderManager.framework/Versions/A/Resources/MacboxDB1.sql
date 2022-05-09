-- Macbox schema, version 1

-- Create the files table. This is the table that represents all folders and files we know
-- about, and is the source of enumeration.
CREATE TABLE dbfs_files (
    itemid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,              -- The file identifier that we hand back to the OS. This is the
                                                                    -- master identifier, and is guaranteed to be stable across the
                                                                    -- lifetime of the object.
    fsid INTEGER NOT NULL,                                          -- The file FSID
    tagid TEXT COLLATE NOCASE,                                      -- The tagid associated with the record. This may be null if the item
                                                                    -- has never been tagged.
    filetype INTEGER DEFAULT 0 NOT NULL,                            -- The type of file to create. 0 = file, 1 = folder, 2 = root
    anchor INTEGER DEFAULT 0 NOT NULL UNIQUE,                       -- The anchor number, which identifies the sequence that objects were
                                                                    -- inserted, updated, or deleted
    parentid INTEGER NOT NULL,                                      -- The parent object itemid. This can be 0 in the case of the root.
    name TEXT NOT NULL COLLATE NOCASE,                              -- The name of the file. This is not the full path, just the leaf
                                                                    -- name.
    size INTEGER DEFAULT 0 NOT NULL,                                -- Item size
    ctime INTEGER DEFAULT 0 NOT NULL,                               -- Create time
    mtime INTEGER DEFAULT 0 NOT NULL,                               -- Modify time
    tombstoned INTEGER DEFAULT 0 NOT NULL,                          -- Whether the item is tombstoned (deleted)
    uti TEXT NOT NULL COLLATE NOCASE,                               -- The type identifier for the item
    state_flags INTEGER DEFAULT 0 NOT NULL
);

-- Create the general state table
CREATE TABLE dbfs_dbstate (
    name TEXT PRIMARY KEY,                                          -- Key name
    value INTEGER UNIQUE                                            -- Key value
) WITHOUT ROWID;


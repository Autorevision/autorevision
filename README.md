Autorevision
============

A script for extracting version information useful in release/build scripting.

To use pass a type and a path to the desired output file:

```bash
./autorevision.sh <output_type> <file> [<variable>]
```

Passing `--` as the file name will cause output to be redirected to stdout.

If you pass a variable name it will echo it to the standard output.
If used with the sh output it will use the file as a cache for use outside a repo so it can still send the stored values of variables to stdout.

For a list of the variables you can pass see the *Currently Extracted Data* section.

**Note**: The script will only run properly at the root level of the repository that it is in; the path to the output file should always be relative to the root of the repo, not the location of the script.


Currently Supported Output Types
--------------------------------

`h`: A header file suitable for c/c++.

`sh`: A text file suitable for including from a bash script with variables defined.


Currently Supported Repository Types
------------------------------------

* **Git**: A version greater than 1.7.2.3 is recommended.

* **Mercurial**: A version greater than 1.6 is recommended.


Currently Extracted Data
------------------------

`VCS_NUM`: A count of revisions there have been between the current one and the initial one; useful for build numbers.

`VCS_DATE`: The date of the current commit in the ISO 8601 format, including seconds.

`VCS_URI`: Repository dependent: for Git the full refspec & for Mercurial the bookmark or the branch if there is no bookmark.

`VCS_TAG`: The current tag or a synonym for `VCS_URI` if not currently on a tag.

`VCS_FULL_HASH`: A full unique identifier for the current revision.

`VCS_SHORT_HASH`: A shortened version `VCS_FULL_HASH` or a synonym for `VCS_FULL_HASH` if it cannot be shortened.

`VCS_WC_MODIFIED`: Set to 1 if the current working directory has been modified and 0 if not.

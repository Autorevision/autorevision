#!/bin/bash

# Copyright (c) 2012 dak180
# See http://opensource.org/licenses/bsd-license.php for licence terms

# autorevision.sh - a shell script to get git / hg revisions etc. into binary builds.
# To use pass a type and a path to the cache file (if any) or a cache file and the desired single varible to output:
# ./autorevision -t <output_type> [-o <cache_file>]
# ./autorevision -o <cache_file> -s <VARIABLE>
# All output (except for the cache file) will be piped to stdout.
# Note: the script will run at the root level of the repository that it is in.

# Config
TARGETFILE="/dev/stdout"
while getopts ":t:o:s:" OPTION; do
	case $OPTION in
		t)
			AFILETYPE="${OPTARG}"
		;;
		o)
			CACHEFILE="${OPTARG}"
		;;
		s)
			VAROUT="${OPTARG}"
		;;
		?)
			echo "error: Invalid arguments." 1>&2
			exit 1
		;;
	esac
done

if [[ ! -z "${VAROUT}"  ]] && [[ ! -z "${AFILETYPE}" ]]; then
	echo "error: Improper argument combo." 1>&2
	exit 1
fi


# Functions to extract data from different repo types.
# For git repos
function gitRepo {
	cd "$(git rev-parse --show-toplevel)"

	VCS_TYPE="git"

	# Is the working copy clean?
	git diff --quiet HEAD &> /dev/null
	WC_MODIFIED="${?}"

	# Enumeration of changesets
	VCS_NUM="$(git rev-list --count HEAD)"
	if [ -z "${VCS_NUM}" ]; then
		echo "warning: Counting the number of revisions may be slower due to an outdated git version less than 1.7.2.3. If something breaks, please update it." 1>&2
		VCS_NUM="$(git rev-list HEAD | wc -l)"
	fi

	# The full revision hash
	VCS_FULL_HASH="$(git rev-parse HEAD)"

	# The short hash
	VCS_SHORT_HASH="$(echo ${VCS_FULL_HASH} | cut -b 1-7)"

	# Current branch
	VCS_URI=`git rev-parse --symbolic-full-name --verify $(git name-rev --name-only --no-undefined HEAD)`

	# Current tag (or uri if there is no tag)
	VCS_TAG="$(git describe --exact-match --tags 2>/dev/null)"
	if [ -z "${VCS_TAG}" ]; then
		VCS_TAG="${VCS_URI}"
	fi

	# Date of the curent commit
	VCS_DATE="$(git log -1 --pretty=format:%ci | sed -e 's/ /T/' | sed -e 's/ //')"
}

# For hg repos
function hgRepo {
	cd "$(hg root)"

	VCS_TYPE="hg"

	# Is the working copy clean?
	hg sum | grep -q 'commit: (clean)'
	WC_MODIFIED="${?}"

	# Enumeration of changesets
	VCS_NUM="$(hg id -n | tr -d '+')"

	# The full revision hash
	VCS_FULL_HASH="$(hg log -r ${VCS_NUM} -l 1 --template '{node}\n')"

	# The short hash
	VCS_SHORT_HASH="$(hg id -i | tr -d '+')"

	# Current bookmark (bookmarks are roughly equivalent to git's branches) or branch if no bookmark
	VCS_URI="$(hg id -B | cut -d ' ' -f 1)"
	# Fall back to the branch if there are no bookmarks
	if [ -z "${VCS_URI}" ]; then
		VCS_URI="$(hg id -b)"
	fi

	# Current tag (or uri if there is no tag)
	if [ "$(hg log -r ${VCS_NUM} -l 1 --template '{latesttagdistance}\n')" = "0" ]; then
		VCS_TAG="`hg id -t | sed -e 's:qtip::' -e 's:tip::' -e 's:qbase::' -e 's:qparent::' -e "s:$(hg --color never qtop 2>/dev/null)::" | cut -d ' ' -f 1`"
	else
		VCS_TAG="${VCS_URI}"
	fi

	# Date of the curent commit
	VCS_DATE="$(hg log -r ${VCS_NUM} -l 1 --template '{date|isodatesec}\n'   | sed -e 's/ /T/' | sed -e 's/ //')"
}

# For svn repos
function svnRepo {
	VCS_TYPE="svn"

	# Is the working copy clean?
        test -z "$(svn diff 2>/dev/null)"
	WC_MODIFIED=$?

	# Enumeration of changesets
	VCS_NUM="$(svn info | sed -n 's/Last Changed Rev: //p')"

	# The full revision hash
	VCS_FULL_HASH="$VCS_NUM"

	# The short hash
	VCS_SHORT_HASH="$VCS_NUM"

	# Current branch - can't be extracted since a checkout directory
	# may contain all branches or be a checkout of a single one.
	VCS_URI=""

	# Current tag (or uri if there is no tag). But "current tag" can't
	# be extracted reliably because Subversion doesn't have tags the way
	# other VCSes do.
	VCS_TAG=""

	# Date of the current commit
	VCS_DATE="$(svn info | sed -n -e 's/Last Changed Date: //p' | sed 's/ (.*)//' | sed -e 's/ /T/' | sed -e 's/ //')"
}


# Functions to output data in different formats.
# For header output
function hOutput {
	case $WC_MODIFIED in
	1) WC_MODIFIED='true' ;;
	0) WC_MODIFIED='false' ;;
	esac
	cat > "${TARGETFILE}" << EOF
/* ${VCS_FULL_HASH} */
#ifndef AUTOREVISION_H
#define AUTOREVISION_H

#define VCS_TYPE		"${VCS_TYPE}"
#define VCS_NUM			${VCS_NUM}
#define VCS_DATE		"${VCS_DATE}"
#define VCS_URI			"${VCS_URI}"
#define VCS_TAG			"${VCS_TAG}"

#define VCS_FULL_HASH		"${VCS_FULL_HASH}"
#define VCS_SHORT_HASH		"${VCS_SHORT_HASH}"

#define VCS_WC_MODIFIED		${WC_MODIFIED}

#endif

EOF
}

# A header output for use with xcode to populate info.plist strings
function xcodeOutput {
	cat > "${TARGETFILE}" << EOF
/* ${VCS_FULL_HASH} */
#ifndef AUTOREVISION_H
#define AUTOREVISION_H

#define VCS_TYPE		${VCS_TYPE}
#define VCS_NUM			${VCS_NUM}
#define VCS_DATE		${VCS_DATE}
#define VCS_URI			${VCS_URI}
#define VCS_TAG			${VCS_TAG}

#define VCS_FULL_HASH					${VCS_FULL_HASH}
#define VCS_SHORT_HASH					${VCS_SHORT_HASH}

#define VCS_WC_MODIFIED					${WC_MODIFIED}

#endif

EOF
}

# For bash output
function shOutput {
	cat > "${TARGETFILE}" << EOF
# ${VCS_FULL_HASH}
# AUTOREVISION_SH

VCS_TYPE="${VCS_TYPE}"
VCS_NUM="${VCS_NUM}"
VCS_DATE="${VCS_DATE}"
VCS_URI="${VCS_URI}"
VCS_TAG="${VCS_TAG}"

VCS_FULL_HASH="${VCS_FULL_HASH}"
VCS_SHORT_HASH="${VCS_SHORT_HASH}"

VCS_WC_MODIFIED="${WC_MODIFIED}"

EOF
}

# For Python output
function pyOutput {
	case $WC_MODIFIED in
	0) WC_MODIFIED=False ;;
	1) WC_MODIFIED=True ;;
	esac
	cat > "${TARGETFILE}" << EOF
# ${VCS_FULL_HASH}
# AUTOREVISION_SH

VCS_TYPE = "${VCS_TYPE}"
VCS_NUM = ${VCS_NUM}
VCS_DATE = "${VCS_DATE}"
VCS_URI = "${VCS_URI}"
VCS_TAG = "${VCS_TAG}"

VCS_FULL_HASH = "${VCS_FULL_HASH}"
VCS_SHORT_HASH = "${VCS_SHORT_HASH}"

VCS_WC_MODIFIED = ${WC_MODIFIED}

EOF
}

# For Perl output
function plOutput {
	cat << EOF
# ${VCS_FULL_HASH}
# AUTOREVISION_SH

\$VCS_TYPE = "${VCS_TYPE}";
\$VCS_NUM = ${VCS_NUM};
\$VCS_DATE = "${VCS_DATE}";
\$VCS_URI = "${VCS_URI}";
\$VCS_TAG = "${VCS_TAG}";

\$VCS_FULL_HASH = "${VCS_FULL_HASH}";
\$VCS_SHORT_HASH = "${VCS_SHORT_HASH}";

\$VCS_WC_MODIFIED = ${WC_MODIFIED};

EOF
}


# Detect and collect repo data.
if [[ -d .git ]] && [[ ! -z "$(git rev-parse HEAD 2>/dev/null)" ]]; then
	gitRepo
elif [[ -d .hg ]] && [[ ! -z "$(hg root 2>/dev/null)" ]]; then
	hgRepo
elif [[ -d .svn ]] && [[ ! -z "$(svn info 2>/dev/null)" ]]; then
	svnRepo
elif [[ -f "${CACHEFILE}" ]]; then
	# We are not in a repo; try to use a previously generated cache to populate our variables.
	source "${CACHEFILE}"
else
	echo "error: No repo or cache detected." 1>&2
	exit 1
fi


if [[ ! -z "${VAROUT}" ]]; then
	if [[ "${VAROUT}" = "VCS_NUM" ]]; then
		echo "${VCS_NUM}"
	elif [[ "${VAROUT}" = "VCS_DATE" ]]; then
		echo "${VCS_DATE}"
	elif [[ "${VAROUT}" = "VCS_URI" ]]; then
		echo "${VCS_URI}"
	elif [[ "${VAROUT}" = "VCS_TAG" ]]; then
		echo "${VCS_TAG}"
	elif [[ "${VAROUT}" = "VCS_FULL_HASH" ]]; then
		echo "${VCS_FULL_HASH}"
	elif [[ "${VAROUT}" = "VCS_SHORT_HASH" ]]; then
		echo "${VCS_SHORT_HASH}"
	elif [[ "${VAROUT}" = "VCS_WC_MODIFIED" ]]; then
		echo "${VCS_WC_MODIFIED}"
	fi
fi


# Detect requested output type and use it.
if [[ ! -z "${AFILETYPE}" ]]; then
	if [[ "${AFILETYPE}" = "h" ]]; then
		hOutput
	elif [ "${AFILETYPE}" = "xcode" ]; then
		xcodeOutput
	elif [ "${AFILETYPE}" = "sh" ]; then
		shOutput
	elif [ "${AFILETYPE}" = "py" ]; then
		pyOutput
	elif [ "${AFILETYPE}" = "pl" ]; then
		plOutput
	else
		echo "error: Not a valid output type." 1>&2
		exit 1
	fi
fi


# If requested, make a cache file.
if [[ ! -z "${CACHEFILE}" ]]; then
	TARGETFILE="${CACHEFILE}"
	shOutput
fi

#!/bin/bash

# start the release

if [[ $# -lt 3 ]]; then
  echo "usage: $(basename $0) previous-version new-version next-version" >&2
  exit 1
fi

previous_version=$1
version=$2
next_version=$3

echo ""
echo "Start release of $version, previous version is $previous_version"
echo ""
echo ""

lein do clean, test && \
git flow release start $version || exit 1

lein with-profile release set-version ${version} :previous-version ${previous_version} \
  || { echo "set version failed" >&2 ; exit 1; }

echo ""
echo ""
echo "Changes since $previous_version"
git log --pretty=changelog $previous_version..
echo ""
echo ""
echo "Now edit project.clj, ReleaseNotes and README"

$EDITOR project.clj
$EDITOR ReleaseNotes.md
$EDITOR README.md


echo -n "commiting project.clj, release notes and readme.  enter to continue:" \
&& read x \
&& git add project.clj ReleaseNotes.md README.md \
&& git commit -m "Updated project.clj, release notes and readme for $version" \
&& echo -n "Peform release.  enter to continue:" && read x \
&& lein test \
&& lein with-profile 1.3 test \
&& lein with-profile 1.4 test \
&& lein do install, deploy clojars \
&& git flow release finish $version \
&& lein with-profile release set-version ${next_version} \
&& git add project.clj \
&& git commit -m "Updated version for next release cycle"
#!/usr/bin/env bash
git config --local user.name "$( git show -s --format='%an' )"
git config --local user.email "$( git show -s --format='%ae' )"


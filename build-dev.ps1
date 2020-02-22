# Ensure all submodules are checked out with the latest master. (Useful for docs development.)
git submodule update --init --recursive
git submodule foreach git pull origin master --recurse-submodules

docfx
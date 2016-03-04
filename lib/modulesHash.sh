dn=$(dirname $0)
source $dn/constants.sh # sets delim
unameHash=$(uname -mprsv | shasum | cut -c 1-40)
pjHash=$(node -e "var pj=($(cat package.json)); console.log({dependencies: pj.dependencies, devDependencies: pj.devDependencies})" | shasum | cut -c 1-40)
echo "DEPS${pjHash}${delim}ARCH${unameHash}"

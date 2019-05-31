#!/bin/bash
# Go to api lib path
LIB_PATH=$PWD/Proto
cd "$LIB_PATH"
    
# Clone if needed
if [[ ! -d protobuf ]]; then
    git clone git@github.com:appodeal/protobuf.git
fi
        
# Pull master
cd "$LIB_PATH/protobuf"
git checkout -f master
git pull

# Update proto models
if [[ -z $(command -v protoc) ]]; then
    echo "You need to install protoc first! \n Look at https://medium.com/@erika_dike/installing-the-protobuf-compiler-on-a-mac-a0d397af46b8"
    exit 0
fi
            
search_results=$(find ./bidmachine -iname "*.proto")
protofiles=()
for search_result in ${search_results}; do
	protofiles+=( "${search_result#??}" )
done
echo "Generate files by models: ${protofiles[@]}"

protoc --proto_path="$LIB_PATH/protobuf" --objc_out="$LIB_PATH/BidMachineAPI" "${protofiles[@]}" 
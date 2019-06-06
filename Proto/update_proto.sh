#!/bin/bash
# Go to api lib path
LIB_PATH=$PWD/Proto
cd "$LIB_PATH"
    
# Clone if needed
if [[ ! -d protobuf ]]; then
    git clone git@github.com:appodeal/protobuf.git
    # Enable for ScalaPB compliance
    # cd "$LIB_PATH/protobuf"
    # git clone git@github.com:scalapb/ScalaPB.git
fi
        
# Enable for ScalaPB compliance
# cd "$LIB_PATH/protobuf/ScalaPB"
# git checkout -f master
# git pull

# Pull master
cd "$LIB_PATH/protobuf"
git checkout -f master
git pull

# Enable for ScalaPB compliance
# find "$LIB_PATH/protobuf/bidmachine" -type f -iname "*.proto" \
# 	 -exec sed -i '' 's/import \"scalapb\/scalapb\.proto\"\;/import \"ScalaPB\/protobuf\/scalapb\/scalapb\.proto\"\;/g' {} \;
        
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

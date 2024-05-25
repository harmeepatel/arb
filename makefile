cjson:
	jq -r tostring data.json > data.min.json

build:
	zig build-exe ./src/main.zig -target wasm32-freestanding \
	--export=createImage \
	--export=allocBytes \
	--export=freeBytes \
	-Doptimize=ReleaseSmall -Dstrip=true

run:
	clear
	zig build run

default:
	dune build

clean:
	dune clean

serve:
	cd bin/ && python3 -m http.server 8000

run:
	rm -f bin/main.bc.js
	dune build bin/main.bc.js
	cp _build/default/bin/main.bc.js bin/main.bc.js
	open http://localhost:8000

.PHONY: default clean serve run

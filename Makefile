default:
	dune build

clean:
	dune clean

serve:
	cd public/ && python3 -m http.server 8000

run:
	rm -f public/main.bc.js
	dune build bin/main.bc.js
	cp _build/default/bin/main.bc.js public/main.bc.js
	open http://localhost:8000

.PHONY: default clean serve run

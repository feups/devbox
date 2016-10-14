.PHONY: clean

doc: doc/devbox.html doc/devbox.pdf

doc/devbox.html: README.adoc
	nix-shell -p asciidoctor --command "asciidoctor $< -o $@"

doc/devbox.pdf: README.adoc
	nix-shell -p asciidoctor --command "asciidoctor-pdf $< -o $@"

clean:
	rm doc/devbox.*

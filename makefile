SOURCES = $(filter-out app.swift, $(wildcard *.swift)) $(wildcard */*.swift)

default: app.swift

app.swift: $(SOURCES)
	@python swiftinclude.py

run: app.swift
	@swift app.swift


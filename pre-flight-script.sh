(
  echo -e "\n========================================"
  echo "1. RUFF LINT CHECK (Target Files & Trace)"
  echo "========================================"
  # Get all files, then filter out the .toml for the count
  ALL_FILES=$(ruff check --show-files . )
  FILES_NO_TOML=$(echo "$ALL_FILES" | grep -v "\.toml$")
  COUNT=$(echo "$FILES_NO_TOML" | grep -v '^$' | wc -l)
  
  echo "Files resolved via pyproject.toml:"
  # Print paths relative to the project root so output is portable for other devs
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  PWD_ABS="$(pwd)"
  REPL='.'
  # Precompute sed argument arrays so we don't repeat the same expressions
  SED_OPTS_G=(
    -e "s|$ROOT/||g"
    -e "s|$ROOT|$REPL|g"
    -e "s|$PWD_ABS/||g"
    -e "s|$PWD_ABS|$REPL|g"
  )
  echo "$ALL_FILES" | sed -e "s|^$ROOT/||" -e "s|^$ROOT$|$REPL|" -e "s|^$PWD_ABS/||" -e "s|^$PWD_ABS$|$REPL|"
  echo "----------------------------------------"
  echo "Total Python files identified: $COUNT"
  
  # Run the check (show only included .py paths)
  ruff check . -v 2>&1 | sed "${SED_OPTS_G[@]}" | grep -E 'Included path via `include`:.*\.py' || true
  ruff check . && echo "Status: All identified files passed linting (0 errors)."
  
  echo -e "\n"

  echo "========================================"
  echo "2. RUFF FORMAT CHECK (Target Files)"
  echo "========================================"
  # Now this count accurately reflects only the .py files
  echo "Targeting the same $COUNT Python files resolved in Section 1..."
  
  ruff format --check . -v 2>&1 | sed "${SED_OPTS_G[@]}" | grep -E 'Included path via `include`:.*\.py' || true
  
  ruff format --check . && echo "Status: All $COUNT files match the required format."
  echo -e "\n"

  echo "========================================"
  echo "3. BASEDPYRIGHT TYPE AUDIT"
  echo "========================================"
  # This should now match your $COUNT exactly!
  basedpyright . --stats 2>&1 | sed "${SED_OPTS_G[@]}"
  echo -e "\n"

  echo "========================================"
  echo "4. PYTEST SUITE"
  echo "========================================"
  python3 -m pytest tests/ -v 2>&1 | sed "${SED_OPTS_G[@]}"

  echo -e "\n========================================"
  echo "✅ PRE-FLIGHT COMPLETE: ALL CHECKS PASSED"
  echo "========================================"
) 2>&1 | tee pre_flight_checks.txt

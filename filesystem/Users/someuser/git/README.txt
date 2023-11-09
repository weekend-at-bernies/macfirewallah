https://github.com/13alvone/py_browser_history

Run like this:

$ python3 py_browser_history.py | more
...

It dumps 100 records from most recent (top) to oldest (bottom)

If you are just interested in the URLs:

$ python3 py_browser_history.py | cut -d '|' -f 3 | sed 's/\[\.\]/\./g' | sed 's/\[\:\]/\:/g'
...

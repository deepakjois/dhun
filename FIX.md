## Fixes/Improvements required

* Refactor multiple calls to result.to_json -done

* Refactor handler calls by converting it from module to subclass of EventMachine::Connection object

* Put querying code in play and enqueue methods inside the player
  - put the querying code inside the runner as it used with query command with or without server. - done
  
* Clean up parser to avoid any SQL-injection style errors in args
  - locked down a bit better via thor options. -done
  
* store the socket information somehow so the runner remembers?

* have play jump to queue number

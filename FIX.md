## Fixes/Improvements required

* Refactor multiple calls to result.to_json
* Refactor handler calls by converting it from module to subclass of EventMachine::Connection object
* Put querying code in play and enqueue methods inside the player
* Clean up parser to avoid any SQL-injection style errors in args
## Lookup DB

Lookup DB is a friendly interface to the Dungeon Crawl Stone Soup LearnDB knowledge base.

### Installing
In order to work, Lookup DB requires (monster-trunk)[http://s-z.org/neil/git/?p=monster-trunk.git;a=summary] to be compiled and symlinked as monster-trunk in the base lookupdb directory.

Currently using monster-trunk branch origin/dcss015 and crawl tag 0.15.2


#### Steps
To setup monster-trunk:

1. Checkout (monster-trunk)[http://s-z.org/neil/git/?p=monster-trunk.git;a=summary] at branch origin/dcss015
2. Checkout crawl at tag 0.15.2
3. Symlink crawl into monster-trunk at crawl-ref (ln -s ../crawl crawl-ref)
4. Run make (I could only get this to work on Ubuntu, not mac)
5. Checkout lookupDB
6. Runk npm install
7. Symlink monster-trunk (ln -s ../monster-trunk/monster-stable monster-trunk)
8. Run gulp coffee (npm install -g gulp if you dont have it already)
9. node lib/index.js 

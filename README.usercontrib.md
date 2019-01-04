# XMPP Extensions Docset

This docset is maintained by Kevin Smith and Edwin Mons.  It was generated from
the public XMPP Standards Foundation [XEP repository].

How to generate the docset:
* Clone <https://github.com/Kev/xep-docset.git>
* Run `make`, this will checkout or update a local copy of the [XEP
  repository], generate HTML, build the database, and build the docset.

To prepare for a push to the user contribution repository, generate the docset
and then:
* Ensure the CONTRIBREPO variable at the top of Makefile points to your own
  clone of <https://github.com/Kapeli/Dash-User-Contributions.git>.
* Run `make contribcommit`
* Inspect the commit, update the commit message where needed
* Push the newly created commit and generate a pull request

[XEP repository]: https://github.com/xsf/xeps

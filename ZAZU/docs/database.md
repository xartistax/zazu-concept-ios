### Employer PoC Seed Jobs

Für den PoC existiert die serverseitige RPC:

`seed_employer_jobs_for_poc()`

Die Funktion:

- darf nur von authentifizierten Employer-Accounts ausgeführt werden
- ermittelt die Company über `company_memberships`
- setzt ein abgeschlossenes Employer-Onboarding voraus
- erstellt 10 realistische aktive Jobs für die eigene Company
- erstellt dazu passende Skill-Anforderungen über die gemeinsame `skills`-Taxonomie
- erstellt Sprachanforderungen über die gemeinsame `languages`-Taxonomie
- verwendet MUSS- und OPTIONAL-Anforderungen
- verwendet keine hardcodierte Company-ID
- verwendet für Taxonomie-Zuordnungen Namen statt fest eingebauter Taxonomie-UUIDs
- ist ein reines PoC-/Testwerkzeug und nicht Bestandteil des Production-Flows

Die Funktion ist absichtlich nicht idempotent:
Jeder Aufruf erzeugt 10 weitere Test-Jobs. Der Employer Full Reset kann die Jobs wieder entfernen.

Die früheren globalen Seed-Unternehmen und deren Jobs wurden entfernt.
Seed-Daten werden nun über den realen Employer-/Company-Kontext erzeugt.

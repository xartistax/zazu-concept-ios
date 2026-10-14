# ZAZU – Architektur

Stand: Oktober 2026  
Phase: PoC

## 1. Ziel

ZAZU wird als native iOS-App auf einer Codebasis entwickelt, die vom PoC über MVP bis Production weiterentwickelt werden kann.

Das fachliche Source of Truth ist:

`docs/ZAZU_Gesamtkonzept_Produktbriefing.pdf`

Der PoC reduziert den Funktionsumfang, verwendet aber keine bewusst wegwerfbare Architektur.

Der aktuelle PoC bildet den zentralen ZAZU-Produktfluss auf beiden Marktseiten ab:

`Profil → Matching → Swipe → Mutual Match → Interview`

## 2. Technologie

### iOS

- Swift
- SwiftUI
- Swift Concurrency / async-await
- Observation (`@Observable`)

### Backend

- Supabase
- PostgreSQL
- Supabase Auth
- Row Level Security (RLS)
- PostgreSQL RPCs für sicherheitskritische serverseitige Abläufe

### Externe Dependencies

- `supabase-swift`
- `SwipeCardsKit`

SwipeCardsKit wird ausschließlich für den Card-Stack verwendet. Persistenz, Matching und sonstige Business-Logik liegen nicht in der Library.

## 3. Architekturprinzip

Bevorzugter Datenfluss:

`Supabase → Repository/Service → Domain Model → ViewModel → SwiftUI`

SwiftUI Views enthalten keine fachlich relevanten Datenbankabfragen.

Repositories kapseln die Kommunikation mit Supabase.

Services enthalten wiederverwendbare Business-Logik, insbesondere Matching und PoC-spezifische Reset-Abläufe.

ViewModels koordinieren UI-State, Loading-, Error- und Persistenzabläufe.

Sicherheitskritische Operationen, die nicht allein über normale RLS-Policies sinnvoll abgebildet werden können, werden über gezielt abgesicherte PostgreSQL-RPCs ausgeführt.

## 4. App Flow und Rollen

ZAZU unterstützt im PoC zwei Account-Rollen:

- Candidate
- Employer

Die Rolle wird in `profiles.account_role` persistiert.

`AppState` hält den zentralen `RootState`.

Der Root Flow berücksichtigt Session, Rolle und jeweiligen Onboarding-Status.

### Candidate

1. Keine gültige Session → Authentication
2. Candidate + Onboarding unvollständig → Candidate Onboarding
3. Candidate + Onboarding vollständig → Candidate Main App

### Employer

1. Keine gültige Session → Authentication
2. Employer + Unternehmens-Onboarding unvollständig → Employer Onboarding
3. Employer + Unternehmens-Onboarding vollständig → Employer Main App

Supabase Auth persistiert die Session. Beim App-Start wird die vorhandene Session wiederhergestellt und der passende rollenbasierte Root State bestimmt.

## 5. Candidate Features

Der Candidate-PoC umfasst:

- Authentication
- Onboarding
- Discover
- Matches
- Interviews
- Profile

### Candidate Onboarding

Das Kandidaten-Onboarding umfasst:

1. Basisinformationen und Kontaktdaten
2. Berufserfahrung
3. Skills / Systemkenntnisse
4. Ausbildung / Qualifikationen
5. Sprachen
6. Jobpräferenzen
7. Arbeitsmodell / Homeoffice / Lohn
8. Zusammenfassung

Der Fortschritt wird persistent gespeichert.

Die Telefonnummer wird als private Kontaktinformation im Profil gespeichert. Sie ist nicht Bestandteil der anonymisierten Swipe-Daten.

Sponsoring ist aufgrund einer aktuellen Produktentscheidung kein Bestandteil des aktuellen ZAZU-Datenmodells. Arbeitsberechtigung bleibt davon getrennt bestehen.

## 6. Employer Features

Der Employer-PoC umfasst:

- rollenbasierten Login und Session Flow
- Unternehmens-Onboarding
- Unternehmensprofil anzeigen und bearbeiten
- Jobs erstellen und bearbeiten
- Jobs aktivieren und deaktivieren
- MUST- und OPTIONAL-Anforderungen definieren
- gemeinsame Skill- und Sprachtaxonomien verwenden
- passende Kandidaten pro Job ermitteln
- anonymisierte Kandidatenprofile anzeigen
- Kandidaten MATCHEN oder PASSEN
- Mutual Matches anzeigen
- Interviewtermine anbieten
- bestätigte Interviews anzeigen

Eine vollständige separate Arbeitgeber-App ist damit nicht mehr simuliert. Der zentrale Arbeitgeber-Flow ist Bestandteil derselben iOS-Codebasis.

## 7. Discover und Swipe

Discover bildet auf beiden Marktseiten den zentralen Matching-Flow ab.

### Candidate

- Swipe rechts → MATCH
- Swipe links → PASS
- Tap → Jobdetails
- kein klassischer Bewerbungsbutton

Kandidatenentscheidungen werden in `candidate_job_interactions` persistiert.

Bereits bewertete Jobs werden nicht erneut im Candidate-Discover-Stack angezeigt.

### Employer

Der Arbeitgeber wählt bzw. verwendet einen eigenen Job und erhält dazu passende Kandidaten.

- Swipe rechts → MATCH
- Swipe links → PASS
- Tap → anonymisiertes Kandidatenprofil

Arbeitgeberentscheidungen werden in `employer_job_interactions` persistiert.

Bereits bewertete Kandidaten werden für den jeweiligen Job nicht erneut angeboten.

## 8. Matching

Die fachliche Matching-Logik liegt im Service-/Domain-Layer und nicht in SwiftUI Views.

Das Matching berücksichtigt insbesondere:

- MUST-Kriterien
- OPTIONAL-Kriterien
- Lohnkompatibilität
- Standort / Radius
- Pendel- und Umzugsbereitschaft
- Arbeitsmodell
- Homeoffice
- Berufserfahrung
- Skills und Skill-Level
- Sprachen und Sprachlevel
- Ausbildung
- Arbeitsberechtigung

MUST-Kriterien werden separat von der prozentualen Bewertung behandelt.

Der aktuelle PoC-Score lautet:

`erfüllte bewertete Kriterien / alle bewerteten Kriterien`

Der Score ersetzt nicht die Prüfung der MUST-Kriterien.

Skills und Sprachen verwenden gemeinsame Taxonomien für Kandidaten und Jobs.

Das Matching wird auf Candidate- und Employer-Seite transparent dargestellt. Arbeitgeber-Reverse-Matching verwendet dieselben fachlichen Matching-Regeln wie das Candidate-Matching.

## 9. Mutual Match

Kandidat und Arbeitgeber treffen unabhängige persistierte Entscheidungen.

Ein Mutual Match entsteht ausschließlich bei:

`Candidate MATCH + Employer MATCH`

Die Reihenfolge der beiden Entscheidungen ist dabei unerheblich.

Die serverseitige Mutual-Match-Erzeugung ist so gekapselt, dass Clients Matches nicht beliebig selbst erzeugen können.

Nach erfolgreichem Mutual Match kann auf beiden Seiten die Meldung

`IT'S A JOB MATCH!`

angezeigt werden.

Danach beginnt die Interviewphase.

## 10. Interview

Nach einem Mutual Match kann der Arbeitgeber mehrere Interviewtermine anbieten.

Der Kandidat kann einen angebotenen Slot auswählen.

Nach der Auswahl wird das Interview verbindlich bestätigt und auf beiden Seiten angezeigt.

Der aktuelle PoC behandelt ein bestätigtes Interview als gesperrt. Rescheduling und Cancellation gehören nicht zum aktuellen PoC.

Der Fall „Keiner der vorgeschlagenen Termine passt“ ist ebenfalls nicht Bestandteil des aktuellen PoC.

Kalender- und Video-Meeting-Integrationen sind für spätere Phasen vorgesehen.

## 11. Datenschutz und Security

Private Kandidatendaten werden nicht ausschließlich durch UI-Logik geschützt.

RLS und abgesicherte PostgreSQL-RPCs schützen rollen- und benutzerspezifische Daten.

Während Candidate Discover und Employer Discover gilt eine anonymisierte Swipe-Phase.

Der Arbeitgeber erhält für Reverse Matching und Swipe nur die für Matching und berufliche Beurteilung notwendigen Kandidatendaten.

Nicht Bestandteil des anonymisierten Arbeitgeber-Swipe-Profils sind insbesondere:

- Name
- Telefonnummer
- E-Mail
- vollständige private Adresse
- Profilfoto
- Alter / Geburtsdatum
- Geschlecht

Ein Mutual Match allein hebt diese Anonymisierung im aktuellen PoC noch nicht auf.

Nach verbindlicher Interviewbestätigung kann der berechtigte Arbeitgeber über eine serverseitig geschützte RPC den Namen und die Telefonnummer des gematchten Kandidaten erhalten.

Ein Profilfoto ist im aktuellen PoC noch nicht implementiert.

Praktisch getestete Zugriffsgrenzen umfassen unter anderem:

- Candidate kann fremde Profile nicht lesen.
- Candidate kann fremde Profile nicht verändern.
- Candidate kann interne Arbeitgeberentscheidungen nicht lesen.
- Employer kann Jobs fremder Unternehmen nicht verändern.
- Employer kann private Kandidatenprofildaten nicht direkt lesen.
- Employer kann keine Entscheidung für einen fremden Job speichern.
- Employer kann Kontaktdaten eines nicht berechtigten Matches nicht abrufen.

## 12. Unternehmens- und Jobdaten

Unternehmen werden über `companies` modelliert.

Die Zuordnung eines Employer-Accounts zu einem Unternehmen erfolgt über `company_memberships`.

Jobs gehören zu einem Unternehmen.

Jobanforderungen werden relational gespeichert und verwenden gemeinsame Taxonomien für Skills und Sprachen.

Der aktuelle PoC unterstützt unter anderem:

- Unternehmensprofil
- Kontaktperson
- Jobtitel und Beschreibung
- Standort
- Arbeitsmodell
- Arbeitspensum
- Eintritt
- Lohnband
- Berufserfahrung
- Arbeitsberechtigung
- Homeoffice
- Skills
- Sprachen
- Ausbildung
- MUST-/OPTIONAL-Klassifikation

## 13. PoC Tools

Die App enthält temporäre Entwicklungswerkzeuge für reproduzierbare PoC- und E2E-Tests.

Candidate Tools unterstützen insbesondere:

- Wechsel zum Employer-Testaccount
- RLS-/Security-Checks
- Reset von Candidate-Swipes und Matches
- vollständigen Candidate-Testreset

Employer Tools unterstützen insbesondere:

- Wechsel zum Candidate-Testaccount
- RLS-/Security-Checks
- Reset von Employer-Swipes
- vollständigen Employer-Testreset

Der Employer Full Reset behält Auth-Account, Firmenname und Firmenzugehörigkeit bei, kann aber eigene Jobs und davon abhängige Testdaten entfernen und das Unternehmens-Onboarding zurücksetzen.

Diese Tools und die PoC-Testcredentials sind keine Production-Funktionen und müssen vor Production entfernt werden.

Alte simulierte Mutual-Match- und Reverse-Matching-Testpfade wurden entfernt.

## 14. Testing

Automatisierte Tests decken insbesondere die Matching-Logik ab:

- MUST / OPTIONAL
- Skills und Skill-Level
- Sprachen und Sprachlevel
- Lohnüberschneidung
- Arbeitsmodell / Homeoffice
- Standort
- Berufserfahrung
- Ausbildung
- Employer Reverse Matching
- Mutual-Match-relevante Business-Logik
- Onboarding-State

Zusätzlich wurde der zentrale Produktfluss mit zwei echten Supabase-Testaccounts und auf einem realen iPhone getestet:

`Employer Job → Candidate MATCH → Employer MATCH → Mutual Match → Interview-Slots → Candidate Terminauswahl → bestätigtes Interview`

Dabei wurde auch die Privacy-Grenze geprüft:

- Mutual Match ohne bestätigtes Interview bleibt anonym.
- Nach bestätigtem Interview werden Name und Telefonnummer für den berechtigten Arbeitgeber freigegeben.

Weitere praktisch getestete Flows:

- Login / Logout
- persistente Session
- Candidate Onboarding
- Employer Onboarding
- Candidate Profilpersistenz und Bearbeitung
- Employer Unternehmensprofil und Bearbeitung
- Job erstellen / bearbeiten / aktivieren
- Candidate Swipe MATCH / PASS
- Employer Swipe MATCH / PASS
- Mutual Match in beiden Entscheidungsreihenfolgen
- Interviewauswahl und Persistenz
- RLS-Negativtests

## 15. Bewusste PoC-Grenzen

Nicht Bestandteil des aktuellen PoC sind insbesondere:

- Payments und Monetarisierung
- Admin Dashboard
- echte Dokumentverifizierung
- vollständige Dokument-Workflows
- vollständige Push Notifications
- komplexe Analytics
- produktionsreife Matching Engine
- Kalenderintegration
- Video-Meeting-Integration
- Interview Rescheduling / Cancellation
- vollständige Arbeitgeberverifizierung
- Profilfoto-Upload und Freischaltung
- Production-taugliche Test-/Reset-Werkzeuge

Bekannte PoC-Vereinfachungen dürfen für MVP und Production weiterentwickelt werden, ohne den grundlegenden Datenfluss neu aufzubauen.

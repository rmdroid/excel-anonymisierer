# KI-Anonymisierer Excel

Excel-Datei rein, anonymisierte Excel-Datei raus – vollständig auf Ihrer
eigenen Hardware. Keine Cloud, kein Upload, kein Drittanbieter.

Gehört zum [KI-Anonymisierer](https://ki-anonymisierer.de).

## Einrichten

```bash
curl -fsSL https://raw.githubusercontent.com/rmdroid/excel-anonymisierer/main/install.sh | bash
```

Das Skript prüft die Voraussetzungen, fragt nach dem Lizenzschlüssel, lädt das
Abbild und startet die Anwendung. Danach liegt die Oberfläche unter
**http://localhost:9999**.

Wer das Skript vorher lesen will – empfehlenswert bei allem, was per `curl`
ausgeführt wird:

```bash
git clone https://github.com/rmdroid/excel-anonymisierer
cd excel-anonymisierer
less install.sh
./install.sh
```

Voraussetzung ist Docker. Unter Windows und macOS genügt
[Docker Desktop](https://docs.docker.com/get-docker/) mit 4 GB Arbeitsspeicher.

## Freischaltung

Ohne Lizenzschlüssel ist nichts freigeschaltet.

| | Laufzeit | |
|---|---|---|
| **Testzugang** | 7 Tage | voller Funktionsumfang, kostenlos |
| **Dauerlizenz** | unbefristet | 99 € einmalig je Arbeitsplatz, ausgestellt auf Ihre Organisation; Einstellungen aus dem Test bleiben erhalten |

Anfrage und Bestellung: [BESTELLUNG.md](BESTELLUNG.md). Der Schlüssel wird
lokal geprüft – keine Onlineaktivierung, keine Übertragung.

## So funktioniert es

1. **Datei hineinziehen.** Sie bleibt auf diesem Rechner.
2. **Erkennen.** Jede Spalte bekommt ein Etikett: Name, Adresse, IBAN,
   Geburtsdatum, Steuer-ID, Religion (Art. 9 DSGVO), Freitext. IBAN und
   Steuer-ID werden über die Prüfziffer erkannt.
3. **Entscheiden.** Pro Spalte eine Methode: Pseudonym, Vergröbern,
   Schwärzen, Ersatzdaten oder Behalten. Nur echte Zweifelsfälle werden
   abgefragt. Links Original, rechts Ergebnis – im direkten Vergleich.
4. **Speichern.** Neue Datei, dazu auf Wunsch ein Protokoll als PDF und eine
   verschlüsselte Schlüsseldatei zum Zurückübersetzen.

Das Original wird nie verändert. Formatierung, Formeln und Tabellenblätter
bleiben erhalten.

### Freitext

Die Spalte „Bemerkung“ wird Stelle für Stelle geprüft – mit Regeln, einem
lokalen Sprachmodell für unbekannte Namen und den Namen aus der Tabelle
selbst:

```
Rücksprache mit Hr. Brand wg. Nachtschicht   →  Rücksprache mit Hr. Nachname 13 wg. Nachtschicht
Reha nach Bandscheiben-OP bis 30.09.         →  [Gesundheitsangabe]
Vertretung für Paula ab KW 42                →  Vertretung für Vorname 03 ab KW 42
```

### Wiedererkennbarkeit

Namen entfernen reicht nicht, wenn nur eine Person die Filiale leitet und 1968
geboren ist. Die Anwendung prüft, wie oft jede Kombination aus Geburtsjahr,
PLZ, Ort und Tätigkeit vorkommt, und schlägt vor, was hilft.

### Was außerhalb der Zellen steckt

Ausgeblendete Tabellenblätter werden mit anonymisiert. Kommentare, Kopf- und
Fußzeilen, Pivot-Zwischenspeicher und Autorangaben werden entfernt. Auch der
Dateiname wird geprüft.

### Zurückübersetzen

Die KI antwortet mit Pseudonymen. Mit Schlüsseldatei und Passwort setzt die
Anwendung die echten Namen wieder ein – auf diesem Rechner, für eingefügten
Text und ganze Dateien.

## Wie die Daten laufen

```
Excel-Datei ──► Anwendung auf diesem Rechner ──► anonymisierte Datei
                  (Regeln + Sprachmodell)              │
                                                       ▼
                                                   Ihre KI
```

- Die Verarbeitung läuft vollständig lokal. Das Sprachmodell ist im Abbild
  enthalten; der Container arbeitet auch ohne jede Netzwerkverbindung.
- Hochgeladene Dateien liegen nur im Arbeitsspeicher und sind nach dem
  Schließen vergessen.
- Protokolliert werden Zeilen- und Zellenzahlen, nie Inhalte.
- Der Port ist an `127.0.0.1` gebunden.

## Betrieb

```bash
cd ~/ki-anonymisierer-excel

docker compose logs -f                          # Protokoll
docker compose down                             # beenden
docker compose up -d                            # starten
docker compose pull && docker compose up -d     # aktualisieren
```

Lizenz und Profile liegen in einem Docker-Volume und überleben
Aktualisierungen.

### Grenzen

- Unterstützt werden `.xlsx` und `.xlsm`. CSV-Dateien und alte `.xls`-Dateien
  vorher in Excel als `.xlsx` speichern.
- Diagramme und Bilder werden nicht in die anonymisierte Datei übernommen.
  Die Oberfläche weist vor dem Speichern darauf hin.
- Die Erkennung ist gründlich, aber kein Ersatz für einen prüfenden Blick auf
  die Spaltenetiketten.

### Häufige Fehler

**Port belegt** – mit `PORT=9998 ./install.sh` einen anderen wählen.

**Container startet nicht oder bricht ab** – Docker mehr Arbeitsspeicher
zuteilen (Docker Desktop → Settings → Resources, mindestens 4 GB).

## Lizenz

Nutzung nach [EULA.md](EULA.md). Bestandteile Dritter, darunter das
Sprachmodell `urchade/gliner_multi_pii-v1` (Apache 2.0):
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).

## Unterstützung

Testzugang, Sicherheitsfragebögen, Fragen: **rm@kostenmanager.net**

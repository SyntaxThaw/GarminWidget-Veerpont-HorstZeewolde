# Veerdienst Instinct 2 Widget

Eenvoudige Garmin Connect IQ **widget** voor de Garmin Instinct 2.

Toont:
- volgende rit
- minuten tot vertrek
- rit daarna
- laatste rit vandaag
- winterstop in weekend
- zomer/regulier rooster

## Batterij- en performance-optimalisatie

- Geen continue achtergrondtaken; widget rendert alleen wanneer geopend/ververst.
- Ritdata wordt per minuut gecachet (`_cachedMinuteKey`) om herberekeningen te minimaliseren.
- Geen netwerk, sensoren of GPS gebruikt.
- Eenvoudige zwart/wit rendering met beperkte text-draw calls.

## Bestandsstructuur

- manifest.xml
- monkey.jungle
- source/VeerdienstApp.mc
- source/VeerdienstWidget.mc
- resources/strings/strings.xml
- resources/drawables/launcher_icon.png
- .github/workflows/garmin-widget-ci.yml

## Lokaal bouwen in Connect IQ SDK

1. Installeer Garmin Connect IQ SDK en Monkey C extension.
2. Bouw lokaal:
   - `monkeyc -f monkey.jungle -o bin/VeerdienstWidget.prg -y <pad-naar-developer_key.der>`

## GitHub workflow (build + optionele publish handoff)

Workflowbestand: `.github/workflows/garmin-widget-ci.yml`

Benodigde secrets:
- `CONNECTIQ_SDK_URL`: download-URL van jouw Connect IQ SDK zip
- `CIQ_DEV_KEY`: inhoud van je developer key (`.der`)

Wat de workflow doet:
1. Checkout + Java setup.
2. SDK downloaden.
3. Widget compileren naar `bin/VeerdienstWidget.prg`.
4. Artifact uploaden.
5. Bij `workflow_dispatch` met `publish=true`: geeft publish-handoff stap voor handmatige store upload.

> Let op: volledig automatisch publiceren naar de Connect IQ Store is vaak account/tooling-afhankelijk. Daarom is de workflow standaard veilig opgezet als build + artifact + handoff.

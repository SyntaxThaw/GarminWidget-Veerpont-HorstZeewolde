# Veerdienst Instinct 2

Eenvoudige Garmin Connect IQ watch face voor de Garmin Instinct 2.

Toont:
- volgende rit
- minuten tot vertrek
- rit daarna
- laatste rit vandaag
- winterstop in weekend
- zomer/regulier rooster

## Bestandsstructuur

- manifest.xml
- monkey.jungle
- source/VeerdienstApp.mc
- source/VeerdienstWatchFace.mc
- resources/strings/strings.xml
- resources/drawables/launcher_icon.png

## Bouwen in Connect IQ SDK

Open dit project in VS Code met de Monkey C extensie of bouw via de Garmin SDK tools.

Belangrijk:
- Product staat nu op `instinct2`
- Minimum API level staat op `3.4.0`

## Makkelijke uitbreidingen

- zomervakantie-datums via settings instelbaar maken
- ook ondersteuning voor Instinct 2S en 2X toevoegen
- eigen layout voor low power of MIP optimaliseren

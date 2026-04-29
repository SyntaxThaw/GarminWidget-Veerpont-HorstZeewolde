using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;

class VeerdienstWatchFace extends Ui.WatchFace {

    const START_ZOMERVAKANTIE = 20260711;
    const EIND_ZOMERVAKANTIE  = 20260823;

    const ROOSTERS = {
        :regulier => {
            :werkdag => {
                :zeewolde => ["06:30", "07:00", "07:20", "07:45", "08:20", "09:00", "10:00", "10:40", "11:20", "12:30", "13:10", "13:50", "14:30", "15:10", "15:55", "16:30", "17:10", "18:00"],
                :horst    => ["06:45", "07:10", "07:30", "08:00", "08:40", "09:20", "10:20", "11:00", "11:40", "12:50", "13:30", "14:10", "14:50", "15:40", "16:10", "16:50", "17:30", "18:10"]
            },
            :zaterdag => {
                :zeewolde => ["08:20", "09:00", "10:00", "10:40", "11:20", "12:30", "13:10", "13:50", "14:30", "15:10", "15:50", "16:30", "17:10", "18:00"],
                :horst    => ["08:40", "09:20", "10:20", "11:00", "11:40", "12:50", "13:30", "14:10", "14:50", "15:30", "16:10", "16:50", "17:30", "18:10"]
            },
            :zondag => {
                :zeewolde => ["10:00", "10:40", "11:20", "12:30", "13:10", "13:50", "14:30", "15:10", "15:50", "16:30", "17:10", "18:00"],
                :horst    => ["10:20", "11:00", "11:40", "12:50", "13:30", "14:10", "14:50", "15:30", "16:10", "16:50", "17:30", "18:10"]
            }
        },

        :zomer => {
            :werkdag => {
                :zeewolde => ["06:30", "07:00", "07:20", "07:45", "08:20", "09:00", "10:00", "10:50", "11:40", "13:00", "13:50", "14:40", "15:30", "16:30", "17:10", "18:00"],
                :horst    => ["06:45", "07:10", "07:30", "08:00", "08:40", "09:20", "10:25", "11:15", "12:05", "13:25", "14:15", "15:05", "15:55", "16:50", "17:30", "18:10"]
            },
            :zaterdag => {
                :zeewolde => ["08:20", "09:00", "10:00", "10:50", "11:40", "13:00", "13:50", "14:40", "15:30", "16:30", "17:10", "18:00"],
                :horst    => ["08:40", "09:20", "10:25", "11:15", "12:05", "13:25", "14:15", "15:05", "15:55", "16:50", "17:30", "18:10"]
            },
            :zondag => {
                :zeewolde => ["10:00", "10:50", "11:40", "13:00", "13:50", "14:40", "15:30", "16:30", "17:10", "18:00"],
                :horst    => ["10:25", "11:15", "12:05", "13:25", "14:15", "15:05", "15:55", "16:50", "17:30", "18:10"]
            }
        }
    };

    function initialize() {
        Ui.WatchFace.initialize();
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var w = dc.getWidth();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        var data = berekenData();

        dc.drawText(w / 2, 10, Gfx.FONT_XTINY, "PONT", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2, 26, Gfx.FONT_XTINY, data[:isZomerrooster] ? "ZOMER" : "REG", Gfx.TEXT_JUSTIFY_CENTER);

        if (data[:geenVaartVandaag]) {
            dc.drawText(w / 2, 70, Gfx.FONT_SMALL, "GEEN VAART", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, 90, Gfx.FONT_XTINY, "winter weekend", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (data[:volgende] == null) {
            dc.drawText(w / 2, 70, Gfx.FONT_SMALL, "KLAAR", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, 90, Gfx.FONT_XTINY, "vandaag geen pont meer", Gfx.TEXT_JUSTIFY_CENTER);

            if (data[:laatste] != null) {
                dc.drawText(w / 2, 126, Gfx.FONT_TINY,
                    "laatste " + data[:laatste][:tijd] + " " + data[:laatste][:richting],
                    Gfx.TEXT_JUSTIFY_CENTER);
            }
            return;
        }

        var volgende = data[:volgende];
        var daarna   = data[:daarna];
        var laatste  = data[:laatste];
        var overMin  = volgende[:min] - data[:minutenNu];

        dc.drawText(w / 2, 56, Gfx.FONT_LARGE, volgende[:tijd], Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2, 88, Gfx.FONT_SMALL, volgende[:richting], Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2, 108, Gfx.FONT_TINY, "over " + overMin.toString() + " min", Gfx.TEXT_JUSTIFY_CENTER);

        if (daarna != null) {
            dc.drawText(w / 2, 136, Gfx.FONT_TINY,
                "daarna " + daarna[:tijd] + " " + daarna[:richting],
                Gfx.TEXT_JUSTIFY_CENTER);
        }

        if (laatste != null) {
            dc.drawText(w / 2, 156, Gfx.FONT_XTINY,
                "laatste " + laatste[:tijd],
                Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    function berekenData() {
        var nowInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var clock   = Sys.getClockTime();

        var dagVanDeWeek = nowInfo.day_of_week; // 1=zon ... 7=zat
        var maand        = nowInfo.month;       // 1..12
        var minutenNu    = (clock.hour * 60) + clock.min;
        var datumKey     = (nowInfo.year * 10000) + (nowInfo.month * 100) + nowInfo.day;

        var isZomerrooster = (datumKey >= START_ZOMERVAKANTIE && datumKey <= EIND_ZOMERVAKANTIE);

        var dagType = :werkdag;
        if (dagVanDeWeek == 7) {
            dagType = :zaterdag;
        } else if (dagVanDeWeek == 1) {
            dagType = :zondag;
        }

        var isWinter = (maand >= 11 || maand <= 2);
        var geenVaartVandaag = isWinter && (dagVanDeWeek == 1 || dagVanDeWeek == 7);

        var result = {
            :isZomerrooster   => isZomerrooster,
            :geenVaartVandaag => geenVaartVandaag,
            :minutenNu        => minutenNu,
            :volgende         => null,
            :daarna           => null,
            :laatste          => null
        };

        if (geenVaartVandaag) {
            return result;
        }

        var roosterType = isZomerrooster ? ROOSTERS[:zomer] : ROOSTERS[:regulier];
        var tijdenZeewolde = roosterType[dagType][:zeewolde];
        var tijdenHorst    = roosterType[dagType][:horst];

        for (var i = 0; i < tijdenZeewolde.size(); i++) {
            verwerkRit(result, tijdenZeewolde[i], "Z->H", minutenNu);
        }

        for (var j = 0; j < tijdenHorst.size(); j++) {
            verwerkRit(result, tijdenHorst[j], "H->Z", minutenNu);
        }

        return result;
    }

    function verwerkRit(result, tijd, richting, minutenNu) {
        var ritMin = tijdNaarMinuten(tijd);
        var rit = {
            :tijd     => tijd,
            :richting => richting,
            :min      => ritMin
        };

        if (result[:laatste] == null || ritMin > result[:laatste][:min]) {
            result[:laatste] = rit;
        }

        if (ritMin < minutenNu) {
            return;
        }

        if (result[:volgende] == null || ritMin < result[:volgende][:min]) {
            result[:daarna] = result[:volgende];
            result[:volgende] = rit;
        } else if (result[:daarna] == null || ritMin < result[:daarna][:min]) {
            result[:daarna] = rit;
        }
    }

    function tijdNaarMinuten(tijdStr as String) as Number {
        var uur = tijdStr.substring(0, 2).toNumber();
        var min = tijdStr.substring(3, 5).toNumber();
        return (uur * 60) + min;
    }
}

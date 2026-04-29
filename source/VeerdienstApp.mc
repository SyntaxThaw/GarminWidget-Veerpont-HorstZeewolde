using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class VeerdienstApp extends App.AppBase {

    function initialize() {
        App.AppBase.initialize();
    }

    function getInitialView() {
        return [ new VeerdienstWatchFace() ];
    }
}

function getApp() as VeerdienstApp {
    return App.getApp() as VeerdienstApp;
}

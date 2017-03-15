pragma Singleton

import QtQuick 2.0


/*!
   \qmltype Matrix
   \inqmlmodule XjUi

   \brief Provides access to standard math function.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */

QtObject {
    id: matrix


    function log(says) {
        console.log("## Matrix.qml ##: \n" + says)
    }

    Component.onCompleted: {
        log("Component.onCompleted")
    }
}

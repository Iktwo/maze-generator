import QtQuick 2.0

Item {
    id: root

    property var inMaze: []
    property var inFrontier: []

    property int rows: 15
    property int columns: 15

    signal openPathOnIndex(int indexToOpen, string direction)

    function addToMaze(value) {
        if (inMaze.indexOf(value) == -1) {
            var array = inMaze
            array.push(value)
            inMaze = array
        }

        // Pop it from frontier
        if (inFrontier.indexOf(value) != -1) {
            var array = inFrontier
            array.splice(array.indexOf(value), 1)
            inFrontier = array
        }

        var neighborgsThatAreInMaze = []

        if (value - root.columns >= 0) {
            addToFrontier(value - root.columns)

            if (inMaze.indexOf(value - root.columns) != -1)
                neighborgsThatAreInMaze.push(value - root.columns)
        }

        if (value % root.columns < root.columns - 1) {
            addToFrontier(value + 1)

            if (inMaze.indexOf(value + 1) != -1)
                neighborgsThatAreInMaze.push(value + 1)
        }

        if (value + root.columns < root.columns * root.rows) {
            addToFrontier(value + root.columns)

            if (inMaze.indexOf(value + root.columns) != -1)
                neighborgsThatAreInMaze.push(value + root.columns)
        }

        if (value % root.columns > 0) {
            addToFrontier(value - 1)

            if (inMaze.indexOf(value - 1) != -1)
                neighborgsThatAreInMaze.push(value - 1)
        }

        var openingPathTo = -1

        if (neighborgsThatAreInMaze.length == 1) {
            // Open path to this neighborg
            openingPathTo = neighborgsThatAreInMaze[0]
        } else if (neighborgsThatAreInMaze.length > 0){
            /// Choose in neighborg
            openingPathTo = neighborgsThatAreInMaze[Math.floor(Math.random() * neighborgsThatAreInMaze.length)]
        }

        if (openingPathTo != -1) {
            if (value === openingPathTo + 1) {
                openPathOnIndex(value, "left")
                openPathOnIndex(openingPathTo, "right")
            } else if (value === openingPathTo - 1) {
                openPathOnIndex(value, "right")
                openPathOnIndex(openingPathTo, "left")
            } else if (value > openingPathTo) {
                openPathOnIndex(value, "up")
                openPathOnIndex(openingPathTo, "down")
            } else if (value < openingPathTo) {
                openPathOnIndex(value, "down")
                openPathOnIndex(openingPathTo, "up")
            }
        }
    }

    function addToFrontier(value) {
        // If not in frontier already & not in maze already
        if (inFrontier.indexOf(value) == -1 && inMaze.indexOf(value) == -1) {
            var array = inFrontier
            array.push(value)
            inFrontier = array
        }
    }

    width: 640
    height: 640

    GridView {
        id: view

        anchors {
            fill: parent
            margins: 20
        }

        model: root.columns * root.rows
        cellHeight: height / rows
        cellWidth: width / columns
        interactive: false

        Keys.onLeftPressed: moveCurrentIndexLeft()
        Keys.onRightPressed: moveCurrentIndexRight()
        Keys.onUpPressed: moveCurrentIndexUp()
        Keys.onDownPressed: moveCurrentIndexDown()

        Keys.onReturnPressed:  {
            currentItem.active = !currentItem.active
        }

        Keys.onEnterPressed: {
            currentItem.active = !currentItem.active
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_W) {
                currentItem.upwall = !currentItem.upwall
                event.accepted = true;
            } else if (event.key === Qt.Key_S) {
                currentItem.downwall = !currentItem.downwall
                event.accepted = true;
            } else if (event.key === Qt.Key_A) {
                currentItem.leftwall = !currentItem.leftwall
                event.accepted = true;
            } else if (event.key === Qt.Key_D) {
                currentItem.rightwall = !currentItem.rightwall
                event.accepted = true;
            }
        }

        focus: true

        delegate: Rectangle {
            id: delegate

            property bool active: false
            property bool upwall: true
            property bool downwall: true
            property bool leftwall: true
            property bool rightwall: true

            height: GridView.view.cellHeight
            width: GridView.view.cellWidth

            color: inFrontier.indexOf(index) != -1 ? "#2ecc71" : (inMaze.indexOf(index) != -1 ? "#ecf0f1" : (active ? "#ecf0f1" : "#bdc3c7"))

            /// TODO: find a way to not do this, this makes the whole thing ultra slow
            Connections {
                target: root
                onOpenPathOnIndex: {
                    if (index == indexToOpen) {

                        if (direction == "up")
                            delegate.upwall = false
                        else if (direction == "down")
                            delegate.downwall = false
                        else if (direction == "left")
                            delegate.leftwall = false
                        else if (direction == "right")
                            delegate.rightwall = false
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                height: 1
                width: parent.width
                color: "black"

                visible: upwall
            }

            Rectangle {
                anchors.bottom: parent.bottom
                height: 1
                width: parent.width
                color: "black"

                visible: downwall
            }

            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: 1
                color: "black"

                visible: leftwall
            }

            Rectangle {
                anchors.right: parent.right
                height: parent.height
                width: 1
                color: "black"

                visible: rightwall
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    active = !active
                    addToMaze(index)
                }
            }
        }
    }

    Timer {
        running: inFrontier.length > 0
        repeat: true
        interval: 16
        onTriggered: {
            var cell = Math.floor(Math.random() * inFrontier.length)
            addToMaze(inFrontier[cell])
        }
    }
}

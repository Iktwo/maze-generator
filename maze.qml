import QtQuick 2.0

Rectangle {
    id: root

    property int lineSize: 2

    property var inMaze: []
    property var inFrontier: []

    property int rows: 10
    property int columns: 10

    readonly property int count: rows * columns
    readonly property int mazesToGenerate: 100

    property bool generated: false

    property int cellHeight: Math.round((height - (viewMargins * 2))/ rows)
    property int cellWidth: Math.round((width - (viewMargins * 2))/ columns)

    property int viewMargins: 15

    signal openPathOnIndex(int indexToOpen, string direction)

    property double mazeId: 0

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

    function resetMaze() {
        if (mazeId % 10 == 0) {
            rows = rows + 1
            columns = columns + 1
        }

        inMaze = []
        inFrontier = []
        generated = false
        root.forceActiveFocus()
        view.model = undefined
        view.model = columns * rows
        mazeId = mazeId + 1

        generateStartingMaze()
    }

    function generateStartingMaze() {
        if (!root.generated) {
            root.generated = true

            addToMaze(Math.floor(Math.random() * root.count))
        }
    }

    width: 595
    height: 595

    color: "#ffffff"

    focus: true

    Keys.onPressed: {
        if (event.key === Qt.Key_R) {
            resetMaze();
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 5
        }

        text: mazeId
    }

    FocusScope {
        anchors.centerIn: parent

        height: childrenRect.height
        width: childrenRect.width

        focus: true

        Keys.onPressed: {
            if (event.key === Qt.Key_R) {
                resetMaze();
            }
        }

        Repeater {
            id: view

            model: root.columns * root.rows

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
                property int calculatedRow: index / columns
                property int calculatedColumn: index % columns

                function handleKey(key) {
                    switch(key) {
                    case Qt.Key_Up:
                        if (calculatedRow === 0) {
                            upwall = !upwall
                        }
                        break;
                    case Qt.Key_Down:
                        if (calculatedRow === rows - 1) {
                            downwall = !downwall
                        }
                        break;
                    case Qt.Key_Left:
                        if (calculatedColumn === 0) {
                            leftwall = !leftwall
                        }
                        break;
                    case Qt.Key_Right:
                        if (calculatedColumn === columns - 1) {
                            rightwall = !rightwall
                        }
                        break;

                    }
                }

                height: root.cellHeight
                width: root.cellWidth

                y: calculatedRow * root.cellWidth + (calculatedRow * (lineSize * -1))
                x: calculatedColumn * root.cellHeight + (calculatedColumn * (lineSize * -1))

                color: activeFocus ? "#223498db" : "transparent"

                focus: true

                Keys.onPressed: {
                    switch(event.key) {
                    case Qt.Key_Up:
                    case Qt.Key_Down:
                    case Qt.Key_Left:
                    case Qt.Key_Right:
                        handleKey(event.key)
                        break;

                    }

                    if (event.key === Qt.Key_R) {
                        resetMaze();
                    }

                    event.accepted = true;
                }

                // color: inFrontier.indexOf(index) != -1 ? "#2ecc71" : (inMaze.indexOf(index) != -1 ? "#ecf0f1" : (active ? "#ecf0f1" : "#bdc3c7"))

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

                    height: lineSize
                    width: parent.width
                    color: "#000000"

                    visible: upwall
                }

                Rectangle {
                    anchors.bottom: parent.bottom

                    height: lineSize
                    width: parent.width
                    color: "#000000"

                    visible: downwall
                }

                Rectangle {
                    anchors.left: parent.left

                    height: parent.height
                    width: lineSize
                    color: "#000000"

                    visible: leftwall
                }

                Rectangle {
                    anchors.right: parent.right

                    height: parent.height
                    width: lineSize
                    color: "#000000"

                    visible: rightwall
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (root.generated && !parent.activeFocus && (delegate.calculatedColumn === 0 || delegate.calculatedColumn === columns - 1 || delegate.calculatedRow === 0 || delegate.calculatedRow === rows - 1)) {
                            parent.forceActiveFocus()
                        } else {
                            root.forceActiveFocus()
                        }

                        if (!root.generated) {
                            root.generated = true

                            active = !active
                            addToMaze(index)
                        }
                    }
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

        onRunningChanged: {
            if (!running) {

                var topLeft = 0
                var topRight = rows - 1
                var bottomLeft = root.count - rows
                var bottomRight = root.count - 1
                var typeOfMaze = Math.floor(Math.random() * 4)
                switch (typeOfMaze) {
                case 0:
                    openPathOnIndex(topRight, "right")
                    openPathOnIndex(bottomLeft, "left")
                    break
                case 1:
                    openPathOnIndex(topLeft, "left")
                    openPathOnIndex(bottomLeft, "left")
                    break
                case 2:
                    openPathOnIndex(topLeft, "left")
                    openPathOnIndex(bottomRight, "right")
                    break
                case 3:
                    openPathOnIndex(topRight, "right")
                    openPathOnIndex(bottomRight, "right")
                    break
                }

                root.grabToImage(function(result) {
                    result.saveToFile("maze_" + mazeId + ".png");

                    if (mazeId < mazesToGenerate) {
                        resetMaze()
                    }
                })
            }
        }
    }

    Component.onCompleted: {
        resetMaze()
    }
}

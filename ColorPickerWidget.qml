import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.13
import QtQuick.Window
import QtQuick.Shapes
import QtQuick.Effects

Rectangle {
    id: root2
    gradient: Gradient {
        GradientStop {
            position: 0.0; color: appliedColor
        }
        GradientStop {
            position: 1; color: "darkgrey"
        }
    }
    anchors.fill: parent
    property color selectedColor: "red"
    property color chosenColor: "red"
    property color appliedColor: "blue"
    property color chosenMainColor: "green"
    property real currentAngle: 0
    property real trackRadius: 87

    // Helper function to interpolate colors between your conical gradient stops
    function getColorAtAngle(angle) {
        var normAngle = angle % 360;
        if (normAngle < 0) normAngle += 360;
        var pos = normAngle / 360.0;

        // Note: Swapped red/green alignment to match your conical gradient visual layout
        var stops = [{
            pos: 0.00, color: Qt.rgba(1, 0, 0, 1)
        }, // red
            {
                pos: 0.17, color: Qt.rgba(1, 0, 1, 1)
            }, // magenta
            {
                pos: 0.33, color: Qt.rgba(0, 0, 1, 1)
            }, // blue
            {
                pos: 0.50, color: Qt.rgba(0, 1, 1, 1)
            }, // cyan
            {
                pos: 0.67, color: Qt.rgba(0, 1, 0, 1)
            }, // green
            {
                pos: 0.83, color: Qt.rgba(1, 1, 0, 1)
            }, // yellow
            {
                pos: 1.00, color: Qt.rgba(1, 0, 0, 1)
            } // red (loop back)
        ];

        for (var i = 0; i < stops.length - 1; i++) {
            if (pos >= stops[i].pos && pos <= stops[i+1].pos) {
                var localPos = (pos - stops[i].pos) / (stops[i+1].pos - stops[i].pos);
                return Qt.rgba(
                    stops[i].color.r + localPos * (stops[i+1].color.r - stops[i].color.r),
                    stops[i].color.g + localPos * (stops[i+1].color.g - stops[i].color.g),
                    stops[i].color.b + localPos * (stops[i+1].color.b - stops[i].color.b),
                    1.0
                );
            }
        }
        return "red";
    }


    function getColorFromTriangle(px, py) {
        // Triangle vertices matching your ShapePath:
        // p1 = Bottom-Left (Black), p2 = Top-Left (White), p3 = Right-Tip (selectedColor)
        var p1 = {
            x: 25, y: 125, color: Qt.rgba(0, 0, 0, 1)
        }; // Bottom corner (Black)
        var p2 = {
            x: 25, y: 25, color: Qt.rgba(1, 1, 1, 1)
        }; // Upper corner (White)
        var p3 = {
            x: 145, y: 75, color: getColorAtAngle(currentAngle)
        }; // Right tip (Hue color)

        var denom = (p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y);
        if (denom === 0) return selectedColor;

        // Calculate barycentric weights (w1, w2, w3)
        var w1 = ((p2.y - p3.y) * (px - p3.x) + (p3.x - p2.x) * (py - p3.y)) / denom;
        var w2 = ((p3.y - p1.y) * (px - p3.x) + (p1.x - p3.x) * (py - p3.y)) / denom;
        var w3 = 1.0 - w1 - w2;

        // Clamp weights between 0 and 1 just in case of minor floating-point drift
        w1 = Math.max(0, Math.min(1, w1));
        w2 = Math.max(0, Math.min(1, w2));
        w3 = Math.max(0, Math.min(1, w3));

        // Interpolate final RGB values
        var r = w1 * p1.color.r + w2 * p2.color.r + w3 * p3.color.r;
        var g = w1 * p1.color.g + w2 * p2.color.g + w3 * p3.color.g;
        var b = w1 * p1.color.b + w2 * p2.color.b + w3 * p3.color.b;

        return Qt.rgba(r, g, b, 1.0);
    }


    Item {
        id: root
        width: 200
        height: 40
        anchors.centerIn: parent
        // Property to hold the currently selected color


        // Button to trigger the pop-out color picker
        Button {
            id: triggerButton
            text: "Pick Color"
            anchors.fill: parent
            onClicked: colorPopup.open()

            background: Rectangle {
                color: root2.appliedColor
                radius: 6
                border.color: "#bdc3c7"
            }

            // Ensure text is readable depending on brightness
            contentItem: Text {
                text: triggerButton.text
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }



        // Pop-out Color Picker Popup
        Popup {
            id: colorPopup
            width: 300
            //implicitHeight: 380
            modal: true
            focus: true
            anchors.centerIn: Overlay.overlay

            background: Rectangle {
                id: popupBG
                color: "#bebebe"
                radius: 12
                border.color: "#dcdcdc"
            }

            contentItem: ColumnLayout {


                Text {
                    text: "Select Color"
                    font.bold: true
                    font.pixelSize: 16
                }


                // Preview Box
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 6
                    color: Qt.rgba(redSlider.value, greenSlider.value, blueSlider.value, alphaSlider.value)
                    border.color: "#ccc"
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    Layout.alignment: Qt.AlignHCenter

                    Shape {
                        anchors.centerIn: parent
                        width: 200
                        height: 200
                        anchors.top: parent.top
                        anchors.topMargin: 50
                        anchors.leftMargin: 150
                        anchors.left: left.parent

                        ShapePath {
                            fillColor: "grey"
                            strokeColor: "transparent" // Or add a stroke if desired

                            // Draw a circle shape using a path
                            startX: 100; startY: 0
                            PathArc {
                                x: 100; y: 200
                                radiusX: 100; radiusY: 100
                                useLargeArc: true
                            }
                            PathArc {
                                x: 100; y: 0
                                radiusX: 100; radiusY: 100
                                useLargeArc: true
                            }

                            fillGradient: ConicalGradient {
                                centerX: 100
                                centerY: 100
                                angle: 0

                                GradientStop {
                                    position: 0.00; color: "red"
                                }
                                GradientStop {
                                    position: 0.17; color: "yellow"
                                }
                                GradientStop {
                                    position: 0.33; color: "green"
                                }
                                GradientStop {
                                    position: 0.50; color: "cyan"
                                }
                                GradientStop {
                                    position: 0.67; color: "blue"
                                }
                                GradientStop {
                                    position: 0.83; color: "magenta"
                                }
                                GradientStop {
                                    position: 1.00; color: "red"
                                }
                            }
                        }

                        Rectangle {
                            width: 30
                            height: width
                            radius: width / 2
                            border.color: "black"
                            border.width: 2
                            color: "transparent"

                            x: (parent.width / 2) + trackRadius * Math.cos(currentAngle * Math.PI / 180) - (width / 2)
                            y: (parent.height / 2) + trackRadius * Math.sin(currentAngle * Math.PI / 180) - (height / 2)


                        }

                        MouseArea {
                            anchors.fill: parent

                            function updatePosition(mouseX, mouseY) {
                                var dx = mouseX - (width / 2);
                                var dy = mouseY - (height / 2);

                                // Calculate angle from center to mouse position
                                var rad = Math.atan2(dy, dx);
                                var deg = rad * (180 / Math.PI);

                                // Update angle so the draggable circle snaps to this position on the ring
                                currentAngle = deg;
                                chosenMainColor = getColorAtAngle(currentAngle);
                                chosenColor = getColorAtAngle(currentAngle);
                            }

                            onPressed: {
                                (mouse) => updatePosition(mouse.x, mouse.y)

                            }
                            onPositionChanged: (mouse) => updatePosition(mouse.x, mouse.y)
                        }
                        Rectangle {
                            id: circleMask
                            color: popupBG.color
                            anchors.centerIn: parent
                            width: parent.width * 0.75
                            height: parent.height* 0.75
                            radius: width/2

                            Shape {

                                id: triangleShape
                                anchors.centerIn: parent
                                anchors.fill: parent
                                transform: Rotation {
                                    origin.x: triangleShape.width / 2
                                    origin.y: triangleShape.height / 2
                                    angle: currentAngle
                                }

                                ShapePath {
                                    startX: 25; startY: 125
                                    PathLine {
                                        x: 25; y: 25
                                    }
                                    PathLine {
                                        x: 145; y: 75
                                    }
                                    PathLine {
                                        x: 25; y: 125
                                    }
                                    strokeColor: "transparent"

                                    fillGradient: LinearGradient {
                                        x1: 10; y1: 60 // Left edge / center base
                                        x2: 10; y2: 125 // Right tip corner (90° / pointing right)

                                        // Blend from White/Black base to neutral/black tip
                                        GradientStop {
                                            position: 0.0; color: "white"
                                        }
                                        GradientStop {
                                            position: 1.0; color: "black"
                                        }
                                    }
                                }

                                // --- 2. Overlay Triangle: Transparent to Current Color ---
                                // This introduces your hue/chroma at the right-hand tip while letting
                                // the white/black show through on the opposite side.
                                ShapePath {
                                    startX: 25; startY: 125
                                    PathLine {
                                        x: 25; y: 25
                                    }
                                    PathLine {
                                        x: 145; y: 75
                                    }
                                    PathLine {
                                        x: 25; y: 125
                                    }
                                    strokeColor: "transparent"

                                    fillGradient: LinearGradient {
                                        x1: 25; y1: 75 // Left edge (transparent)
                                        x2: 145; y2: 75 // Right tip corner (full current color)

                                        GradientStop {
                                            position: 0.0; color: Qt.rgba(0, 0, 0, 0)
                                        } // Transparent
                                        GradientStop {
                                            position: 1.0; color: chosenMainColor
                                        } // Current wheel color
                                    }

                                }


                                Rectangle {
                                    id: triangleCircle
                                    width: 30
                                    height: width
                                    radius: width / 2
                                    border.color: "black"
                                    border.width: 2
                                    color: "transparent"
                                    x: 50
                                    y: 59
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    // Helper function to check if a point (px, py) is inside the triangle vertices
                                    function isInsideTriangle(px, py, p1, p2, p3) {
                                        var areaOrig = Math.abs((p2.x - p1.x)*(p3.y - p1.y) - (p3.x - p1.x)*(p2.y - p1.y));
                                        var area1 = Math.abs((p1.x - px)*(p2.y - py) - (p2.x - px)*(p1.y - py));
                                        var area2 = Math.abs((p2.x - px)*(p3.y - py) - (p3.x - px)*(p2.y - py));
                                        var area3 = Math.abs((p3.x - px)*(p1.y - py) - (p1.x - px)*(p3.y - py));

                                        // Allow a tiny tolerance for floating-point comparison
                                        return Math.abs(areaOrig - (area1 + area2 + area3)) < 0.5;
                                    }

                                    function updateTrianglePicker(mx, my) {
                                        // Triangle vertices matching your ShapePath coordinates:
                                        var p1 = {
                                            x: 25, y: 125
                                        };
                                        var p2 = {
                                            x: 25, y: 25
                                        };
                                        var p3 = {
                                            x: 145, y: 75
                                        };

                                        // Center of the circle marker we want to position
                                        var targetX = mx - (triangleCircle.width / 2);
                                        var targetY = my - (triangleCircle.height / 2);
                                        var centerX = mx; // Center of the marker checking against the triangle
                                        var centerY = my;

                                        // Only update position if the center of the marker is inside the triangle
                                        if (isInsideTriangle(centerX, centerY, p1, p2, p3)) {
                                            triangleCircle.x = targetX;
                                            triangleCircle.y = targetY;

                                            chosenColor = getColorFromTriangle(mx, my);
                                        } else {
                                            // Optional: You can project or snap to the nearest boundary edge if desired,
                                            // or simply let it stay at the last valid position.
                                        }
                                    }

                                    onPressed: (mouse) => updateTrianglePicker(mouse.x, mouse.y)
                                    onPositionChanged: (mouse) => updateTrianglePicker(mouse.x, mouse.y)
                                }
                            }
                        }
                    }


                }

                // RGB Sliders
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: 8



                    // Red
                    Text {
                        text: "R:"
                    }
                    Slider {
                        id: redSlider
                        Layout.fillWidth: true
                        from: 0; to: 1; value: root2.chosenColor.r
                    }
                    Text {
                        text: Math.round(redSlider.value * 255)
                    }

                    // Green
                    Text {
                        text: "G:"
                    }
                    Slider {
                        id: greenSlider
                        Layout.fillWidth: true
                        from: 0; to: 1; value: root2.chosenColor.g
                    }
                    Text {
                        text: Math.round(greenSlider.value * 255)
                    }

                    // Blue
                    Text {
                        text: "B:"
                    }
                    Slider {
                        id: blueSlider
                        Layout.fillWidth: true
                        from: 0; to: 1; value: root2.chosenColor.b
                    }
                    Text {
                        text: Math.round(blueSlider.value * 255)
                    }

                    // Alpha
                    Text {
                        text: "A:"
                    }
                    Slider {
                        id: alphaSlider
                        Layout.fillWidth: true
                        from: 0; to: 1; value: root2.chosenColor.a
                    }
                    Text {
                        text: alphaSlider.value.toFixed(2)
                    }
                }

                // HEX Display / Input
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "HEX:"
                    }
                    TextField {
                        id: hexInput
                        Layout.fillWidth: true
                        text: Qt.rgba(redSlider.value, greenSlider.value, blueSlider.value, alphaSlider.value)
                        readOnly: true
                        horizontalAlignment: TextInput.AlignHCenter
                    }
                }

                // Apply & Close Button
                Button {
                    Layout.fillWidth: true
                    text: "Apply"
                    onClicked: {
                        root2.appliedColor = Qt.rgba(redSlider.value, greenSlider.value, blueSlider.value, alphaSlider.value)
                        colorPopup.close()
                    }
                }
            }
        }
    }
}
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    minimumHeight: 600
    minimumWidth: 800
    title: qsTr("Markov string parser")
    color: "whitesmoke"

    ListModel {
        id: resultModel
    }

    Connections {
        target: worker

        onStepResult: {
            resultModel.append({"before1": before1, "ruleKey":ruleKey, "before2" : before2, "after1": after1, "conv": conv, "after2": after2})
        }

        onResult: {
            parseResultText.text = "Результат: " + res
            startButton.enabled = true
            stopButton.enabled = false
        }
    }

    RowLayout{
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20
        ColumnLayout{
            //Layout.preferredWidth: parent.width / 2
            Layout.fillWidth: false
            spacing: 20

            Pane{
                id: groupRulesControl
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: rulesContentLayout.implicitWidth + 20
                contentHeight: rulesContentLayout.implicitHeight + groupRulesTitle.height + 20
                Material.elevation: 6
                Behavior on Material.elevation { NumberAnimation {duration: 100}}
                Material.background: Material.color(Material.Grey,Material.Shade100)
                padding: 0

                Rectangle{
                    id: groupRulesTitle
                    width: parent.width
                    height: 40
                    color: Material.color(Material.DeepPurple)
                    Material.elevation: 3
                    layer.enabled: groupRulesTitle.enabled && groupRulesTitle.Material.elevation > 0
                    layer.effect: ElevationEffect {
                        elevation: groupRulesTitle.Material.elevation
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 10
                        font.pixelSize: 16
                        color: Material.color(Material.Grey,Material.Shade100)
                        text: qsTr("Правила")
                    }
                }

                ColumnLayout{
                    id: rulesContentLayout
                    anchors.top: groupRulesTitle.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10

                    Row{
                        spacing: 10
                        TextField {
                            id: ruleBeforeField
                            placeholderText: "Символ или слово"
                            Material.accent: Material.DeepPurple
                        }

                        Text{
                            height: parent.height
                            text: "->"
                            font.pixelSize: 20
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: ruleAfterField
                            placeholderText: "Замена"
                            Material.accent: Material.DeepPurple
                        }

                        RoundButton {
                            id: addRuleButton
                            font.pixelSize: 20
                            text: qsTr("+")
                            Material.background: Material.DeepPurple
                            Material.foreground: Material.color(Material.Grey, Material.Shade300)
                            onClicked: {
                                var res = true;
                                for (var i = 0; i < rulesModel.count; i++)
                                {
                                    if(rulesModel.get(i).before == ruleBeforeField.text)
                                    {
                                        res = false;
                                        break;
                                    }
                                }

                                if(res)
                                {
                                    rulesModel.addRule(ruleBeforeField.text, ruleAfterField.text)
                                    ruleAfterField.clear()
                                    ruleBeforeField.clear()
                                }
                            }
                        }
                    }

                    ListView{
                        id: rulesView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: rulesModel
                        delegate: Item{ width: control.width + 10; height: control.height + 10; Pane {
                            id: control
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                            contentHeight: ruleNumberRect.height
                            contentWidth: ruleNumberRect.width + rowLayout.implicitWidth + 16
                            padding: 0
                            property double radius: 16
                            background: Rectangle {
                                    color: control.Material.backgroundColor
                                    radius: control.Material.elevation > 0 ? control.radius : 0
                                    layer.enabled: control.enabled && control.Material.elevation > 0
                                    layer.effect: ElevationEffect {
                                        elevation: control.Material.elevation
                                    }
                                }
                                Material.background: Material.color(Material.DeepPurple, Material.Shade200)
                                Material.elevation: 5

                                Rectangle {
                                    id: ruleNumberRect
                                    height: ruleItemIndexText.paintedHeight + 12
                                    width: height
                                    color: Material.color(Material.DeepPurple)
                                    radius: height / 2

                                    Text {
                                        id: ruleItemIndexText
                                        text: index + 1
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        bottomPadding: 2
                                        anchors.fill: parent
                                        color: Material.color(Material.Grey, Material.Shade100)
                                    }
                                }

                                RowLayout {
                                    id: rowLayout
                                    anchors.left: ruleNumberRect.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 6
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    spacing: 10

                                    Text {
                                        id: name
                                        text: before + " -> " + after
                                    }

                                    Rectangle {
                                        id: closeBtn
                                        height: closeBtnText.paintedHeight
                                        width: height
                                        color: {
                                            if(closeBtnMouse.pressed)
                                                return Material.color(Material.DeepPurple, Material.Shade700)
                                            else if (closeBtnMouse.containsMouse)
                                                return Material.color(Material.DeepPurple, Material.Shade600)

                                            return Material.color(Material.DeepPurple)
                                        }
                                        radius: height / 2
                                        Material.elevation: 6
                                        layer.enabled: closeBtn.enabled && control.Material.elevation > 0
                                        layer.effect: ElevationEffect {
                                            elevation: closeBtn.Material.elevation
                                        }
                                        Text {
                                            id: closeBtnText
                                            font.pixelSize: 14
                                            text: "-"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            bottomPadding: 2
                                            anchors.fill: parent
                                            color: Material.color(Material.Grey, Material.Shade100)
                                        }
                                        MouseArea{
                                            id: closeBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                rulesModel.deleteRule(index)
                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Pane{
                id: groupSettingsControl
                Layout.fillWidth: true
                contentWidth: delayLayout.implicitWidth + 20
                contentHeight: delayLayout.implicitHeight + groupSettingsTitle.height + 20
                Material.elevation: 6
                Behavior on Material.elevation { NumberAnimation {duration: 100}}
                Material.background: Material.color(Material.Grey,Material.Shade100)
                padding: 0

                Rectangle{
                    id: groupSettingsTitle
                    width: parent.width
                    height: 40
                    color: Material.color(Material.DeepPurple)
                    Material.elevation: 3
                    layer.enabled: groupSettingsTitle.enabled && groupSettingsTitle.Material.elevation > 0
                    layer.effect: ElevationEffect {
                        elevation: groupSettingsTitle.Material.elevation
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 10
                        font.pixelSize: 16
                        color: Material.color(Material.Grey,Material.Shade100)
                        text: qsTr("Настройки")
                    }
                }

            Row{
                id: delayLayout
                anchors.top: groupSettingsTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                spacing: 10
                Text{
                    text: "Задержка выполнения"
                    anchors.verticalCenter: parent.verticalCenter
                    width: delayLayout.width - setDelayByutton.width - delayField.width - delayLayout.spacing*3
                }
                TextField {
                    id: delayField
                    width: 60
                    placeholderText: "Задержка (сек.)"
                    validator: DoubleValidator{
                        bottom: 0.0
                        decimals: 1
                        top: 99.9
                    }

                    Material.accent: Material.DeepPurple
                    text: "2,0"
                }

                Button{
                    id: setDelayByutton
                    text: "Установить"
                    Material.background: Material.DeepPurple
                    Material.foreground: Material.color(Material.Grey, Material.Shade300)
                    onClicked: {
                        worker.setDelay(Number.fromLocaleString(delayField.text))
                    }
                }
            }
        }
        }

        Pane{
            id: groupResultControl
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: resultContentLayout.implicitWidth + 20
            contentHeight: resultContentLayout.implicitHeight + groupResultTitle.height + 20
            Material.elevation: 6
            Behavior on Material.elevation { NumberAnimation {duration: 100}}
            Material.background: Material.color(Material.Grey,Material.Shade100)
            padding: 0

            Rectangle{
                id: groupResultTitle
                width: parent.width
                height: 40
                color: Material.color(Material.DeepPurple)
                Material.elevation: 3

                layer.enabled: groupResultTitle.enabled && groupResultTitle.Material.elevation > 0
                layer.effect: ElevationEffect {
                    elevation: groupResultTitle.Material.elevation
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 10
                    font.pixelSize: 16
                    color: Material.color(Material.Grey,Material.Shade100)
                    text: qsTr("Обработка строки")
                }
            }
            ColumnLayout{
                id: resultContentLayout
                anchors.top: groupResultTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
            Row{
                id: startParseLayout
                spacing: 5
                Layout.fillWidth: true
                TextField {
                    width: startParseLayout.width - startButton.width - stopButton.width - startParseLayout.spacing*3
                    id: parseTextField
                    placeholderText: "Текст"
                    Material.accent: Material.DeepPurple
                }

                Button{
                    id: startButton
                    text: "Старт"
                    Material.background: Material.DeepPurple
                    Material.foreground: Material.color(Material.Grey, Material.Shade300)
                    onClicked: {
                        resultModel.clear()
                        parseResultText.text = ""
                        worker.start(parseTextField.text,rulesModel)
                        startButton.enabled = false
                        stopButton.enabled = true
                    }
                }

                Button{
                    id: stopButton
                    enabled: false
                    text: "Стоп"
                    Material.background: Material.Red
                    Material.foreground: Material.color(Material.Grey, Material.Shade300)
                    onClicked: {
                        worker.stop()
                        startButton.enabled = true
                        stopButton.enabled = false
                    }
                }
            }

            ListView{
                id: resultView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: resultModel
                clip: true
                ScrollBar.vertical: ScrollBar{policy: ScrollBar.AsNeeded; Material.background: Material.DeepPurple}
                delegate: Item{ width: resultView.width - 10; height: resultControl.height + 10;
                    Pane {
                        id: resultControl
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.leftMargin: 10
                        padding: 8

                        property double radius: 16
                        background: Rectangle {
                                color: resultControl.Material.backgroundColor
                                radius: resultControl.Material.elevation > 0 ? resultControl.radius : 0
                                layer.enabled: resultControl.enabled && resultControl.Material.elevation > 0
                                layer.effect: ElevationEffect {
                                    elevation: resultControl.Material.elevation
                                }
                            }
                        Material.background: Material.color(Material.DeepPurple, Material.Shade200)
                        Material.elevation: 3

                        ColumnLayout{
                            Text{text:"Найден символ : " + ruleKey}
                            GridLayout{
                                rows: 2
                                columns: 2
                                Text{text:"До перестановки:"}
                                Text{textFormat: Text.RichText; text: before1+"<font color=\"#FF0000\">"+ruleKey+"</font>" + before2}
                                Text{text: "После перестановки:"}
                                Text{textFormat: Text.RichText; text: after1+"<font color=\"#FF0000\">"+conv+"</font>" + after2}
                            }
                        }
                    }
                }

                onCountChanged: {
                    Qt.callLater( resultView.positionViewAtEnd )
                }
            }

            Item{
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.bottomMargin: 20
                Layout.topMargin: 5
                height: 20
                Pane {
                    id: resultTextControl
                    padding: 8

                    property double radius: 16
                    background: Rectangle {
                            color: resultTextControl.Material.backgroundColor
                            radius: resultTextControl.Material.elevation > 0 ? resultTextControl.radius : 0
                            layer.enabled: resultTextControl.enabled && resultTextControl.Material.elevation > 0
                            layer.effect: ElevationEffect {
                                elevation: resultTextControl.Material.elevation
                            }
                        }
                    Material.background: parseResultText.text.length == 0 ? Qt.rgba(0,0,0,0) : Material.color(Material.Green, Material.Shade300)
                    Material.elevation: parseResultText.text.length == 0 ? 0 : 6

                    Text{
                        id: parseResultText
                        text: ""
                        font.bold: true
                    }
                }
            }
            }
        }
    }
}





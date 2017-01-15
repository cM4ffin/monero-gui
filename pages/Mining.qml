// Copyright (c) 2014-2015, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components"
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "#F0EEEE"
    property var currentHashRate: 0

    function isDaemonLocal() {
        var daemonAddress = appWindow.persistentSettings.daemon_address
        if (daemonAddress === "")
            return false
        var daemonHost = daemonAddress.split(":")[0]
        if (daemonHost === "127.0.0.1" || daemonHost === "localhost")
            return true
        return false
    }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: 10
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 20

        Rectangle {
            anchors.fill: soloBox
            color: "#00000000"
            border.width: 2
            border.color: "#CCCCCC"
            anchors.margins: -15
        }

        // solo
        ColumnLayout {
            id: soloBox
            anchors.margins: 40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            Label {
                id: soloTitleLabel
                fontSize: 24
                text: qsTr("Solo mining")
            }

            Label {
                id: soloLocalDaemonsLabel
                fontSize: 18
                color: "#D02020"
                text: qsTr("(only available for local daemons)")
                visible: !isDaemonLocal()
            }

            Text {
                id: soloMainLabel
                text: qsTr("Mining helps the Monero network build resilience.<br>")
                      + qsTr("The more mining is done, the harder it is to attack the network.<br>")
                      + qsTr("Moreover, mining gives you a small chance to earn some Monero.<br>")
                      + qsTr("Your computer will search for Monero block solutions.<br>")
                      + qsTr("If you find one, you will get the associated block reward.<br>")
                      + translationManager.emptyString
                wrapMode: Text.Wrap
            }

            RowLayout {
                id: soloMinerThreadsRow
                Label {
                    id: soloMinerThreadsLabel
                    color: "#4A4949"
                    text: qsTr("CPU threads") + translationManager.emptyString
                    fontSize: 16
                }
                LineEdit {
                    id: soloMinerThreadsLine
                    Layout.preferredWidth:  200
                    text: "1"
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    validator: IntValidator { bottom: 1 }
                }
            }

            RowLayout {
                Label {
                    id: manageSoloMinerLabel
                    color: "#4A4949"
                    text: qsTr("Manage miner") + translationManager.emptyString
                    fontSize: 16
                }

                StandardButton {
                    visible: true
                    //enabled: !walletManager.isMining()
                    id: startSoloMinerButton
                    width: 110
                    text: qsTr("Start mining") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    onClicked: {
                        var success = walletManager.startMining(appWindow.currentWallet.address, soloMinerThreadsLine.text)
                        if (success) {
                            update()
                        } else {
                            errorPopup.title  = qsTr("Error starting mining") + translationManager.emptyString;
                            errorPopup.text = qsTr("Couldn't start mining.<br>")
                            if (!isDaemonLocal())
                                errorPopup.text += qsTr("Mining is only available on local daemons. Run a local daemon to be able to mine.<br>")
                            errorPopup.icon = StandardIcon.Critical
                            errorPopup.open()
                        }
                    }
                }

                StandardButton {
                    visible: true
                    //enabled:  walletManager.isMining()
                    id: stopSoloMinerButton
                    width: 110
                    text: qsTr("Stop mining") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    onClicked: {
                        walletManager.stopMining()
                        update()
                    }
                }
            }
        }

        Text {
            id: statusText
            anchors.leftMargin: 40
            anchors.topMargin: 17
            text: qsTr("Status: not mining")
            textFormat: Text.RichText
            wrapMode: Text.Wrap
        }
    }

    function updateStatusText() {
        var text = ""
        if (walletManager.isMining()) {
            if (text !== "")
                text += "<br>";
            text += qsTr("Mining at %1 H/s").arg(walletManager.miningHashRate())
        }
        if (text === "") {
            text += qsTr("Not mining") + translationManager.emptyString;
        }
        statusText.text = qsTr("Status: ") + text
    }

    function update() {
        updateStatusText()
        startSoloMinerButton.enabled = !walletManager.isMining()
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled
    }

    StandardDialog {
        id: errorPopup
        cancelVisible: false
    }

    Timer {
        id: timer
        interval: 2000; running: false; repeat: true
        onTriggered: update()
    }

    function onPageCompleted() {
        console.log("Mining page loaded");

        update()
        timer.running = true

    }
    function onPageClosed() {
        timer.running = false
    }
}

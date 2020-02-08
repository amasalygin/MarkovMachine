from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject,pyqtSignal, pyqtSlot, pyqtProperty
from MarkovMachine import Machine
from rulesmodel import RulesModel


class Worker(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.machine = Machine()

    stepResult = pyqtSignal([str, str, str,str,str,str], arguments=['before1', 'ruleKey', 'before2', 'after1',
                                                                    'conv', 'after2'])
    result = pyqtSignal(str, arguments=["res"])

    def notifyStepResult(self, **kwargs):
        before = kwargs['before']
        pos = kwargs['pos']
        key = kwargs['key']
        conv = kwargs['conv']
        after = kwargs['after']

        before1 = before[0:pos]
        before2 = before[pos+len(key):]

        after1 = after[0:pos]
        after2 = after[pos+len(conv):]

        self.stepResult.emit(before1, key, before2, after1, conv, after2)

    def notifyResult(self, string):
        self.result.emit(string)

    @pyqtSlot()
    def stop(self):
        self.machine.stop()

    @pyqtSlot(float)
    def setDelay(self, value):
        self.machine.delay = value

    @pyqtSlot(str,"QVariant")
    def start(self, string, rulesModel):
        rules = rulesModel.toDict()
        self.machine.string = string
        self.machine.rules = rules
        self.machine.setResultCallback(self.notifyResult)
        self.machine.setStepCallback(self.notifyStepResult)
        self.machine.start()


if __name__ == "__main__":
    import sys
    import os

    app = QGuiApplication(sys.argv)
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"

    engine = QQmlApplicationEngine()
    worker = Worker()
    rModel = RulesModel()

    engine.rootContext().setContextProperty("rulesModel", rModel)
    engine.rootContext().setContextProperty("worker", worker)

    engine.load("view.qml")

    engine.quit.connect(app.quit)
    sys.exit(app.exec_())

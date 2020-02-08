from PyQt5.QtCore import QObject, QAbstractListModel, Qt, QModelIndex, pyqtSlot

class RulesModel(QAbstractListModel):

    BeforeRole = Qt.UserRole + 1
    AfterRole = Qt.UserRole + 2

    def __init__(self, *args, rules=None, **kwargs):
        super(RulesModel, self).__init__(*args, **kwargs)
        self.rules = rules or []

    def data(self, index, role):
        if role == Qt.DisplayRole:
            text = self.rules[index.row()]["before"] + "->" + self.rules[index.row()]["after"]
            return text
        if role == RulesModel.BeforeRole:
            text = self.rules[index.row()]["before"]
            return text
        if role == RulesModel.AfterRole:
            text = self.rules[index.row()]["after"]
            return text

    def rowCount(self, index=QModelIndex()):
        return len(self.rules)

    def roleNames(self):
        return {
            RulesModel.BeforeRole: b'before',
            RulesModel.AfterRole: b'after'
        }

    @pyqtSlot(str, str)
    def addRule(self, before, after):
        res = True
        for item in self.rules:
            if item["before"] == before:
                res = False

        if res:
            self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
            self.rules.append({"before": before, "after": after})
            self.endInsertRows()

    @pyqtSlot(int)
    def deleteRule(self, row):
        self.beginRemoveColumns(QModelIndex(), row, row)
        del self.rules[row]
        self.endRemoveRows()

    def toDict(self):
        dict = {}
        for item in self.rules:
            dict[item["before"]] = item["after"]
        return dict
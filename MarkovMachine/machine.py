from time import sleep
import threading

class Machine():
    def __init__(self):
        self.__string = str()
        self.__rules = dict()
        self.__stop = False
        self.__delay = 2.0
        self.__running = False
        self.notifyStep = None
        self.notifyResult = None

    @property
    def rules(self):
        return self.__rules

    @rules.setter
    def rules(self, rules):
        self.__rules = rules

    @property
    def string(self):
        return self.__string

    @string.setter
    def string(self, string):
        self.__string = string

    @property
    def delay(self):
        return self.__delay

    @delay.setter
    def delay(self, value):
        self.__delay = value

    @property
    def running(self):
        return self.__running

    def setStepCallback(self, notify):
        self.notifyStep = notify

    def setResultCallback(self, notify):
        self.notifyResult = notify

    def stop(self):
        self.__stop = True

    def start(self):
        self.__running = True
        thr = threading.Thread(target=self.__parsingfunction)
        thr.start()

    def __parsingfunction(self):
        self.__stop = False
        final = False
        changed = True
        while changed:
            changed = False

            for key in self.__rules:
                pos = self.__string.find(key)
                if pos != -1:
                    before = self.__string
                    conversion = self.__rules.get(key)

                    if(conversion.startswith('.')):
                        final = True
                        conversion = conversion.replace('.', '')

                    self.__string = self.__string.replace(key, conversion, 1)

                    if self.notifyStep is not None:
                        self.notifyStep(before=before, key=key, conv=conversion, pos=pos, after=self.__string)
                    else:
                        print(self.__string)

                    changed = True
                    sleep(self.__delay)
                    if final or self.__stop or changed:
                        break

            if final or self.__stop:
                break

        if self.notifyResult is not None:
            self.notifyResult(self.__string)

        self.__running = False
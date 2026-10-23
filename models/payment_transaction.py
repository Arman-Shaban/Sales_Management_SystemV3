#Nastaran
class PaymentTransaction:
    def __init__(self, receipt_id, amount, date, time):
        self.receipt_id = receipt_id
        self.amount = amount
        self.date = date
        self.time = time

class PaymentReceived(PaymentTransaction):
    def __init__(self):
        pass

class OutgoingPayment(PaymentTransaction):
    def __init__(self):
        pass

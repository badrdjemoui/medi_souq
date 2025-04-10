
class PaymentService {
  Future<bool> processPayment(double amount) async {
    try {
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}

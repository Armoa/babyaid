import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/payment_provider.dart';

class SelectMetodPay extends StatelessWidget {
  const SelectMetodPay({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: true);

    return Card(
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 236, 236, 236),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Método de Pago",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildPaymentOption(context, "Pago Online"),
                      _buildPaymentOption(context, "Efectivo"),
                      _buildPosOptions(context), // Opciones Pos con subniveles
                      _buildTransferOption(context), // Opción Transferencia
                    ],
                  ),
                ),
              );
            },
          );
        },
        leading: const Icon(Icons.account_balance_wallet, size: 28),
        title: const Text("Método de pago"),
        subtitle: Text(
          paymentProvider.selectedMethod,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title) {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        color:
            paymentProvider.selectedMethod == title ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color:
                paymentProvider.selectedMethod == title
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        trailing: Icon(
          paymentProvider.selectedMethod == title
              ? Icons.check
              : Icons.arrow_forward_ios_rounded,
          color:
              paymentProvider.selectedMethod == title
                  ? Colors.white
                  : Colors.black,
        ),
        onTap: () {
          paymentProvider.updateMethod(title); // Actualiza el estado global
          Navigator.pop(context); // Cierra el Modal
        },
      ),
    );
  }

  Widget _buildPosOptions(BuildContext context) {
    Provider.of<PaymentProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: const Text("Pos", style: TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 236, 236, 236),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Seleccionar tipo de tarjeta",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSubOption(context, "Pos/Tarjeta de Crédito"),
                      _buildSubOption(context, "Pos/Tarjeta de Débito"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubOption(BuildContext context, String title) {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        color:
            paymentProvider.selectedMethod == title ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color:
                paymentProvider.selectedMethod == title
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        trailing: Icon(
          paymentProvider.selectedMethod == title
              ? Icons.check
              : Icons.arrow_forward_ios_rounded,
          color:
              paymentProvider.selectedMethod == title
                  ? Colors.white
                  : Colors.black,
        ),
        onTap: () {
          paymentProvider.updateMethod(title); // Actualiza el estado global
          Navigator.pop(context); // Cierra la última hoja
          Navigator.pop(context); // Cierra la hoja principal
        },
      ),
    );
  }

  Widget _buildTransferOption(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: const Text("Transferencia", style: TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 236, 236, 236),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Datos para la transferencia",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Datos Bancarios",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          paymentProvider.updateMethod(
                            "Transferencia",
                          ); // Actualiza el estado global
                          Navigator.pop(context); // Cierra la última hoja
                          Navigator.pop(context); // Cierra la hoja principal
                        },
                        child: const Text("Seleccionar"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

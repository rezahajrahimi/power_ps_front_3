import 'package:flutter/material.dart';

class AddOrRemoveReservationProductDialog extends StatefulWidget {
  const AddOrRemoveReservationProductDialog(
      {super.key, required this.productId, required this.hasReserved});
  final BigInt productId;
  final bool hasReserved;
  @override
  State<AddOrRemoveReservationProductDialog> createState() =>
      _AddOrRemoveReservationProductDialogState();
}

class _AddOrRemoveReservationProductDialogState
    extends State<AddOrRemoveReservationProductDialog> {
  bool _minusBallance = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SizedBox(
          height: 200,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.hasReserved
                  ? const Text(
                      "حذف تمدید خودکار",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      "فعال سازی تمدید خودکار",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  widget.hasReserved
                      ? const Text(
                          "مبلغ تمدید به حساب کاربر بازگردد؟",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          "مبلغ تمدید از حساب کاربر کم بشود؟",
                        ),
                  const Spacer(),
                  Switch(
                      value: _minusBallance,
                      onChanged: (_) {
                        setState(() {
                          _minusBallance = !_minusBallance;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _minusBallance = true;
                      });
                    },
                    child: const Text("تایید"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _minusBallance = false;
                      });
                    },
                    child: const Text("لغو"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

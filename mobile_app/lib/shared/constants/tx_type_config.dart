import 'package:flutter/material.dart';

class TxTypeConfig {
  final String label;
  final IconData icon;
  final Color color;

  const TxTypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const txTypeConfigs = <String, TxTypeConfig>{
  'expense': TxTypeConfig(
    label: 'Expense',
    icon: Icons.arrow_upward_rounded,
    color: Color(0xFFEF5350),
  ),
  'income': TxTypeConfig(
    label: 'Income',
    icon: Icons.arrow_downward_rounded,
    color: Color(0xFF66BB6A),
  ),
  'transfer': TxTypeConfig(
    label: 'Transfer',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF42A5F5),
  ),
  'loan_given': TxTypeConfig(
    label: 'Loan Given',
    icon: Icons.person_add_rounded,
    color: Color(0xFFFFA726),
  ),
  'loan_taken': TxTypeConfig(
    label: 'Loan Taken',
    icon: Icons.person_remove_rounded,
    color: Color(0xFFAB47BC),
  ),
  'repayment_received': TxTypeConfig(
    label: 'Received',
    icon: Icons.check_circle_rounded,
    color: Color(0xFF26A69A),
  ),
  'repayment_paid': TxTypeConfig(
    label: 'Paid Back',
    icon: Icons.payments_rounded,
    color: Color(0xFFFFCA28),
  ),
};

bool _isOutflow(String type) =>
    type == 'expense' || type == 'loan_given' || type == 'repayment_paid';

Color amountColor(String type) =>
    _isOutflow(type) ? const Color(0xFFEF5350) : const Color(0xFF66BB6A);

String amountPrefix(String type) => _isOutflow(type) ? '−' : '+';

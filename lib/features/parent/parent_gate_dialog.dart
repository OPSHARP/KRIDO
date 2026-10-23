import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/widgets/playful_bouncing_effects.dart';

class ParentGateDialog extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const ParentGateDialog({super.key, required this.onAuthenticated});

  static Future<void> show(BuildContext context, {required VoidCallback onSuccess}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ParentGateDialog(onAuthenticated: onSuccess),
    );
  }

  @override
  ConsumerState<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends ConsumerState<ParentGateDialog> {
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyTap(String key) async {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += key;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        final gateService = ref.read(parentGateServiceProvider);
        final isValid = await gateService.verifyPin(_enteredPin);
        if (isValid) {
          if (mounted) {
            Navigator.pop(context);
            widget.onAuthenticated();
          }
        } else {
          if (mounted) {
            setState(() {
              _enteredPin = '';
              if (gateService.isLockedOut) {
                _errorMessage =
                    'Too many attempts. Locked for ${gateService.remainingLockoutSeconds}s';
              } else {
                _errorMessage = 'Incorrect PIN. Try again.';
              }
            });
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gateService = ref.watch(parentGateServiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppTheme.cardWhite,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 340),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 440,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              // Left Column: Header & PIN indicator
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, size: 38, color: AppTheme.purple),
                    const SizedBox(height: 4),
                    const Text(
                      'Parents Only',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter 4-digit Parent PIN\n(Default: 1234)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    // PIN circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final isFilled = i < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? AppTheme.purple : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              Container(width: 1.5, height: 220, color: Colors.grey.shade200),
              const SizedBox(width: 12),

              // Right Column: Keypad
              if (gateService.isLockedOut)
                Expanded(
                  child: Center(
                    child: Text(
                      'Please wait ${gateService.remainingLockoutSeconds} seconds',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int row = 0; row < 3; row++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int col = 1; col <= 3; col++)
                            _buildKeyButton('${row * 3 + col}'),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 52, height: 44),
                        _buildKeyButton('0'),
                        Container(
                          margin: const EdgeInsets.all(4),
                          width: 44,
                          height: 44,
                          child: IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.backspace_rounded,
                                color: AppTheme.textNavy),
                            onPressed: _onBackspace,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildKeyButton(String text) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: 44,
      height: 44,
      child: BouncyBounceTap(
        onTap: () => _onKeyTap(text),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: AppTheme.textNavy,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _onKeyTap(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

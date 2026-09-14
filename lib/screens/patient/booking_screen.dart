import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/user_models.dart';
import 'booking_confirmation_screen.dart';

/// RÃ©servation d'un rendez-vous avec [psy] : choix du crÃ©neau, puis
/// simulation de paiement (BaridiMob/CCP fictif), puis confirmation.
class BookingScreen extends StatefulWidget {
  final PsychologueModel psy;
  const BookingScreen({super.key, required this.psy});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final List<DateTime> _days;
  int _selectedDayIndex = 0;
  String? _selectedTime;
  bool _paymentStep = false;
  String _paymentMethod = 'BaridiMob';

  static const List<String> _slots = [
    '09:00',
    '10:30',
    '13:00',
    '14:30',
    '16:00',
    '17:30',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i + 1));
  }

  DateTime get _selectedDateTime {
    final day = _days[_selectedDayIndex];
    final parts = _selectedTime!.split(':');
    return DateTime(day.year, day.month, day.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }

  void _confirmBooking() {
    final rdv = context.read<AppState>().bookAppointment(
          psy: widget.psy,
          dateHeure: _selectedDateTime,
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(rendezVous: rdv, psy: widget.psy),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paymentStep ? 'Paiement' : 'Prendre rendez-vous'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_paymentStep) {
              setState(() => _paymentStep = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: _paymentStep ? _buildPaymentStep() : _buildSlotStep(),
      ),
    );
  }

  // -------------------- Ã‰tape 1 : choix du crÃ©neau --------------------
  Widget _buildSlotStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rendez-vous avec ${widget.psy.fullName}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Choisissez une date',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final day = _days[i];
              final selected = i == _selectedDayIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() {
                  _selectedDayIndex = i;
                  _selectedTime = null;
                }),
                child: Container(
                  width: 58,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekdayLabel(day.weekday),
                          style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? Colors.white70
                                  : AppColors.textLight)),
                      const SizedBox(height: 4),
                      Text('${day.day}',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textDark)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        const Text('Choisissez un horaire',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _slots.map((slot) {
            final selected = slot == _selectedTime;
            return ChoiceChip(
              label: Text(slot),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              onSelected: (_) => setState(() => _selectedTime = slot),
            );
          }).toList(),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: _selectedTime == null
              ? null
              : () => setState(() => _paymentStep = true),
          child: const Text('Continuer'),
        ),
      ],
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return labels[weekday - 1];
  }

  // -------------------- Ã‰tape 2 : paiement fictif --------------------
  Widget _buildPaymentStep() {
    final day = _days[_selectedDayIndex];
    final dateLabel =
        '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RÃ©capitulatif',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 10),
              _RecapRow('Psychologue', widget.psy.fullName),
              _RecapRow('Date', dateLabel),
              _RecapRow('Heure', _selectedTime ?? '-'),
              _RecapRow('Montant', '2 500 DA'),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text('Mode de paiement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentOption(
                label: 'BaridiMob',
                imagePath: 'assets/images/baridi.jpg',
                selected: _paymentMethod == 'BaridiMob',
                onTap: () => setState(() => _paymentMethod = 'BaridiMob'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentOption(
                label: 'CCP',
                imagePath: 'assets/images/ccp.JPG',
                selected: _paymentMethod == 'CCP',
                onTap: () => setState(() => _paymentMethod = 'CCP'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _paymentMethod == 'BaridiMob'
                      ? 'assets/images/baridi.jpg'
                      : 'assets/images/ccp.JPG',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _paymentMethod == 'BaridiMob'
                      ? 'NumÃ©ro BaridiMob : 00799999XXXXXXXXXX\n(Ã  remplacer par le vrai identifiant)'
                      : 'Compte CCP : XXXXXXXX ClÃ© XX\n(Ã  remplacer par le vrai identifiant)',
                  style: const TextStyle(
                      color: AppColors.textLight, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'âš ï¸ Paiement simulÃ© pour la dÃ©mo : aucune vÃ©rification bancaire '
          "rÃ©elle n'est effectuÃ©e. En production, prÃ©voir un upload de "
          "reÃ§u + validation manuelle, ou une vraie API de paiement.",
          style: TextStyle(color: AppColors.textLight, fontSize: 12.5),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _confirmBooking,
          child: const Text("J'ai effectuÃ© le paiement"),
        ),
      ],
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  const _RecapRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentOption({
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.account_balance_wallet_rounded,
                  color: selected ? AppColors.primary : AppColors.textLight,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

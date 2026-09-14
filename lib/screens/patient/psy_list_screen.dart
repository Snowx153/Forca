import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/user_models.dart';
import 'psy_profile_screen.dart';

class PsyListScreen extends StatelessWidget {
  const PsyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final psychologues = context.watch<AppState>().psychologues;
    final appState = context.watch<AppState>();
    final t = appState.t;

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(title: Text(t('psylist_appbar'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              t('psylist_title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t('psylist_subtitle'),
              style: TextStyle(color: AppColors.textLight, height: 1.4),
            ),
            const SizedBox(height: 20),
            ...psychologues.map((psy) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PsyCard(psy: psy),
                )),
          ],
        ),
      ),
      ),
    );
  }
}

class _PsyCard extends StatelessWidget {
  final PsychologueModel psy;
  const _PsyCard({required this.psy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PsyProfileScreen(psyId: psy.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage:
                  psy.photoUrl.isNotEmpty ? AssetImage(psy.photoUrl) : null,
              child: psy.photoUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(psy.fullName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(psy.specialite,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textLight)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF5A623), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        psy.avis.isEmpty
                            ? context.read<AppState>().t('psylist_new')
                            : psy.noteMoyenne.toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(width: 6),
                      Text('(${psy.nombreAvis} ${context.read<AppState>().t('psylist_reviews_suffix')})',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textLight)),
                      const Spacer(),
                      Text('${psy.anneesExperience} ${context.read<AppState>().t('psylist_years_exp_suffix')}',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}


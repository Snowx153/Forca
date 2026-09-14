import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import 'patient_home_screen.dart';
import 'qcm_result_screen.dart';

class PatientQcmScreen extends StatefulWidget {
  final bool readOnly;
  const PatientQcmScreen({super.key, this.readOnly = false});

  @override
  State<PatientQcmScreen> createState() => _PatientQcmScreenState();
}

class _PatientQcmScreenState extends State<PatientQcmScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;

  int? _annees;
  final Set<String> _typesDrogueSelectionnes = {};
  String? _frequence;
  String? _quantite;

  final List<int> _anneesOptions = [0, 1, 2, 3, 5, 10];
  final List<String> _typesDrogue = [
    'Alcool',
    'Tabac',
    'Cannabis',
    'CocaÃ¯ne',
    'MÃ©dicaments dÃ©tournÃ©s',
    'Autre',
  ];
  final List<String> _frequences = [
    'Occasionnelle',
    'Hebdomadaire',
    'Quotidienne',
    'Plusieurs fois par jour',
  ];
  final List<String> _quantites = [
    'Faible',
    'ModÃ©rÃ©e',
    'Ã‰levÃ©e',
    'TrÃ¨s Ã©levÃ©e',
  ];

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _annees != null;
      case 1:
        return _typesDrogueSelectionnes.isNotEmpty;
      case 2:
        return _frequence != null;
      case 3:
        return _quantite != null;
      default:
        return false;
    }
  }

  Future<void> _next() async {
    if (widget.readOnly) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        (route) => false,
      );
      return;
    }
    if (_step == 3) {
      final appState = context.read<AppState>();
      try {
        final questionnaireResponse =
            await appState.getInitialQuestionnaire();
        final questionnaire =
            questionnaireResponse['questionnaire'] as Map<String, dynamic>;
        final questions = (questionnaire['questions'] as List)
            .cast<Map<String, dynamic>>();
        final answers = <Map<String, dynamic>>[];

        void addAnswer(int position, String value) {
          final question = questions.firstWhere(
            (item) => item['position'] == position,
          );
          final options = (question['options'] as List)
              .cast<Map<String, dynamic>>();
          final option = options.firstWhere(
            (item) => item['value'].toString() == value ||
                item['label'].toString() == value,
          );
          answers.add({
            'question_id': question['id'],
            'question_option_id': option['id'],
          });
        }

        void addAnswerByOptionPosition(int position, int optionPosition) {
          final question = questions.firstWhere(
            (item) => item['position'] == position,
          );
          final options = (question['options'] as List)
              .cast<Map<String, dynamic>>();
          final option = options.firstWhere(
            (item) => item['position'] == optionPosition,
          );
          answers.add({
            'question_id': question['id'],
            'question_option_id': option['id'],
          });
        }

        addAnswer(1, _annees == 0 ? 'less_than_one' : _annees.toString());
        for (final value in _typesDrogueSelectionnes) {
          addAnswerByOptionPosition(2, _typesDrogue.indexOf(value) + 1);
        }
        addAnswerByOptionPosition(3, _frequences.indexOf(_frequence!) + 1);
        addAnswerByOptionPosition(4, _quantites.indexOf(_quantite!) + 1);
        await appState.submitInitialQuestionnaire(answers);
        appState.saveQcm(
          anneesDependance: _annees!,
          typeDrogue: _typesDrogueSelectionnes.join(', '),
          frequence: _frequence!,
          quantite: _quantite!,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d’enregistrer le QCM.')),
          );
          return;
        }
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const QcmResultScreen()),
        (route) => false,
      );
    } else {
      setState(() => _step++);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    if (widget.readOnly) {
      // Si le patient a dÃ©jÃ  rempli le QCM, on va directement Ã  l'accueil
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
        title: Text(t('qcm_title')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuestionPage(
                    title: t('qcm_step1_title'),
                    subtitle: t('qcm_step1_subtitle'),
                    options: _anneesOptions
                        .map((a) => a == 0
                            ? t('qcm_years_less_than_one')
                            : '$a ${t('qcm_years_suffix')}')
                        .toList(),
                    selected: _annees == null
                        ? null
                        : (_annees == 0
                            ? t('qcm_years_less_than_one')
                            : '$_annees ${t('qcm_years_suffix')}'),
                    onSelect: (val) {
                      final idx = _anneesOptions.indexWhere(
                            (a) => (a == 0
                                  ? t('qcm_years_less_than_one')
                                  : '$a ${t('qcm_years_suffix')}') ==
                              val);
                      setState(() => _annees = _anneesOptions[idx]);
                    },
                  ),
                  _QuestionPage(
                    title: t('qcm_step2_title'),
                    subtitle: t('qcm_step2_subtitle'),
                    options: _typesDrogue,
                    selected: null,
                    selectedValues: _typesDrogueSelectionnes,
                    multiSelect: true,
                    onSelect: (val) => setState(() {
                      if (!_typesDrogueSelectionnes.add(val)) {
                        _typesDrogueSelectionnes.remove(val);
                      }
                    }),
                  ),
                  _QuestionPage(
                    title: t('qcm_step3_title'),
                    subtitle: t('qcm_step3_subtitle'),
                    options: _frequences,
                    selected: _frequence,
                    onSelect: (val) => setState(() => _frequence = val),
                  ),
                  _QuestionPage(
                    title: t('qcm_step4_title'),
                    subtitle: t('qcm_step4_subtitle'),
                    options: _quantites,
                    selected: _quantite,
                    onSelect: (val) => setState(() => _quantite = val),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _canGoNext ? _next : null,
                child: Text(t(_step == 3 ? 'qcm_finish' : 'qcm_next')),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String? selected;
  final Set<String>? selectedValues;
  final bool multiSelect;
  final ValueChanged<String> onSelect;

  const _QuestionPage({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    this.selectedValues,
    this.multiSelect = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textLight, height: 1.4)),
          const SizedBox(height: 24),
          ...options.map((opt) {
            final isSelected = multiSelect
              ? selectedValues!.contains(opt)
              : opt == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelect(opt),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

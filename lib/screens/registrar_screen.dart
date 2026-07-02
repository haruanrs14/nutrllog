import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/refeicao_model.dart';
import '../providers/auth_provider.dart';
import '../providers/refeicao_provider.dart';
import '../widgets/primary_button.dart';

class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});

  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final _descricaoController = TextEditingController();
  final _picker = ImagePicker();

  File? _fotoCapturada;
  TipoRefeicao _tipoSelecionado = TipoRefeicao.almoco;
  Position? _posicao;
  bool _salvando = false;
  bool _buscandoLocalizacao = false;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _detectarRefeicaoPorHorario();
    _obterLocalizacao();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().usuarioAtual?.uid;
      if (uid != null) {
        context.read<RefeicaoProvider>().carregarPlano(uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FIX: recebe tipo pré-selecionado passado pela home
    if (!_inicializado) {
      _inicializado = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['tipoPreSelecionado'] != null) {
        _tipoSelecionado = args['tipoPreSelecionado'] as TipoRefeicao;
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _detectarRefeicaoPorHorario() {
    final hora = DateTime.now().hour;
    TipoRefeicao tipo;
    if (hora >= 5 && hora < 10) {
      tipo = TipoRefeicao.cafe;
    } else if (hora >= 10 && hora < 15) {
      tipo = TipoRefeicao.almoco;
    } else if (hora >= 15 && hora < 18) {
      tipo = TipoRefeicao.lanche;
    } else {
      tipo = TipoRefeicao.jantar;
    }
    setState(() => _tipoSelecionado = tipo);
  }

  Future<void> _obterLocalizacao() async {
    setState(() => _buscandoLocalizacao = true);
    try {
      bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) return;
      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) return;
      }
      if (permissao == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) setState(() => _posicao = pos);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _buscandoLocalizacao = false);
    }
  }

  Future<void> _tirarFoto() async {
    final foto = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 80, maxWidth: 1080);
    if (foto != null) setState(() => _fotoCapturada = File(foto.path));
  }

  Future<void> _escolherDaGaleria() async {
    final foto = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1080);
    if (foto != null) setState(() => _fotoCapturada = File(foto.path));
  }

  Future<void> _salvar() async {
    if (_fotoCapturada == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Tire uma foto da refeição para continuar.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _salvando = true);

    final auth = context.read<AuthProvider>();
    final uid = auth.usuarioAtual?.uid ?? 'local';

    final refeicao = RefeicaoModel(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      userId: uid,
      tipo: _tipoSelecionado,
      descricao: _descricaoController.text.trim(),
      dataHora: DateTime.now(),
      fotoPath: _fotoCapturada!.path,
      latitude: _posicao?.latitude,
      longitude: _posicao?.longitude,
      localizacaoNome: _posicao != null
          ? '${_posicao!.latitude.toStringAsFixed(4)}, ${_posicao!.longitude.toStringAsFixed(4)}'
          : null,
    );

    await context.read<RefeicaoProvider>().adicionarRefeicao(refeicao);

    if (mounted) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Refeição registrada com sucesso! ✅'),
        backgroundColor: const Color(0xFF2DDDA0).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Registrar refeição',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto ──────────────────────────────────────────────────
              GestureDetector(
                onTap: _tirarFoto,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171726),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _fotoCapturada != null
                          ? const Color(0xFF4080FF)
                          : const Color(0xFF22223A),
                    ),
                    image: _fotoCapturada != null
                        ? DecorationImage(
                            image: FileImage(_fotoCapturada!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: _fotoCapturada == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4080FF)
                                    .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Color(0xFF4080FF), size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text('Toque para fotografar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('ou escolha da galeria',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12)),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tirarFoto,
                      icon: const Icon(Icons.camera_alt_rounded, size: 16),
                      label: const Text('Câmera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4080FF),
                        side: const BorderSide(color: Color(0xFF4080FF)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _escolherDaGaleria,
                      icon: const Icon(Icons.photo_library_rounded,
                          size: 16),
                      label: const Text('Galeria'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade400,
                        side: BorderSide(color: Colors.grey.shade700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Tipo de refeição ──────────────────────────────────────
              const SizedBox(height: 24),
              Text('TIPO DE REFEIÇÃO',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TipoRefeicao.values.map((tipo) {
                  final sel = tipo == _tipoSelecionado;
                  return ChoiceChip(
                    label: Text('${tipo.emoji} ${tipo.label}'),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _tipoSelecionado = tipo),
                    selectedColor: const Color(0xFF4080FF),
                    backgroundColor: const Color(0xFF171726),
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.grey.shade400,
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: sel
                              ? const Color(0xFF4080FF)
                              : const Color(0xFF22223A)),
                    ),
                  );
                }).toList(),
              ),

              // ── Recomendação do nutricionista (fixa, não editável) ──────
              const SizedBox(height: 24),
              Builder(builder: (context) {
                final recomendacao = context
                    .watch<RefeicaoProvider>()
                    .recomendacaoPara(_tipoSelecionado);
                if (recomendacao == null || recomendacao.trim().isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_rounded,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text('RECOMENDAÇÃO DO NUTRICIONISTA',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171726),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF4080FF).withOpacity(0.35)),
                      ),
                      child: Text(
                        recomendacao,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // ── Descrição ─────────────────────────────────────────────
              Text('DESCRIÇÃO (OPCIONAL)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Ex: Arroz, feijão, frango grelhado e salada...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF171726),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade800)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade800)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF4080FF), width: 1.5)),
                ),
              ),

              // ── GPS ───────────────────────────────────────────────────
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF171726),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF22223A)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 16,
                        color: _posicao != null
                            ? const Color(0xFF4080FF)
                            : Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buscandoLocalizacao
                            ? 'Obtendo localização via GPS...'
                            : _posicao != null
                                ? 'GPS: ${_posicao!.latitude.toStringAsFixed(4)}, ${_posicao!.longitude.toStringAsFixed(4)}'
                                : 'Localização não disponível',
                        style: TextStyle(
                            fontSize: 12,
                            color: _posicao != null
                                ? Colors.grey.shade300
                                : Colors.grey.shade600),
                      ),
                    ),
                    if (_buscandoLocalizacao)
                      const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF4080FF))),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              PrimaryButton(
                texto: 'Salvar refeição',
                carregando: _salvando,
                onPressed: _salvar,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

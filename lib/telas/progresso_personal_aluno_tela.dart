import 'package:flutter/material.dart';
import '../tema/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../modelos/progresso.dart';
import '../servicos/firebase_progresso_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class ProgressoPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;
  final String alunoId;
  final String sexo;

  const ProgressoPersonalAlunoTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
    required this.sexo,
  });

  @override
  State<ProgressoPersonalAlunoTela> createState() =>
      _ProgressoPersonalAlunoTelaState();
}

class _ProgressoPersonalAlunoTelaState
    extends State<ProgressoPersonalAlunoTela> {
  final FirebaseProgressoService _service = FirebaseProgressoService();

  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _obsController = TextEditingController();
  final Map<String, TextEditingController> _medidasControllers = {};
  final GlobalKey _graficoKey = GlobalKey();

  String _medidaSelecionada = "Peso";
  final List<String> metricas = [
    "Peso",
    "bracoDireito",
    "bracoEsquerdo",
    "coxaDireita",
    "coxaEsquerda",
    "cintura",
    "quadril",
  ];
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _inicializarCamposMedidas();
  }

  void _inicializarCamposMedidas() {
    final campos = [
      'bracoDireito',
      'bracoEsquerdo',
      'coxaDireita',
      'coxaEsquerda',
      'cintura',
      'quadril',
    ];
    for (var campo in campos) {
      _medidasControllers[campo] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _obsController.dispose();
    for (var c in _medidasControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> _selecionarData(BuildContext context) async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      fieldLabelText: 'Inserir data',
      fieldHintText: 'dd/mm/aaaa',
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppCores.primaria,
              onPrimary: AppCores.sobrePrimaria,
              surface: AppCores.fundo,
              onSurface: AppCores.texto,
            ),
            dialogBackgroundColor: AppCores.fundo,
          ),
          child: child!,
        );
      },
    );
    if (dataEscolhida != null) setState(() => _dataSelecionada = dataEscolhida);
  }

  Future<void> _confirmarCadastroProgresso() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppCores.fundo,
          title: const Text('Confirmar Cadastro',
              style: TextStyle(color: AppCores.primaria)),
          content: const Text(
            'Deseja realmente salvar este progresso?',
            style: TextStyle(color: AppCores.textoSecundario),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.primaria,
                foregroundColor: AppCores.sobrePrimaria,
              ),
              onPressed: () async {
                Navigator.pop(context);
                _cadastrarProgresso();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cadastrarProgresso() async {
    try {
      final peso = double.tryParse(_pesoController.text) ?? 0;
      final altura = double.tryParse(_alturaController.text) ?? 0;
      if (peso <= 0 || altura <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha peso e altura válidos.'),
          backgroundColor: AppCores.primaria,
        ));
        return;
      }
      final medidas = <String, double>{};
      _medidasControllers.forEach((k, v) {
        final val = double.tryParse(v.text);
        if (val != null && val > 0) medidas[k] = val;
      });

      final progresso = Progresso(
        id: FirebaseFirestore.instance.collection('progresso').doc().id,
        alunoId: widget.alunoId,
        sexo: widget.sexo,
        peso: peso,
        altura: altura,
        medidas: medidas,
        imagemUrl: null,
        observacoes: _obsController.text,
        data: _dataSelecionada,
        criadoEm: DateTime.now(),
      );

      await _service.adicionarProgresso(progresso);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Progresso cadastrado com sucesso!'),
          backgroundColor: AppCores.primaria,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar progresso: $e')),
      );
    }
  }

  void _abrirModalCadastro() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppCores.fundo,
          title: const Text('Registrar Progresso',
              style: TextStyle(color: AppCores.primaria)),
          content: _formulario(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _confirmarCadastroProgresso,
              style: ElevatedButton.styleFrom(backgroundColor: AppCores.primaria),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget _formulario() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Data da Medição:',
                style: TextStyle(color: AppCores.primaria)),
            TextButton.icon(
              onPressed: () => _selecionarData(context),
              icon: const Icon(Icons.calendar_today, color: AppCores.primaria),
              label: Text(
                "${_dataSelecionada.day.toString().padLeft(2, '0')}/"
                    "${_dataSelecionada.month.toString().padLeft(2, '0')}/"
                    "${_dataSelecionada.year}",
                style: const TextStyle(color: AppCores.texto),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pesoController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppCores.texto),
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
            labelStyle: TextStyle(color: AppCores.primaria),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _alturaController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppCores.texto),
          decoration: const InputDecoration(
            labelText: 'Altura (m)',
            labelStyle: TextStyle(color: AppCores.primaria),
          ),
        ),
        const SizedBox(height: 8),
        ..._medidasControllers.entries.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: e.value,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppCores.texto),
              decoration: InputDecoration(
                labelText: '${e.key} (cm)',
                labelStyle: const TextStyle(color: AppCores.primaria),
              ),
            ),
          ),
        ),
        TextField(
          controller: _obsController,
          maxLines: 2,
          style: const TextStyle(color: AppCores.texto),
          decoration: const InputDecoration(
            labelText: 'Observações',
            labelStyle: TextStyle(color: AppCores.primaria),
          ),
        ),
      ],
    ),
  );
  void _abrirModalAtualizar(String id, Map<String, dynamic> data) {
    _pesoController.text = (data['peso'] ?? '').toString();
    _alturaController.text = (data['altura'] ?? '').toString();
    _obsController.text = data['observacoes'] ?? '';
    _dataSelecionada =
        DateTime.tryParse(data['data'] ?? '') ?? DateTime.now();
    final medidas = Map<String, dynamic>.from(data['medidas'] ?? {});
    for (final campo in _medidasControllers.keys) {
      _medidasControllers[campo]?.text = (medidas[campo] ?? '').toString();
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppCores.fundo,
          title: const Text('Editar Progresso',
              style: TextStyle(color: AppCores.primaria)),
          content: _formulario(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => _confirmarExcluir(id),
              child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () => _confirmarAtualizacao(id),
              style: ElevatedButton.styleFrom(backgroundColor: AppCores.primaria),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarAtualizacao(String id) async {
    final doc = await FirebaseFirestore.instance.collection('progresso').doc(id).get();
    final antigo = doc.data() ?? {};
    final medidasAtuais = Map<String, dynamic>.from(antigo['medidas'] ?? {});
    final medidasNovas = <String, double>{};

    _medidasControllers.forEach((k, v) {
      final valor = double.tryParse(v.text);
      if (valor != null && valor > 0) medidasNovas[k] = valor;
    });

    final mudou = (double.tryParse(_pesoController.text) ?? 0) != (antigo['peso'] ?? 0) ||
        (double.tryParse(_alturaController.text) ?? 0) != (antigo['altura'] ?? 0) ||
        _obsController.text.trim() != (antigo['observacoes'] ?? '') ||
        medidasNovas.toString() != medidasAtuais.toString() ||
        _dataSelecionada.toIso8601String() != (antigo['data'] ?? '');

    if (!mudou) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nenhuma alteração detectada.'),
        backgroundColor: AppCores.primaria,
      ));
      Navigator.pop(context);
      return;
    }

    await FirebaseFirestore.instance.collection('progresso').doc(id).update({
      'peso': double.tryParse(_pesoController.text) ?? 0,
      'altura': double.tryParse(_alturaController.text) ?? 0,
      'observacoes': _obsController.text.trim(),
      'medidas': medidasNovas,
      'data': _dataSelecionada.toIso8601String(),
      'atualizadoEm': DateTime.now().toIso8601String(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Progresso atualizado com sucesso!'),
      backgroundColor: AppCores.primaria,
    ));
  }

  Future<void> _confirmarExcluir(String id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppCores.fundo,
        title: const Text('Excluir Progresso',
            style: TextStyle(color: Colors.redAccent)),
        content: const Text('Deseja realmente excluir este registro?',
            style: TextStyle(color: AppCores.textoSecundario)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: AppCores.sobrePrimaria),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('progresso').doc(id).delete();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Progresso excluído com sucesso!'),
                backgroundColor: AppCores.primaria,
              ));
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _gerarRelatorioPDF(List<QueryDocumentSnapshot> docs) async {
    try {
      
      RenderRepaintBoundary boundary =
      _graficoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? graficoBytes = byteData?.buffer.asUint8List();

    
      final pdf = pw.Document();
      final aluno = widget.nomeAluno;
      final dataGeracao = DateTime.now();

      
      final logo = await imageFromAssetBundle('imagens/logo_azul.png');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    height: 50,
                    width: 50,
                    child: pw.Image(logo),
                  ),
                  pw.Text(
                    "Relatório de Progresso",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF0D47A1),
                    ),
                  ),
                  pw.SizedBox(width: 50), 
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromInt(0xFF0D47A1), thickness: 1.5),
              pw.SizedBox(height: 8),

              pw.Text("Aluno: $aluno",
                  style: const pw.TextStyle(fontSize: 14)),
              pw.Text(
                  "Data de geração: ${dataGeracao.day}/${dataGeracao.month}/${dataGeracao.year}",
                  style: const pw.TextStyle(fontSize: 12)),

              if (graficoBytes != null) ...[
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Image(pw.MemoryImage(graficoBytes),
                      width: 400, height: 200, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text("Evolução do aluno",
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      )),
                ),
              ],
              pw.SizedBox(height: 16),

             
              ...docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final medidas = Map<String, dynamic>.from(data['medidas'] ?? {});
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColor.fromInt(0xFF1565C0)),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "📅 ${DateTime.parse(data['data']).day.toString().padLeft(2, '0')}/${DateTime.parse(data['data']).month.toString().padLeft(2, '0')}/${DateTime.parse(data['data']).year}",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF0D47A1),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text("Peso: ${data['peso']} kg"),
                      ...medidas.entries.map(
                            (m) => pw.Text("${m.key}: ${m.value} cm",
                            style: const pw.TextStyle(fontSize: 11)),
                      ),
                      if (data['observacoes'] != null &&
                          data['observacoes'].toString().isNotEmpty)
                        pw.Text("Obs: ${data['observacoes']}",
                            style: pw.TextStyle(
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColors.grey700,
                            )),
                    ],
                  ),
                );
              }),
            ];
          },
        ),
      );

     
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao gerar PDF: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        title: Text("Progresso de ${widget.nomeAluno}"),
        backgroundColor: AppCores.fundo,
        foregroundColor: AppCores.primaria,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('progresso')
            .where('alunoId', isEqualTo: widget.alunoId)
            .orderBy('data', descending: false)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppCores.primaria));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum progresso cadastrado ainda.',
                  style: TextStyle(color: AppCores.texto)),
            );
          }

          final docs = snap.data!.docs;
          final ultimo = docs.last.data() as Map<String, dynamic>;
          final ultimaData = DateTime.tryParse(
              ultimo['atualizadoEm'] ?? ultimo['data'] ?? '') ??
              DateTime.now();

          final List<FlSpot> pontos = [];
          final List<String> labelsDatas = [];

          for (int i = 0; i < docs.length; i++) {
            final d = docs[i].data() as Map<String, dynamic>;
            final dataR =
                DateTime.tryParse(d['data'] ?? '') ?? DateTime.now();
            labelsDatas.add("${dataR.day}/${dataR.month}");
            if (_medidaSelecionada == "Peso") {
              pontos.add(FlSpot(i.toDouble(), (d['peso'] ?? 0).toDouble()));
            } else {
              final medidas = Map<String, dynamic>.from(d['medidas'] ?? {});
              final chave = _medidaSelecionada;
              final valor = medidas[chave] ?? 0;
              pontos.add(FlSpot(i.toDouble(), (valor as num).toDouble()));
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Última atualização: ${ultimaData.day}/${ultimaData.month}/${ultimaData.year}",
                      style: const TextStyle(
                          color: AppCores.primaria,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCores.primaria,
                        foregroundColor: AppCores.sobrePrimaria,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _abrirModalCadastro,
                      icon: const Icon(Icons.add),
                      label: const Text("Novo Progresso"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCores.primaria,
                    foregroundColor: AppCores.sobrePrimaria,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final snapData = await FirebaseFirestore.instance
                        .collection('progresso')
                        .where('alunoId', isEqualTo: widget.alunoId)
                        .orderBy('data', descending: false)
                        .get();
                    if (snapData.docs.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text(
                            'Nenhum progresso encontrado para exportar.'),
                        backgroundColor: AppCores.primaria,
                      ));
                      return;
                    }
                    await _gerarRelatorioPDF(snapData.docs);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Exportar Relatório em PDF"),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppCores.primaria,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Row(
                      children: [
                        const Icon(Icons.stacked_line_chart, color: AppCores.sobrePrimaria),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _medidaSelecionada,
                            isExpanded: true,
                            dropdownColor: AppCores.fundo,
                            iconEnabledColor: AppCores.sobrePrimaria,
                            style: const TextStyle(color: AppCores.texto),

                            items: metricas.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: const TextStyle(color: AppCores.texto),
                                ),
                              );
                            }).toList(),

                            onChanged: (valor) {
                              setState(() => _medidaSelecionada = valor!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                RepaintBoundary(
                  key: _graficoKey,
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: AppCores.primaria, width: 1)),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Text(
                                    v.toStringAsFixed(0),
                                    style: const TextStyle(
                                        color: AppCores.textoSecundario, fontSize: 12))),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx < 0 || idx >= labelsDatas.length) {
                                  return const SizedBox();
                                }
                                return Text(labelsDatas[idx],
                                    style: const TextStyle(
                                        color: AppCores.textoSecundario, fontSize: 10));
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: pontos,
                            isCurved: true,
                            color: AppCores.primaria,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final medidas =
                    Map<String, dynamic>.from(d['medidas'] ?? {});
                    return Card(
                      color: AppCores.superficie,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📅 ${DateTime.parse(d['data']).day.toString().padLeft(2, '0')}/${DateTime.parse(d['data']).month.toString().padLeft(2, '0')}/${DateTime.parse(d['data']).year}',
                              style: const TextStyle(
                                  color: AppCores.primaria, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text('Peso: ${d['peso']} kg',
                                style: const TextStyle(color: AppCores.texto)),
                            ...medidas.entries.map((m) => Text(
                              '${m.key}: ${m.value} cm',
                              style: const TextStyle(color: AppCores.textoSecundario),
                            )),
                            if (d['observacoes'] != null &&
                                d['observacoes'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Obs: ${d['observacoes']}',
                                    style: const TextStyle(
                                        color: AppCores.textoSecundario,
                                        fontStyle: FontStyle.italic)),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final id = docs[i].id;
                                  _abrirModalAtualizar(id, d);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppCores.primaria,
                                  foregroundColor: AppCores.sobrePrimaria,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text("Editar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _botaoFiltro(String tipo) {
    final ativo = _medidaSelecionada == tipo;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _medidaSelecionada = tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? AppCores.primaria : AppCores.superficieAlta,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: ativo ? AppCores.primaria : AppCores.borda,
              width: 1.2,
            ),
          ),
          child: Text(
            tipo,
            style: TextStyle(
              color: ativo ? AppCores.sobrePrimaria : AppCores.texto,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Paleta central do FLL. Para mudar a identidade visual, altere aqui.
class AppCores {
  AppCores._();

  // Cor principal (azul) e variações
  static const primaria = Color(0xFF1565C0);
  static const primariaClara = Color(0xFFBBDEFB);
  static const primariaEscura = Color(0xFF0D47A1);

  // Conteúdo sobre a cor principal (textos/ícones em botões e cartões azuis)
  static const sobrePrimaria = Colors.white;
  static const sobrePrimariaSuave = Colors.white70;

  // Fundos
  static const fundo = Colors.white;
  static const superficie = Color(0xFFF1F5FB); // cartões e listas
  static const superficieAlta = Color(0xFFE2EAF5); // cartões em destaque, campos
  static const borda = Color(0xFFB8C6D9);

  // Textos sobre o fundo branco
  static const texto = Color(0xFF16233A);
  static const textoSecundario = Color(0xB316233A); // 70%
  static const textoSuave = Color(0x8A16233A); // 54%
  static const textoFraco = Color(0x6116233A); // 38%
  static const divisor = Color(0x1F16233A); // 12%
}

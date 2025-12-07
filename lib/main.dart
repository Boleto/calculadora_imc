import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    const ProviderScope(),
  );
}

/// ProviderScope: um wrapper simples usando BlocProvider
class ProviderScope extends StatelessWidget {
  const ProviderScope({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ImcCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
        ),
        home: const Home(),
      ),
    );
  }
}

/// Cubit do IMC
class ImcCubit extends Cubit<String> {
  ImcCubit() : super('Informe seus dados!');

  void calcular(double peso, double alturaCm) {
    try {
      final h = alturaCm / 100;
      final imc = peso / (h * h);

      String result;
      if (imc < 18.6) {
        result = 'Abaixo do peso (IMC = ${imc.toStringAsPrecision(3)})';
      } else if (imc < 24.9) {
        result = 'Peso ideal (IMC = ${imc.toStringAsPrecision(3)})';
      } else if (imc < 29.9) {
        result = 'Sobrepeso (IMC = ${imc.toStringAsPrecision(3)})';
      } else if (imc < 34.9) {
        result = 'Obesidade grau I (IMC = ${imc.toStringAsPrecision(3)})';
      } else if (imc < 39.9) {
        result = 'Obesidade grau II (IMC = ${imc.toStringAsPrecision(3)})';
      } else {
        result = 'Obesidade grau III (IMC = ${imc.toStringAsPrecision(3)})';
      }

      emit(result);
    } catch (_) {
      emit('Valores inválidos');
    }
  }

  void reset() => emit('Informe seus dados!');
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  final pesoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();

  @override
  void dispose() {
    pesoCtrl.dispose();
    alturaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImcCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de IMC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              cubit.reset();
              pesoCtrl.clear();
              alturaCtrl.clear();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person, size: 120, color: Colors.amber),

              /// Peso
              TextFormField(
                controller: pesoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                ],
                validator: (v) => v == null || v.isEmpty ? 'Informe seu peso' : null,
              ),
              const SizedBox(height: 12),

              /// Altura com máscara (only digits)
              TextFormField(
                controller: alturaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) => v == null || v.isEmpty ? 'Informe sua altura' : null,
              ),
              const SizedBox(height: 20),

              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    cubit.calcular(
                      double.parse(pesoCtrl.text),
                      double.parse(alturaCtrl.text),
                    );
                  }
                },
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),

              BlocBuilder<ImcCubit, String>(
                builder: (_, state) => Text(
                  state,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

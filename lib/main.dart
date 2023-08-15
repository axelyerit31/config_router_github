import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// onWebViewCreated y onLoadPage se ejecutan cada vez que la
// pagina carga, hay que manejar que se ejecuta con un bool

void main() {
  runApp(const MyApp());
}

int contadorCargas = 0;

double sHeight = 0;
double sWidth = 0;

// PASSWORD PARA ACCEDER A LA APP
String passwordApp = "";

TextEditingController passwordController = TextEditingController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("QR Scanner"),
        ),
        body: Center(
          child: SizedBox(
            width: sWidth * 4 / 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Ingresar contraseña:"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(
                        10), // Bordes redondeados con radio de 10
                  ),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.grey[400]),
                      hintText: "Contraseña",
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.all(10),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      if (passwordController.text == passwordApp) {
                        passwordController.clear();
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const RouterScreen(),
                          ),
                        );
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  "Error",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                                content: const Text(
                                  "Contraseña incorrecta.",
                                ),
                              );
                            });
                      }
                    },
                    child: const Text("Comprobar"))
              ],
            ),
          ),
        ));
  }
}

class RouterScreen extends StatefulWidget {
  const RouterScreen({super.key});

  @override
  State<RouterScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RouterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Configurar Router"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Con internet:"),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 40,
                  width: 155,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/unchecked.png"))),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Sin internet:"),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 40,
                  width: 150,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/checked.png"))),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 500,
              child: InAppWebView(
                // ===============================================
                // AQUI VA EL LINK PARA ACCEDER AL MODEM O ROUTER
                // ===============================================
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        'http://192.168.18.1')), // URL de la página web

                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(),
                ),

                // ===============================================
                // AQUI VA EL CODIGO JAVASCRIPT PARA INTERACTUAR CON LA PAGINA
                // ===============================================
                onLoadStop: (controller, url) {
                  contadorCargas += 1;
                  print(
                      "----- Pagina cargada, carga numero $contadorCargas -----");

                  if (contadorCargas == 1) {
                    // AQUI EL CODIGO PARA HACER EL LOGIN

                    print("\n\nHaciendo el login");
                    controller.evaluateJavascript(source: '''
                    // Aquí puedes ejecutar código JavaScript una vez que la página web se haya cargado completamente
                    document.getElementById('txt_Username').value = 'usuario del modem';
                    document.getElementById('txt_Password').value = 'clave del modem';
                    document.getElementById('loginbutton').click();
                    ''');

                    // AQUI EL CODIGO PARA INTERACTUAR CON LA PAGINA
                    // Le puse una espera de 2 segundos para que la pagina termine de cargar el login

                    Future.delayed(const Duration(seconds: 2), () {
                      print("\n\nIniciando interaccion");
                      controller.evaluateJavascript(source: '''
                        document.getElementById('name_addconfig').click();
                        setTimeout(function() {
                          document.getElementById('name_securityconfig').click();
                          setTimeout(function() {
                            document.getElementById('macfilter').click();
                              setTimeout(function() {
                                // document.getElementById('EnableMacFilter').click();
                              }, 6000);
                          }, 2000);
                        }, 2000);
                      ''');
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

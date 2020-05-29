import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadopago/utils/globals.dart' as globals;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {

    super.initState();

     const channelMercadoPagoResposta = const MethodChannel( "matheus.com/mercadoPagoResposta" );

      channelMercadoPagoResposta.setMethodCallHandler( ( MethodCall call ) async {

          switch ( call.method ) {
            case 'mercadoPagoOK':

              var idPago = call.arguments[0];
              var status = call.arguments[1];
              var statusDetails = call.arguments[3];

              return mercadoPagoOK( idPago, status, statusDetails );
            
            case 'mercadoPagoErro':
          
              var erro = call.arguments[0];
              return mercadoPagoErro( erro );
          
          }
      });
      
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeScreen();
  }

  _buildHomeScreen() {
    return Scaffold(

      appBar: AppBar( title: Text(  "Mercado Pago"  ) ),
      body: Center(

        child: CupertinoButton(

          child: Text( 'Comprar com Mercado Pago', style: TextStyle( color: Colors.white )  ),

          color: Colors.black45,

          onPressed: () async {

            _criaPreferencia().then( ( result ) {

              if ( result != null ) {

                var preferenceID = result['response']['id'];

                try {

                  const channelMercadoPago = const MethodChannel( "matheus.com/mercadoPago" );
                  final response = channelMercadoPago.invokeMethod( "mercadoPago", 
                  
                  <String, dynamic> {
                      "publicKey": globals.mpTESTPublicKey,
                      "preferenceID": preferenceID
                  });

                  print( "oooi: $response" );

                } on PlatformException  catch ( error ) {
                  print(error.message);
                }

              }

            });

          },
        ),

      ),

    );
  }

  Future<Map<String, dynamic>> _criaPreferencia() async {

    var mp = MP( globals.mpClientID, globals.mpClientSecret );

    var preference = {
      "items": [
        {
          "title": "Test",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": 10.4
        }
      ],

      "payer": {
        "name": "Matheus",
        "email": "mathew.mfranco@gmail.com" 
      },

      "payment_methods": { 
        "excluded_payment_types": [
          { "id": "ticket" },
          { "id": "atm" }
        ]

       }
  
    };

    var result = await mp.createPreference(preference);

    return result;
  }


   void mercadoPagoOK( idPago, status, statusDetails ) {
     print( "idPago: $idPago" );
     print( "status: $status" );
     print( "statusDetails: $statusDetails" );
   }  
   
    void mercadoPagoErro( erro ) {
     print( "erro: $erro" );
   }

}

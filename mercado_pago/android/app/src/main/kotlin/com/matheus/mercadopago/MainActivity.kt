package com.matheus.mercadopago

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import com.mercadopago.android.px.core.MercadoPagoCheckout
import com.mercadopago.android.px.model.Payment
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    private val REQUEST_CODE = 1
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initFlutterChannels()
    }

    private fun initFlutterChannels() {

        val channelMercadoPago = MethodChannel( flutterView, "matheus.com/mercadoPago" )


        channelMercadoPago.setMethodCallHandler { call, result ->

            val args = call.arguments as HashMap<String, Any>
            val publicKey = args["publicKey"] as String
            val preferenceID = args["preferenceID"] as String

            when( call.method ) {
                "mercadoPago" -> mercadoPago( publicKey, preferenceID, result )
                else -> return@setMethodCallHandler
            }
        }

    }

    private fun mercadoPago( publicKey: String, preferenceID: String, channelResult: MethodChannel.Result ) {
        MercadoPagoCheckout.Builder( publicKey, preferenceID ).build().startPayment(this@MainActivity, REQUEST_CODE )
    }

   4 override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        val channelMercadoPagoResposta = MethodChannel( flutterView, "matheus.com/mercadoPagoResposta" )

        if ( resultCode == MercadoPagoCheckout.PAYMENT_RESULT_CODE ) {

            val payment = data!!.getSerializableExtra( MercadoPagoCheckout.EXTRA_PAYMENT_RESULT ) as Payment
            val paymentStatus = payment.paymentStatus
            val paymentStatusDetails = payment.paymentStatusDetail
            val paymentID = payment.id

            val arrayList = ArrayList<String>()
            arrayList.add( paymentID.toString() )
            arrayList.add( paymentStatus )
            arrayList.add( paymentStatusDetails )

            channelMercadoPagoResposta.invokeMethod( "mercadoPagoOK", arrayList )

        }
        else if ( resultCode == Activity.RESULT_CANCELED ) {

            val arrayList = ArrayList<String>()
            arrayList.add( "pagoErro" )
            channelMercadoPagoResposta.invokeMethod( "mercadoPagoErro", arrayList )

        }
        else {

            val arrayList = ArrayList<String>()
            arrayList.add( "pagoCancelado" )
            channelMercadoPagoResposta.invokeMethod( "mercadoPagoErro", arrayList )

        }
    }

}

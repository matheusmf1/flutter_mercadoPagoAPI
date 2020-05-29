import UIKit
import Flutter
import MercadoPagoSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PXLifeCycleProtocol {
    
    var flutterVC: FlutterViewController!
    var navigationController: UINavigationController?
    var channelMercadoPago: FlutterMethodChannel!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    flutterVC = window?.rootViewController as? FlutterViewController
    navigationController = UINavigationController( rootViewController: flutterVC )
    window?.rootViewController = navigationController
    navigationController?.navigationBar.isHidden = true
    
    channelMercadoPago = FlutterMethodChannel( name: "matheus.com/mercadoPago", binaryMessenger: flutterVC.binaryMessenger )
    
    initMethodChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func initMethodChannel() {
        channelMercadoPago.setMethodCallHandler { [unowned self] ( methodCall, result ) in
            
            if let args = methodCall.arguments as? Dictionary<String, Any>,
            let publicKey = args["publicKey"] as? String,
            let preferenceID = args["preferenceID"] as? String {
                self.mercadoPago( publicKey: publicKey, preferenceID: preferenceID, result: result )
            }
       }
    }
    
    
    private func adaptarMercadoPago( start: Bool ) {
        
        if ( start ) {
            
            navigationController?.navigationBar.isHidden = false
            
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            navigationController?.navigationBar.isHidden = true
            
        }
        
        
    }
    
    
    private func mercadoPago( publicKey: String, preferenceID: String, result: @escaping FlutterResult ) {
        self.adaptarMercadoPago( start: true )
        
        let checkout = MercadoPagoCheckout.init( builder:
            MercadoPagoCheckoutBuilder.init( publicKey: publicKey, preferenceId: preferenceID ) )
        
        checkout.start( navigationController: self.navigationController!, lifeCycleProtocol: self )
        
    }
    
    func finishCheckout() -> ( ( _ payment: PXResult? ) -> Void ) {
        return ({ ( _ payment: PXResult? ) in
            var idPago: String = ""
            var status: String = ""
            var statusDetails: String = ""
            
            if let delegate = ( payment ) {
                status = delegate.getStatus()
                statusDetails = delegate.getStatusDetail()
                
        
               if let _idPago = ( delegate.getPaymentId() ) {
                   idPago = _idPago
               }
            }
       
            
            let channelMercadoPagoResposta = FlutterMethodChannel( name: "matheus.com/mercadoPagoResposta",
                                                                   binaryMessenger: self.flutterVC.binaryMessenger)
            
            channelMercadoPagoResposta.invokeMethod( "mercadoPagoOK", arguments: [idPago, status, statusDetails])
            self.adaptarMercadoPago( start: false )
        })
    }
    
    func cancelCheckout() -> ( () -> Void )? {
        
        return {
         
            let channelMercadoPagoResposta = FlutterMethodChannel( name: "matheus.com/mercadoPagoResposta",
                                                                             binaryMessenger: self.flutterVC.binaryMessenger)
                      
            channelMercadoPagoResposta.invokeMethod( "mercadoPagoErro", arguments: ["pagoCancelado"])
            self.adaptarMercadoPago( start: false )
        }
    }
}

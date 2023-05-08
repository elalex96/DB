-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-04-2021  
-- Description: consultar detalle de la factura de mercadeo
-- =============================================  
  
CREATE  PROCEDURE [dbo].[AD_SP_ObtenerDetalleFacturaMercadeo] 
@IdProveedor INT,  
@IdAceptacionPedido INT,
@TipoConsulta NVARCHAR(MAX)
AS  
 BEGIN  
  SET NOCOUNT ON  

  IF @TipoConsulta='CONSULTAR_DETALLE'
  BEGIN 

    
	-->OBTENER DETALLE DE LA FACTURA SOLICITADA FILTRADA POR ACEPTACIÓN ID Y POR PROVEEDOR DE COMPRAS (OPERADORA-RECEPTOR DE LA FACTURA)
	  
	SELECT  
    AF.IdAceptacionPedido,  
    PE.IdPedido,  
    O.FechaRegistro,  
    CONCAT(PR.RazonSocial,ISNULL(' '+PR.RegimenCapital,'')) AS ProveedorEmisor,  
	CONCAT(PC.RazonSocial,ISNULL(' '+PC.RegimenCapital,'')) AS ProveedorReceptor,
    E.Nombre AS EstatusFactura,  
    E.IdEstatus,  
    O.IdOperacion,  
    PR.IdProveedor,  
    PG.IdPedido AS IdPedidoGeneral,  
    F.IdFactura,    
    TP.TipoPedido,  
    TP.IdTipoPedido,  
    FT.Nombre,  
    TF.Nombre,  
    F.FechaTimbrado,
	F.TipoComprobante,
    ISNULL(F.UUID,'') AS UUID,  
    ISNULL(F.Emisor,'') AS RFC_Emisor,  
    ISNULL(F.Receptor,'') AS RFC_Receptor,
	O.IdOperacion,
	PE.IdContrato,
	PE.IdProveedorCompras,
	AC.NombreAreaContractual AS AreaContractual,
	ISNULL(FA.IdFactura,0) AS IdFacturaAdinco
    FROM MM_AceptacionFactura AS AF  
        JOIN FI_Factura AS F  
            ON AF.IdFactura   =  F.IdFactura 
        JOIN TA_Operacion AS O  
            ON AF.IdAceptacionFactura   =O.IdDocumento 
        JOIN TA_Tarea AS T  
            ON O.IdOperacion  = T.IdOperacion 
        JOIN TA_Estatus AS E  
            ON O.IdEstatusOperacion   = E.IdEstatus 
        JOIN MM_AceptacionPedido AS AP  
            ON AF.IdAceptacionPedido  =AP.IdAceptacionPedido 
        JOIN MM_Pedido AS PE  
            ON  AP.IdPedido   = PE.IdPedido 
        JOIN MM_Pedidos AS PG  
            ON PE.IdPedido = PG.IdIdentificador  
             AND PG.IdProveedorCliente = @IdProveedor  
			 AND PG.IdTipoPedido  IN ( 2, 4, 6 ) 
        JOIN S_Proveedor AS PR  
            ON PE.IdSubcontratista   = PR.IdProveedor 
		JOIN S_Proveedor AS PC  
            ON PE.IdProveedorCompras  = PC.IdProveedor  
        LEFT JOIN dbo.MM_TipoPedido AS TP  
            ON PG.IdTipoPedido   = TP.IdTipoPedido 
		LEFT JOIN dbo.TA_FlujoTarea FT 
			ON  O.IdFlujoTarea   = FT.IdFlujoTarea
		LEFT JOIN dbo.TA_TipoFlujoTarea TF 
			ON FT.IdTipoFlujo   = TF.IdTipoFlujoTarea		
		LEFT JOIN Adinco.dbo.CO_Contrato AS C  
			ON PE.IdContrato = C.IdContrato 
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  
			ON C.IdAreaContractual = AC.IdAreaContractual 
		LEFT JOIN Adinco.dbo.FI_Factura  AS FA 
			ON  F.UUID = FA.UUID  COLLATE SQL_Latin1_General_CP1_CI_AS 
    WHERE O.IdTipoOperacion = 10  --> APROBACIÓN DE TIPO FACTURA  	 
          AND PE.IdProveedorCompras = @IdProveedor  
          AND AF.IdAceptacionPedido =@IdAceptacionPedido ---> 441  
    GROUP BY               
            AF.IdAceptacionPedido,  
			PE.IdPedido,  
			O.FechaRegistro,  
			PR.RazonSocial,  
			PC.RazonSocial,
			E.Nombre,  
			E.IdEstatus,  
			O.IdOperacion,  
			PR.IdProveedor,  
			PG.IdPedido,  
			F.IdFactura,    
			TP.TipoPedido,  
			TP.IdTipoPedido,  
			FT.Nombre,  
			TF.Nombre,  
			F.FechaTimbrado,
			F.TipoComprobante,
			F.UUID,  
			F.Emisor,  
			F.Receptor,  			
			O.IdOperacion,
			PE.IdContrato,
			PE.IdProveedorCompras,
			AC.NombreAreaContractual,
			FA.IdFactura,
			PR.RegimenCapital,
			PC.RegimenCapital
  END    

  IF @TipoConsulta='CONSULTAR_PROVEEDORES'
  BEGIN 

	  SELECT     
	  PR.IdProveedor,
	  CONCAT(PR.RazonSocial,ISNULL(' '+PR.RegimenCapital,''))  AS RazonSocial 
      FROM MM_AceptacionFactura AS AF 
        JOIN MM_AceptacionPedido AS AP  
            ON AF.IdAceptacionPedido  =AP.IdAceptacionPedido 
        JOIN MM_Pedido AS PE  
            ON AP.IdPedido = PE.IdPedido
        JOIN S_Proveedor AS PR  
            ON PE.IdProveedorCompras = PR.IdProveedor 
      GROUP BY PR.RazonSocial,PR.RegimenCapital, PR.IdProveedor        
            

  END 
  
 END



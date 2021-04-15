USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ObtenerDetalleAprobacionCompraDirecta'
)
    DROP PROCEDURE AD_SP_ObtenerDetalleAprobacionCompraDirecta;
GO 
/****** Object:  StoredProcedure [dbo].[p_EN_ObtenerDocumentosEntregables]    Script Date: 10/03/2021 05:58:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author: Daniel AC
-- Create date: <05/04/2021>  
-- Description: <Consulta a detalle de una compra directa de Procura>  
-- =============================================   
CREATE PROCEDURE [dbo].[AD_SP_ObtenerDetalleAprobacionCompraDirecta] 
	@ProveedorId INT,
	@NumCompraDirecta INT  
AS
BEGIN
		
		  SELECT 
				O.IdOperacion,   
                O.IdDocumento,
				R.IdRegistro, 
				PG.IdPedido AS IdPedidoGeneral, 
				 E.Nombre AS Estatus,       
                U.Nombre AS NombreAsignador,   
                O.IdEstatusOperacion AS IdEstatus,   
                O.IdFlujoTarea, 
                T.IdEstatus,   
                O.FechaRegistro,   
                O.Descripcion,
                f.Moneda,
				P.RazonSocial AS ProveedorReceptor,
				PE.RazonSocial AS ProveedorEmisor,
				O.IdProveedor AS ProveedorOperadorId,
				AC.NombreAreaContractual AS AreaContractual,
				F.IdFactura,
				F.IdContrato,
				O.IdProveedor  --> Proveedor de procura
         FROM TA_Operacion AS O  
               JOIN S_Proveedor AS P 
					ON P.IdProveedor			=	O.IdProveedor  
               JOIN S_UsuarioProveedor AS US 
					ON US.IdProveedor			=	P.IdProveedor  
               JOIN S_Usuario AS U 
					ON U.IdUsuario				=	O.IdAsignador  
               JOIN MM_Pedidos PG 
					ON PG.IdIdentificador		=	O.IdDocumento  
                        AND PG.IdTipoPedido		=	1  --> COMPRA DIRECTA
                        AND O.IdProveedor		=	PG.IdProveedorCliente  --> EL PROVEEDOR DE LA OPERADORA
               JOIN dbo.TA_Tarea T 
					ON T.IdOperacion			=	O.IdOperacion  
               JOIN TA_Estatus AS E 
					ON E.IdEstatus				=	T.IdEstatus  
               JOIN FI_Factura AS f 
					ON f.IdFactura				=	PG.IdIdentificador  
			   JOIN CO_Registro AS R 
					ON f.IdFactura				=	r.IdFactura
			   LEFT JOIN S_Proveedor AS PE 
					ON F.Emisor					=	PE.RFC
	           LEFT JOIN Adinco.dbo.CO_Contrato AS C  
					ON F.IdContrato = C.IdContrato 
			    LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  
					ON C.IdAreaContractual = AC.IdAreaContractual  
         WHERE O.IdProveedor= @ProveedorId
		 AND PG.IdPedido =  @NumCompraDirecta
		 AND O.IdTipoOperacion = 14 --> COMPRA DIRECTA
         GROUP BY O.IdOperacion,   
                  O.IdDocumento,   
                  U.Nombre,   
                  O.IdEstatusOperacion,   
                  O.IdFlujoTarea,   
                  E.Nombre,   
                  t.IdEstatus,   
                  O.FechaRegistro,   
                  O.Descripcion,   
                  PG.IdPedido,   
                  f.Moneda,  
				  R.IdRegistro,
				  P.RazonSocial,
				  PE.RazonSocial,
				  AC.NombreAreaContractual,
				  O.IdProveedor,
				  F.IdFactura,
				  	F.IdContrato
END

  
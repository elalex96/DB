USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ObtenerProveedorOperadoraPorTipoOperacion'
)
    DROP PROCEDURE AD_SP_ObtenerProveedorOperadoraPorTipoOperacion;
GO 
/****** Object:  StoredProcedure [dbo].[p_EN_ObtenerDocumentosEntregables]    Script Date: 10/03/2021 05:58:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-04-2021  
-- Description: consultar los aprobadores que tiene el tipo de operacion de entrada   
-- =============================================  
CREATE PROCEDURE [dbo].[AD_SP_ObtenerProveedorOperadoraPorTipoOperacion] 
    @ContratoId INT,
    @UsuarioId INT,
	@Tipo NVARCHAR(MAX)   
AS
BEGIN
		
		IF @Tipo='COMPRA_DIRECTA'
		BEGIN
			SELECT 
			P.IdProveedor,
			P.RazonSocial AS Proveedor 			
			FROM TA_Operacion AS O  
			JOIN S_Proveedor AS P ON O.idproveedor = P.IdProveedor  
			WHERE O.IdTipoOperacion = 14  --> COMPRA DIRECTA
			GROUP BY P.RazonSocial ,  
			P.IdProveedor
			ORDER BY P.RazonSocial ASC  
		END 


		IF @Tipo='COMPROBANTE_DIRECTO'
		BEGIN
			SELECT  
			P.IdProveedor,
			P.RazonSocial AS Proveedor 	
			FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
			  JOIN dbo.FI_PedimentoComprobante AS PC   
			   ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante  
			  JOIN dbo.TA_Operacion AS OP  
			   ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante  
			   AND OP.IdTipoOperacion = 19  --> COMPROBANTE EXTRANJERO DIRECTO
			   AND OP.IdProveedor = APC.IdProveedor  
			   JOIN S_Proveedor P 
			   ON OP.IdProveedor=P.IdProveedor
			GROUP BY P.RazonSocial ,  
			P.IdProveedor
			ORDER BY P.RazonSocial ASC  
		END 

END

  
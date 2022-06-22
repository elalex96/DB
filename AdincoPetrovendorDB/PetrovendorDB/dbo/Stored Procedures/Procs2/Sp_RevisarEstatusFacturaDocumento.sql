USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_RevisarEstatusFacturaDocumento'
)
    DROP PROCEDURE Sp_RevisarEstatusFacturaDocumento;
GO
/****** Object:  StoredProcedure [dbo].[Sp_RevisarEstatusFacturaDocumento]    Script Date: 17/06/2022 02:46:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	Revisa el estatus de la Factura, esto con el fin de saber si se habilita o deshbailita
--				el check de Carta contenido nacional que se encuentra en la aceptacion de pedido detalle
-- =============================================
-- =============================================
-- Author:		Daniel Cruz
-- Update date: 17-06-2022
-- Description:	Se agrega filtro para aceptaciones de proveedores extranjeros 
-- =============================================
CREATE PROCEDURE [dbo].[Sp_RevisarEstatusFacturaDocumento] @IdAceptacionPedido INT
AS
BEGIN

	DECLARE @IsAceptacionExtranjera INT 
	
	SELECT @IsAceptacionExtranjera=IdNacionalidadProveedor
			FROM MM_AceptacionPedido 			
			WHERE IdAceptacionPedido=@IdAceptacionPedido
	
	IF  ISNULL(@IsAceptacionExtranjera,0)=2
	BEGIN 

		-->ACEPTACIONES DE PROVEEDORES EXTRANJEROS

		SELECT 
		CASE WHEN O.IdEstatusOperacion IN (2) THEN 
		1 -- bloquear el btn de Carta Contenido
		ELSE 
		0 -- desbloquear el btn de Carta Contenido
		END 
		FROM
		 dbo.MM_AceptacionPedido AP 		
		 JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 JOIN dbo.FI_PedimentoComprobante PC 
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 JOIN dbo.TA_Operacion O 
			ON PC.IdPedimentoComprobante = O.IdDocumento
			AND O.IdTipoOperacion=16 		 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		 WHERE 	AP.IdAceptacionPedido=@IdAceptacionPedido		  
		 AND ISNULL(PC.IdEstatusEliminado,0)=0 --> NO ESTE ELIMINADO
	  
	END 
	ELSE 
	BEGIN 
	-->ACEPTACIONES DE PROVEEDORES NACIONALES 
    SELECT CASE
               WHEN IdEstatusXML IN ( 1, 2, 3 )
                    OR IdEstatusPDF IN ( 1, 2, 3 ) THEN
                   1 -- bloquear el btn de Carta Contenido
               ELSE
                   0 -- desbloquear el btn de Carta Contenido
           END
    FROM dbo.MM_AceptacionFactura
    WHERE IdAceptacionPedido = @IdAceptacionPedido

	END 

END


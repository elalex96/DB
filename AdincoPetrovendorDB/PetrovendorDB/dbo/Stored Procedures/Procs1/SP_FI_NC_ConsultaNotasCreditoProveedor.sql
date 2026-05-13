USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_FI_NC_ConsultaNotasCreditoProveedor') IS NOT NULL
BEGIN
DROP PROCEDURE SP_FI_NC_ConsultaNotasCreditoProveedor;
END
GO
-- Author:		Luis David De La Cruz
-- Create date: 12/11/2019
-- Description:	Se agrega las notas de crédito para Murphy
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/09/2019
-- Description:	Lista de Notas de Credito
-- =============================================
-- =============================================    
-- Author:           Alexaner Gomez   
-- Create date: 12/09/2025  
-- Description: se agrega filtro por fecha de carga de la aceptación de la factura
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_FI_NC_ConsultaNotasCreditoProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@FechaInicio datetime,
	@FechaFin datetime 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		select
	 AP.IdAceptacionPedido
	 , '' as Descripcion
	 , E.Nombre AS Estatus
	 ,NC.CreadoEl
	 ,UC.Nombre AS CargadoPor
	 ,F.IdFactura
	 ,F.SubTotal
	 ,F.MontoConIva
	 ,NC.IdAceptacionNotaCredito
	 ,0 as IdOperacion
	 ,Null AS FechaCambioEstatus
	 , '' AS ComentarioAprobador
	 ,F.Moneda
	 ,F.UUID
	 ,NC.CFDIRelacionados
	 ,CASE  
			WHEN E.IdEstatus = 2 THEN 'label label-success'  
			WHEN E.IdEstatus = 1 THEN 'label label-primary'  
			WHEN E.IdEstatus = 3 THEN 'label label-danger'  
			WHEN E.IdEstatus IS NULL THEN 'label label-default'  
		   END AS span,
		Murphy = 1,
	CASE  
                   WHEN NC.CreadoEl IS NULL THEN  
                       'Sin cargar'  
                   ELSE  
                       CONVERT(VARCHAR(50), NC.CreadoEl, 103)  
               END AS FechaCargaFactura
from 
	MPY_MM_AceptacionNotaCredito as NC
	join MPY_MM_AceptacionPedido AP on AP.IdAceptacionPedido = NC.IdAceptacionPedido
	join TA_Estatus as E on E.IdEstatus = NC.IdEstatus
	join S_Usuario as UC on NC.CreadoPor = UC.IdUsuario
	join FI_Factura as F on F.IdFactura = NC.IdFacturaNotaCredito
	join adinco..CO_SAPVendor as t2 on t2.VendorIDSAP collate Modern_Spanish_CI_AS= AP.IdSubContratista collate Modern_Spanish_CI_AS
	join S_Proveedor as p on t2.TaxID collate Modern_Spanish_CI_AS= P.RFC collate Modern_Spanish_CI_AS
	where p.IdProveedor = @IdProveedor
	AND NC.CreadoEl BETWEEN @FechaInicio AND @FechaFin
	union
	SELECT 
		   AP.IdAceptacionPedido,
		   O.Descripcion,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,
           NC.IdAceptacionNotaCredito,
           O.IdOperacion,
           O.FechaModificacion AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           F.UUID,
           NC.CFDIRelacionados,
		   CASE  
			WHEN E.IdEstatus = 2 THEN 'label label-success'  
			WHEN E.IdEstatus = 1 THEN 'label label-primary'  
			WHEN E.IdEstatus = 3 THEN 'label label-danger'  
			WHEN E.IdEstatus IS NULL THEN 'label label-default'  
		   END AS span,
		   Murphy = 0,
		   CASE  
                   WHEN NC.CreadoEl IS NULL THEN  
                       'Sin cargar'  
                   ELSE  
                       CONVERT(VARCHAR(50), NC.CreadoEl, 103)  
               END AS FechaCargaFactura
    FROM dbo.MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        LEFT JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
        LEFT JOIN dbo.TA_Operacion O
            ON O.IdDocumento = NC.IdAceptacionNotaCredito
               AND O.IdTipoOperacion = 17 --> APROBACIÓN NOTA DE CREDITO
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
        LEFT JOIN dbo.S_Usuario UC
            ON UC.IdUsuario = NC.CreadoPor
    WHERE P.IdSubcontratista = @IdProveedor
          AND ISNULL(NC.IdEstatusEliminada, 0) = 0
		  AND NC.CreadoEl BETWEEN @FechaInicio AND @FechaFin
    GROUP BY CASE
             WHEN E.IdEstatus = 2 THEN
             'label label-success'
             WHEN E.IdEstatus = 1 THEN
             'label label-primary'
             WHEN E.IdEstatus = 3 THEN
             'label label-danger'
             WHEN E.IdEstatus IS NULL THEN
             'label label-default'
             END,
             AP.IdAceptacionPedido,
             O.Descripcion,
             E.Nombre,
             NC.CreadoEl,
             UC.Nombre,
             F.IdFactura,
             F.SubTotal,
             F.MontoConIva,
             NC.IdAceptacionNotaCredito,
             O.IdOperacion,
             O.FechaModificacion,
             F.Moneda,
             F.UUID,
             NC.CFDIRelacionados,
			 NC.CreadoEl
	ORDER BY NC.CreadoEl DESC


END
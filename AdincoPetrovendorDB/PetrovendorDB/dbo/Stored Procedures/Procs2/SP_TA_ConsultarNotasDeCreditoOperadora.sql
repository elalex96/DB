-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarNotasDeCreditoOperadora]--420,2205,10037
    -- Add the parameters for the stored procedure here
	
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT NC.IdAceptacionPedido,
		   NC.IdAceptacionNotaCredito,	  
		   O.Descripcion,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,          
           O.IdOperacion,
           O.FechaModificacion AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
		   F.Moneda,
		   F.UUID,
		   cast(PG.IdPedido as varchar) AS NoPedido,
		   NC.CFDIRelacionados,
		   Contrato = c.NumeroContrato
		   --IdPedido = isnull(p.IdPedido,0)
    FROM	dbo.MM_AceptacionNotaCredito	NC
	JOIN	dbo.MM_AceptacionPedido			AP
	ON		AP.IdAceptacionPedido			=	NC.IdAceptacionPedido
	JOIN	dbo.MM_Pedido					P
	ON		P.IdPedido						=	AP.IdPedido
	AND		P.IdProveedorCompras			=	@IdProveedor
	JOIN	dbo.MM_Pedidos					PG	
	ON		PG.IdIdentificador				=	P.IdPedido
	AND		PG.IdProveedorCliente			=	P.IdProveedorCompras
	JOIN	dbo.TA_Operacion				O
	ON		O.IdDocumento					=	NC.IdAceptacionNotaCredito
	AND		O.IdTipoOperacion				=	17 --> APROBACIÓN NOTA DE CREDITO
	JOIN	dbo.TA_Estatus					E
	ON		E.IdEstatus						=	O.IdEstatusOperacion
	JOIN	dbo.FI_Factura					F
	ON		F.IdFactura						=	NC.IdFacturaNotaCredito
	JOIN	dbo.S_Usuario					UC
	ON		UC.IdUsuario					=	NC.CreadoPor
	inner JOIN	Adinco.dbo.CO_Contrato		AS	C 	
	ON		c.IdContrato					=	P.IdContrato
    WHERE	ISNULL(NC.IdEstatusEliminada, 0) = 0
	UNION
	SELECT NC.IdAceptacionPedido,
		   NC.IdAceptacionNotaCredito,	  
		   Descripcion= nc.Comentario,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,          
           IdOperacion = 0,
           FechaModificacion = nc.FechaAprobacion,
           nc.Comentario AS ComentarioAprobador,
		   F.Moneda,
		   F.UUID,
		   ap.IdPedido AS NoPedido,
		   NC.CFDIRelacionados,
		   Contrato = c.NumeroContrato
		   --IdPedido = 0
    FROM dbo.MPY_MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MPY_MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
       
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = NC.IdEstatus
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
        LEFT JOIN dbo.S_Usuario UC
            ON UC.IdUsuario = NC.CreadoPor
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	c.IdContrato	=	AP.IdContrato
    WHERE AP.IdContrato = @IdContrato
          AND ISNULL(NC.IdEstatusEliminada, 0) = 0
     GROUP BY --Descripcion,
             E.Nombre,
             NC.CreadoEl,
             UC.Nombre,
             F.IdFactura,
             NC.IdAceptacionNotaCredito,
             --O.IdOperacion,
             F.SubTotal,
             F.MontoConIva,
            -- O.FechaModificacion,
			 F.Moneda,
			 F.UUID,
			 NC.IdAceptacionPedido,
			-- PG.IdPedido,
			 NC.CFDIRelacionados,
			  ap.IdPedido,
			  nc.FechaAprobacion,
			  nc.Comentario,
			  c.IdContrato,
			  c.NumeroContrato
		
		ORDER BY NC.CreadoEl DESC
END;

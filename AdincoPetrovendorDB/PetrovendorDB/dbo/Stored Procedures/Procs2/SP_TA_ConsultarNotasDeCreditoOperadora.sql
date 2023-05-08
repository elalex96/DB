-- ====
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-2023
-- Description:	Se muestra UUID Y FOLIO FACTURA CONSULTAS MURPHY
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
		   F.UUID AS UUID,
		   cast(PG.IdPedido as varchar) AS NoPedido,
		   NC.CFDIRelacionados,
		   Contrato = c.NumeroContrato		  
    FROM	dbo.MM_AceptacionNotaCredito	NC (NOLOCK)
	JOIN	dbo.MM_AceptacionPedido			AP (NOLOCK)
	ON		NC.IdAceptacionPedido			=	AP.IdAceptacionPedido			
	JOIN	dbo.MM_Pedido					P (NOLOCK)
	ON		AP.IdPedido						=	P.IdPedido						
			AND	P.IdProveedorCompras		=	@IdProveedor
	JOIN	dbo.MM_Pedidos					PG	(NOLOCK)
	ON		PG.IdIdentificador				=	P.IdPedido
	AND		PG.IdProveedorCliente			=	P.IdProveedorCompras
	AND		PG.IdTipoPedido					IN (2, 4, 6) -->CTES MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
	JOIN	dbo.TA_Operacion				O (NOLOCK)
	ON		NC.IdAceptacionNotaCredito		=	O.IdDocumento						
	AND		O.IdTipoOperacion				=	17 -->CTE APROBACIÓN NOTA DE CREDITO
	JOIN	dbo.TA_Estatus					E (NOLOCK)
	ON		O.IdEstatusOperacion			=	E.IdEstatus							
	JOIN	dbo.FI_Factura					F (NOLOCK)
	ON		NC.IdFacturaNotaCredito			=	F.IdFactura							
	JOIN	dbo.S_Usuario					UC (NOLOCK)
	ON		NC.CreadoPor					=	UC.IdUsuario					
	JOIN	Adinco.dbo.CO_Contrato		AS	C   (NOLOCK)
	ON		P.IdContrato					=	C.IdContrato				
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
		   CONCAT('Folio: ',ISNULL(F.Folio,'-'), ' - UUID: ', ISNULL(F.UUID,'-')) AS UUID,		  
		   ap.IdPedido AS NoPedido,
		   NC.CFDIRelacionados,
		   Contrato = c.NumeroContrato		  
    FROM dbo.MPY_MM_AceptacionNotaCredito NC
        JOIN dbo.MPY_MM_AceptacionPedido AP
            ON  NC.IdAceptacionPedido	=	AP.IdAceptacionPedido      
		JOIN	Adinco.dbo.CO_Contrato	AS	C 	
			ON	AP.IdContrato				=	C.IdContrato	
        LEFT JOIN dbo.TA_Estatus E
            ON NC.IdEstatus				=	E.IdEstatus 
        LEFT JOIN dbo.FI_Factura F
            ON NC.IdFacturaNotaCredito	=	F.IdFactura 
        LEFT JOIN dbo.S_Usuario UC
            ON NC.CreadoPor				=	UC.IdUsuario 			
    WHERE AP.IdContrato = @IdContrato
          AND ISNULL(NC.IdEstatusEliminada, 0) = 0
     GROUP BY
             E.Nombre,
             NC.CreadoEl,
             UC.Nombre,
             F.IdFactura,
             NC.IdAceptacionNotaCredito,            
             F.SubTotal,
             F.MontoConIva,           
			 F.Moneda,
			 F.UUID,
			 F.Folio,
			 F.Serie,
			 NC.IdAceptacionPedido,			
			 NC.CFDIRelacionados,
			 ap.IdPedido,
			  nc.FechaAprobacion,
			  nc.Comentario,
			  c.IdContrato,
			  c.NumeroContrato		
		ORDER BY NC.CreadoEl DESC
END;

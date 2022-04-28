USE [Petrovendor]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_AceptacionPedidoProveedor'
)
    DROP PROCEDURE SP_PR_MM_AceptacionPedidoProveedor;
GO
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 22-09-20
-- Description:	Se agrega el tipo de pedido a la consulta
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 13/09/2021
-- Description:	SE VALIDA QUE CUANDO SEA UN PROVEEDOR EXTRANGERO MUESTRE QUE NO SOLICITA LA CARTA CN 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedor]
    -- Add the parameters for the stored procedure here  
    @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;

    -- Insert statements for procedure here  

    SELECT PG.IdTipoPedido,
		   AP.IdAceptacionPedido,
           AP.IdPedido,
           AP.Comentario,
           AP.Creado,
           CONCAT(
                     LE.[Calle],
                     ' ',
                     LE.[NoExterior],
                     ' ',
                     LE.[NoInterior],
                     ' ',
                     LE.[Colonia],
                     ' ',
                     LE.[Municipio],
                     ' ',
                     LE.[Estado],
                     ' ',
                     PAIS.pais
                 ) AS LugarEntrega,
           TD.TipoDomicilio,
           CONCAT(P.RazonSocial, ' ', P.RegimenCapital) AS Proveedor,
           PG.IdPedido AS IdPedidoGeneral,
           TP.TipoPedido,
           MP.IdSolicitudPedido,
           CASE
               WHEN ISNULL(RC.PedirCarta, 0) = 0 or ISNULL(P.IdNacionalidad,0) = 2 THEN -- SE AGREGA LA VALIDACIÓN DE QUE CUANDO SEA 
                   'No'																	-- EXTRANJERA O NO ESTÉ EN LA TABLA RelacionCartaCNPedido MUESTRE UN 'NO' 
               WHEN ISNULL(RC.PedirCarta, 0) = 1 THEN
                   'SI'
           END AS PedirCarta,
		   ISNULL(SOT.Objeto,SPO.MotivoUrgencia) AS Justificacion,
		   Contrato = c.NumeroContrato
		FROM
			MM_AceptacionPedido			AS	AP (NOLOCK)
		JOIN
			MM_Pedido					AS	MP	(NOLOCK)
			ON	AP.IdPedido         =   MP.IdPedido		
			AND	AP.IdProveedor		=	@IdProveedor
		JOIN
			MM_Pedidos					AS	PG	(NOLOCK)
			ON	MP.IdPedido					=	PG.IdIdentificador
			AND	PG.IdProveedorCliente		=	@IdProveedor
			AND	PG.IdTipoPedido				IN	(2, 4, 6) --> CTES MERCADEO, ORDER DE TRABAJO Y AD DIRECTA
		JOIN
			S_Proveedor					AS	P	(NOLOCK)
			ON	MP.IdSubcontratista			=	P.IdProveedor				
		JOIN
			DG_Domicilio				AS	LE	(NOLOCK)
			ON	AP.IdDomicilioEntrega		=	LE.IdDomicilio		
		JOIN
			DG_TipoDomicilio			AS	TD	(NOLOCK)
			ON	LE.IdTipoDomicilio			=	TD.IdTipoDomicilio	
		JOIN	Adinco.dbo.CO_Contrato	AS	C	(NOLOCK)
			ON	MP.IdContrato				=	C.IdContrato
		LEFT JOIN
			PV_PaisRepublica			AS	PAIS	(NOLOCK)
			ON	LE.IdPais					=	PAIS.id						
		LEFT JOIN	RelacionCartaCNPedido		RC	(NOLOCK)
			ON		AP.IdAceptacionPedido	=	RC.IdAceptacionPedido		
		LEFT JOIN	dbo.MM_TipoPedido			AS	TP	(NOLOCK)
			ON		PG.IdTipoPedido			=	TP.IdTipoPedido				
		LEFT JOIN	Adinco.dbo.OT_Estimacion	AS	OTS	(NOLOCK)
			ON		MP.IdPedido				=	OTS.IdPedido					
		LEFT JOIN	Adinco.dbo.OT_Solicitud		AS	SOT	(NOLOCK)
			ON		OTS.IdOTSolicitud		=	SOT.IdOTSolicitud		
		LEFT JOIN	dbo.MM_SolicitudPedido		AS	SPO	(NOLOCK)
			ON		MP.IdSolicitudPedido	=	SPO.IdSolicitudPedido	
		WHERE	AP.IdProveedor				=	@IdProveedor
			AND			ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS       
		ORDER BY	IdAceptacionPedido DESC;

END;

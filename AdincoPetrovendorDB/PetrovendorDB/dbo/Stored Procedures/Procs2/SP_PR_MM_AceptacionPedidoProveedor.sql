DROP PROCEDURE IF EXISTS SP_PR_MM_AceptacionPedidoProveedor
go
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 22-09-20
-- Description:	Se agrega el tipo de pedido a la consulta
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 13/09/2021
-- Description:	SE VALIDA QUE CUANDO SEA UN PROVEEDOR EXTRANGERO MUESTRE QUE NO SOLICITA LA CARTA CN 
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
		FROM		MM_AceptacionPedido			AS	AP
		INNER JOIN	MM_Pedido					AS	MP
		ON			MP.IdPedido					=	AP.IdPedido
		INNER JOIN	DG_Domicilio				AS	LE
		ON			LE.IdDomicilio				=	AP.IdDomicilioEntrega
		INNER JOIN	DG_TipoDomicilio			AS	TD
		ON			TD.IdTipoDomicilio			=	LE.IdTipoDomicilio
		LEFT JOIN	PV_PaisRepublica			AS	PAIS
		ON			PAIS.id						=	LE.IdPais
		INNER JOIN	S_Proveedor					AS	P
		ON			P.IdProveedor				=	MP.IdSubcontratista
		INNER JOIN	MM_Pedidos					AS	PG
		ON			MP.IdPedido					=	PG.IdIdentificador
		AND			PG.IdProveedorCliente		=	@IdProveedor
		AND			PG.IdTipoPedido				IN	(2, 4, 6)
		LEFT JOIN	RelacionCartaCNPedido		RC
		ON			RC.IdAceptacionPedido		=	AP.IdAceptacionPedido
		LEFT JOIN	dbo.MM_TipoPedido			AS	TP
		ON			TP.IdTipoPedido				=	PG.IdTipoPedido
		LEFT JOIN	Adinco.dbo.OT_Estimacion	AS	OTS
		ON			OTS.IdPedido				=	MP.IdPedido
		LEFT JOIN	Adinco.dbo.OT_Solicitud		AS	SOT
		ON			SOT.IdOTSolicitud			=	OTS.IdOTSolicitud
		LEFT JOIN	dbo.MM_SolicitudPedido		AS	SPO
		ON			SPO.IdSolicitudPedido		=	MP.IdSolicitudPedido
		inner JOIN	Adinco.dbo.CO_Contrato		AS	C 
		ON			MP.IdContrato				=	C.IdContrato
		WHERE		AP.IdProveedor				=	@IdProveedor
        AND			ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS       
		ORDER BY	IdAceptacionPedido DESC;

END;

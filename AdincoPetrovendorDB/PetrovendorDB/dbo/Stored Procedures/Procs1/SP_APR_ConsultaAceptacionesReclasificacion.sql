-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <18/04/2020>
-- Description:	<consulta de las aceptaciones de pedido para reclasificacion>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/06/2020>
-- Description:	<se agrego el campo de justificacion de las OT y procesos de procura>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_APR_ConsultaAceptacionesReclasificacion] --617,3,0,1,''
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
	@Page INT,
	@Buscar NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (SELECT 
							COUNT(1)
						FROM MM_AceptacionPedido AS AP
							INNER JOIN MM_Pedido AS MP
								ON MP.IdPedido = AP.IdPedido
							INNER JOIN MM_Pedidos AS PG
									ON MP.IdPedido = PG.IdIdentificador
									   AND PG.IdProveedorCliente = @IdProveedor
							LEFT JOIN dbo.MM_AceptacionFactura AS AF
								ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
							LEFT JOIN dbo.TA_Operacion AS OP
								ON OP.IdDocumento = AF.IdAceptacionFactura
									AND OP.IdTipoOperacion = 10
							LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS
								ON OTS.IdPedido = MP.IdPedido
							LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT
								ON SOT.IdOTSolicitud = OTS.IdOTSolicitud
							LEFT JOIN dbo.MM_SolicitudPedido AS SP
								ON SP.IdSolicitudPedido = MP.IdSolicitudPedido
							--LEFT JOIN dbo.MM_AceptacionCartaPCN APC
							--	ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
						WHERE AP.IdProveedor = @IdProveedor
							AND (OP.IdEstatusOperacion = 1 OR OP.IdEstatusOperacion IS NULL)
							AND (
								CAST(AP.IdAceptacionPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
								--AP.Comentario LIKE '%' + @Buscar + '%' OR
								CAST(MP.IdSolicitudPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
								CAST(PG.IdPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
								SOT.Objeto LIKE '%' + @Buscar + '%'OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%'
							)
							  AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
							  --AND APC.IdAceptacionPedido IS NULL
							  );

	SELECT
		*,
		@AllRecords AS Records,
		@RecordsByPage AS RecordByPage
	FROM
	(
	SELECT
		ROW_NUMBER() OVER(PARTITION BY AP.IdAceptacionPedido ORDER BY AP.IdAceptacionPedido DESC) AS R, 
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
             WHEN APC.IdAceptacionCartaPCN IS NOT NULL THEN 'SI'
             ELSE 'No'
         END AS PedirCarta,
		 ISNULL(SOT.Objeto,SP.MotivoUrgencia) AS Justificacion,
		 (ROW_NUMBER() OVER(ORDER BY AP.Creado DESC) - 1)/ @RecordsByPage AS _Page,
		 Contrato = c.NumeroContrato
    FROM MM_AceptacionPedido AS AP
        INNER JOIN MM_Pedido AS MP
            ON MP.IdPedido = AP.IdPedido
  left JOIN DG_Domicilio AS LE
            ON LE.IdDomicilio = AP.IdDomicilioEntrega
        left JOIN DG_TipoDomicilio AS TD
            ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
        LEFT JOIN PV_PaisRepublica AS PAIS
            ON PAIS.id = LE.IdPais
        INNER JOIN S_Proveedor AS P
            ON P.IdProveedor = MP.IdSubcontratista
        INNER JOIN MM_Pedidos AS PG
            ON MP.IdPedido = PG.IdIdentificador
               AND PG.IdProveedorCliente = @IdProveedor
        LEFT JOIN RelacionCartaCNPedido RC
            ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
        LEFT JOIN dbo.MM_TipoPedido AS TP
            ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.MM_AceptacionFactura AS AF
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN dbo.TA_Operacion AS OP
			ON OP.IdDocumento = AF.IdAceptacionFactura
				AND OP.IdTipoOperacion = 10
		LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS
			ON OTS.IdPedido = MP.IdPedido
		LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT
			ON SOT.IdOTSolicitud = OTS.IdOTSolicitud
		LEFT JOIN dbo.MM_SolicitudPedido AS SP
			ON SP.IdSolicitudPedido = MP.IdSolicitudPedido
		LEFT JOIN dbo.MM_AceptacionCartaPCN APC
			ON APC.IdAceptacionPedido = AP.IdAceptacionPedido AND APC.IdEstatus = 2
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	SP.IdContrato	=	C.IdContrato 
    WHERE AP.IdProveedor = @IdProveedor	
		AND (OP.IdEstatusOperacion = 1 OR OP.IdEstatusOperacion IS NULL)
		AND (
			CAST(AP.IdAceptacionPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
			--AP.Comentario LIKE '%' + @Buscar + '%' OR
			CAST(MP.IdSolicitudPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
			CAST(PG.IdPedido AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
			SOT.Objeto LIKE '%' + @Buscar + '%'OR
			SP.MotivoUrgencia LIKE '%' + @Buscar + '%' 
			)
        AND ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS 
		--AND APC.IdAceptacionPedido IS NULL      
    GROUP BY AP.IdAceptacionPedido,
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
             ),
             CONCAT(P.RazonSocial, ' ', P.RegimenCapital),
             CASE
             WHEN ISNULL(RC.PedirCarta, 0) = 1 THEN
             'SI'
             ELSE
             'No'
             END,
             AP.IdAceptacionPedido,
             AP.IdPedido,
             AP.Comentario,
             AP.Creado,
             TD.TipoDomicilio,
             PG.IdPedido,
             TP.TipoPedido,
             MP.IdSolicitudPedido,
			 SOT.Objeto,
			 SP.MotivoUrgencia,
			 c.IdContrato,
			 c.NumeroContrato,
			 APC.IdAceptacionCartaPCN
	--ORDER BY AP.Creado DESC
	) AS R
	WHERE
			R.R = 1 AND 
			R._Page = (@Page - 1)
	ORDER BY R.Creado DESC;

END
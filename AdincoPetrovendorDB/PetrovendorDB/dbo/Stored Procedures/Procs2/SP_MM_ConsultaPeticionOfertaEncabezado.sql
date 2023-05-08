-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 02-05-17
-- Description:	Consultar Detalle de La Oferta Cabecera 
-- Author:		Daniel AC
-- Create date: 12-10-17
-- Description: Actualización de proveedor 
-- Author:		Alexander Gomez
-- Create date: 18-02-2019
-- Description: Se elimino de la consulta el regimen capital (ya no se usa)
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaPeticionOfertaEncabezado]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT, @IdProveedor INT, @IdContrato INT = NULL, @IdUsuario INT = NULL, @FechaRegistro DATETIME = NULL
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		DECLARE @EXISTE_PEDIDO_BIT BIT = 0
		DECLARE @EXISTE_FLUJOAPROBACION NVARCHAR(300)
		DECLARE @PROVEEDOR_ID_SOLPED INT
		DECLARE @EXISTE_PEDIDO INT =
					(	SELECT	COUNT ( IdPedido )
						FROM	MM_Pedido
						WHERE	IdSolicitudPedido = @IdSolicitudPedido )
	DECLARE @PROVEEDORES_DOCUMENTOS_REPSE TABLE(
		RFC_PROVEEDOR VARCHAR(100)
	);

	--TIPO DE DOCUMENTO QUE LA OPERADORA QUIERE POR DEFAULT Y EL RFC DE LA OPERADORA
	INSERT INTO @PROVEEDORES_DOCUMENTOS_REPSE(RFC_PROVEEDOR) VALUES ('DDM0906096A6');
	INSERT INTO @PROVEEDORES_DOCUMENTOS_REPSE(RFC_PROVEEDOR) VALUES ('OBT1708213V6');


		IF @EXISTE_PEDIDO > 0 SET @EXISTE_PEDIDO_BIT = 1

		---- Consultar la información de Cabecera de la Oferta ---- 
		SET @PROVEEDOR_ID_SOLPED =
			(	SELECT	[IdProveedor]
				FROM	[dbo].[MM_SolicitudPedido]
				WHERE	IdSolicitudPedido = @IdSolicitudPedido )
		SET @EXISTE_FLUJOAPROBACION =
			(	SELECT CASE	 WHEN COUNT ( [IdFlujoTarea] ) > 0 THEN 'EXISTE' ELSE 'NO_EXISTE' END
				FROM	[dbo].[TA_FlujoTarea]
				WHERE
						[IdTipoOperacion] = 7
						AND [Activo] = 1
						AND
							(	[Eliminado] IS NULL
								OR	[Eliminado] = 0 )
						--AND [Predeterminado] = 1
						AND [IdProveedor] = @PROVEEDOR_ID_SOLPED )

		---exec   spGraficaDatos @ID_Grafica, @Fecha_Inicio, @Fecha_Fin,@datos output
		SELECT		TAO.IdOperacion, TAO.FechaRegistro, TAO.IdEstatusOperacion, TAO.Descripcion, TE.Nombre ,
					SP.AdjudicableParcialmente, SP.VisitaRequerida, SP.JuntaAclaracionesRequerida ,
					SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida ,
					TSP.TipoSolicitudPedido, P.Nombre, SP.EntregasParciales, @EXISTE_PEDIDO_BIT, TAO.FechaModificacion ,
					DATEADD ( DAY, V.DiaVencimiento, TAO.FechaRegistro ) AS FechaLimite ,
					PR.RazonSocial AS Proveedor, PR.Municipio + ' ' + PR.Entidad AS Lugar ,
					ISNULL ( TAO.FechaFinalizacion, GETDATE ()), @EXISTE_FLUJOAPROBACION AS ExisteFlujoAprobacion ,
					ISNULL ( DFO.IdDocFianza, 0 ) AS IdFianza, ISNULL ( DBO.IdDocBases, 0 ) AS IdBases, 
					CASE WHEN sp.EntregasParciales = 1 THEN 
					SP.FechaEntregaFinRequerida ELSE sp.FechaEntregaRequerida end,
					CAST((CASE	
						WHEN PDR.RFC_PROVEEDOR IS NOT NULL THEN 1
						ELSE 0
					END) AS BIT)  AS MostrarOpcionesREPSE
		FROM		MM_SolicitudPedido AS SP
		INNER JOIN	TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		INNER JOIN	TA_Estatus AS TE
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		INNER JOIN	MM_TipoSolicitudPedido AS TSP
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		INNER JOIN	TA_Prioridad AS P
			ON P.IdPrioridad = TAO.IdPrioridad
		INNER JOIN	TA_Vencimiento AS V
			ON V.IdVencimiento = TAO.IdVigencia
		INNER JOIN	S_Proveedor AS PR
			ON PR.IdProveedor = SP.IdProveedor
		LEFT JOIN	TA_DocFianzaOperacion AS DFO
			ON DFO.IdOperacion = TAO.IdOperacion
			   AND	DFO.Activo = 1
		LEFT JOIN	dbo.TA_DocBasesOperacion AS DBO
			ON DBO.IdOperacion = TAO.IdOperacion
			   AND	DBO.Activo = 1
		LEFT JOIN S_Proveedor AS OPE
			ON SP.IdProveedor = OPE.IdProveedor
		LEFT JOIN @PROVEEDORES_DOCUMENTOS_REPSE AS PDR
			ON PDR.RFC_PROVEEDOR = OPE.RFC
		WHERE
					SP.IdSolicitudPedido = @IdSolicitudPedido
					AND IdTipoOperacion = 6
					AND TAO.IdProveedor = @IdProveedor

	--- Nota -----
	--- IdTipoOereacion = 6 --- > PeticionOferta
	END
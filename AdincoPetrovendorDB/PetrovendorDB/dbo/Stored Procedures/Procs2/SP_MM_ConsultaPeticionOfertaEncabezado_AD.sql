USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPeticionOfertaEncabezado_AD]    Script Date: 10/03/2022 07:13:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	se obtiene la justificacion
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 11-05-2018
-- Description:	Consultar Detalle de La Oferta Cabecera y detalle del anexo de ad s3
-- =============================================

ALTER PROCEDURE [dbo].[SP_MM_ConsultaPeticionOfertaEncabezado_AD]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT, @IdProveedor INT, @IdContrato INT, @IdUsuario INT, @FechaRegistro DATETIME
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		DECLARE @EXISTE_PEDIDO_BIT BIT = 0
		DECLARE @EXISTE_FLUJOAPROBACION NVARCHAR(300)
		DECLARE @PROVEEDOR_ID_SOLPED INT
		DECLARE @Justificacion NVARCHAR(MAX), @IdPeticionOferta INT, @ExisteDocumento BIT
		DECLARE @EXISTE_PEDIDO INT =
					(	SELECT	COUNT ( IdPedido )
						FROM	MM_Pedido
						WHERE	IdSolicitudPedido = @IdSolicitudPedido );
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
		SELECT	@Justificacion = JustificacionAdjDirecta, @IdPeticionOferta = IdPeticionOferta
		FROM	dbo.MM_PeticionOferta
		WHERE
				IdSolicitudPedido = @IdSolicitudPedido
				AND IdTipoProceso = 4

		--Adjudicacion directa

		/*MOD S3 EXISTE DOCUMENTO ANEXO AD*/
		SELECT		@ExisteDocumento = CASE WHEN COUNT ( DPO.IdDocumento ) > 0 THEN 1 ELSE 0 END
		FROM		dbo.MM_PeticionOfertaADAdjunto DPO
		INNER JOIN	dbo.MM_SolicitudPedido SP
			ON DPO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE
					SP.IdSolicitudPedido = @IdSolicitudPedido
					AND SP.IdTipoProceso = 4	--Adjudicacion directa

		SELECT		TAO.IdOperacion, TAO.FechaRegistro, TAO.IdEstatusOperacion, TAO.Descripcion, TE.Nombre ,
					SP.AdjudicableParcialmente, SP.VisitaRequerida, SP.JuntaAclaracionesRequerida ,
					SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida ,
					TSP.TipoSolicitudPedido, P.Nombre, SP.EntregasParciales, @EXISTE_PEDIDO_BIT, TAO.FechaModificacion ,
					DATEADD ( DAY, V.DiaVencimiento, TAO.FechaRegistro ) AS FechaLimite ,
					( PR.RazonSocial + ' ' + PR.RegimenCapital ) AS Proveedor, PR.Municipio + ' ' + PR.Entidad AS Lugar ,
					ISNULL ( TAO.FechaFinalizacion, GETDATE ()), @EXISTE_FLUJOAPROBACION AS ExisteFlujoAprobacion ,
					ISNULL ( DFO.IdDocFianza, 0 ) AS IdFianza, ISNULL ( DBO.IdDocBases, 0 ) AS IdBases, @Justificacion ,
					@IdPeticionOferta , @ExisteDocumento,
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
	END
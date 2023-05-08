-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/02/2023
-- Description:	Guardado de solicitudes de descarga para aceptaciones de pedido de soportes
-- =============================================
-- Author:		Luis David
-- Create date: 01/03/2023
-- Description:	Se envía parámetro de tipo de aprobación a descargar
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_RPT_GuardadoSolicitudesDescargasAceptacionSoportes]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATE,
	@FechaFin DATE,
	@IdUsuario INT,
	@Tipo varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VALIDACION NVARCHAR(50);
	DECLARE @ID_SOLICITUD INT = 0;
	DECLARE @CANT_REGISTROS INT = 0;
	DECLARE @DESCARGAR TABLE (
		[Tipo] [nvarchar](50) NULL,
		[FechaInicio] [date] NULL,
		[FechaFin] [date] NULL,
		[IdContrato] [int] NULL
	);
	IF @Tipo = 'ACEPTACION'
	BEGIN
	INSERT INTO @DESCARGAR(
		[Tipo],
		[FechaInicio],
		[FechaFin],
		[IdContrato]
	)
	SELECT
		@Tipo,
		@FechaInicio,
		@FechaFin,
		P.IdContrato
	FROM MM_AceptacionPedido AS AP (NOLOCK)
		JOIN MM_Pedido AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
			AND P.IdContrato IN (10045,10044,10046,10038,10144)
			AND AP.Creado BETWEEN @FechaInicio AND @FechaFin
			AND AP.Activo = 1
			AND ISNULL(AP.IdEliminado,0) = 0
	GROUP BY P.IdContrato;
	END
	IF @Tipo = 'PEDIDO'
	BEGIN
	INSERT INTO @DESCARGAR(
		[Tipo],
		[FechaInicio],
		[FechaFin],
		[IdContrato]
	)
	SELECT
		@Tipo,
		@FechaInicio,
		@FechaFin,
		P.IdContrato
	FROM MM_Pedido AS P (NOLOCK)
	INNER JOIN mm_pedidos AS pg (nolock)
    ON         p.idpedido = pg.ididentificador
    AND        pg.idtipopedido IN ( 2,
                                   4,
                                   6 ) -->(Mer, AD, OT)
	INNER JOIN ta_operacion AS o (nolock)
    ON         p.idsolicitudpedido = o.iddocumento
			where P.IdContrato IN (10045,10044,10046,10038,10144)
			AND (p.fechaenviopedido >= @FechaInicio and p.fechaenviopedido <= @FechaFin)
			AND Isnull(p.idestatuseliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
			AND Isnull(p.cerrado, 0) = 0             --> PEDIDOS NO CERRADOS
			AND o.idtipooperacion = 9
			AND p.recepcionservicio = 1              --> RECEPCIÓN ACEPTADA
			AND o.idestatusoperacion = 2
	GROUP BY P.IdContrato
	END
	SET @CANT_REGISTROS = (SELECT COUNT(1) FROM @DESCARGAR);

	IF ISNULL(@CANT_REGISTROS,0) > 0
	BEGIN

		IF EXISTS (SELECT IdSolicitud
					FROM MM_SolicitudesDescargaProcesos 
					WHERE Tipo = @Tipo
					AND FechaInicio = @FechaInicio
					AND FechaFin = @FechaFin
					AND IdContrato IN (SELECT IdContrato FROM @DESCARGAR)
					AND ISNULL(Procesado,0) = 0)
		BEGIN

			SET @VALIDACION = 'DESCARGA_PENDIENTE_ACTIVA';

		END
		ELSE
		BEGIN

			INSERT INTO [MM_SolicitudesDescargaProcesos](
				[Tipo],
				[FechaInicio],
				[FechaFin],
				[IdContrato],
				IdUsuarioSolicitante,
				FechaRegistroSolicitud
			)
			SELECT
				[Tipo],
				[FechaInicio],
				[FechaFin],
				[IdContrato],
				@IdUsuario,
				GETDATE()
			FROM @DESCARGAR;

			SET @VALIDACION = 'GUARDADO_DESCARGA_PENDIENTE';

		END

	END
	ELSE
	BEGIN

		SET @VALIDACION = 'SIN_REGISTROS';

	END
	
	IF @VALIDACION = 'SIN_REGISTROS'
	BEGIN

		SELECT @VALIDACION

	END
	ELSE
	BEGIN

		SELECT 
			@VALIDACION,
			IdSolicitud,
			Tipo,
			FechaInicio,
			FechaFin,
			IdContrato,
			IdUsuarioSolicitante,
			FechaRegistroSolicitud
		FROM MM_SolicitudesDescargaProcesos 
		WHERE Tipo = @Tipo
			AND FechaInicio = @FechaInicio
			AND FechaFin = @FechaFin
			AND IdContrato IN (SELECT IdContrato FROM @DESCARGAR)
			AND ISNULL(Procesado,0) = 0
		GROUP BY IdSolicitud,
				Tipo,
				FechaInicio,
				FechaFin,
				IdContrato,
				IdUsuarioSolicitante,
				FechaRegistroSolicitud;

	END
END
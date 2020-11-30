-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <19/12/19>
-- Description:	<Consulta y actualiza el estatus de las notificaciones dependiendo el tipo>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarEstatusNotificaciones]
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Operacion TABLE (IdOperacion INT,IdTabla INT,IdTipo INT)

	INSERT INTO @Operacion
	( IdOperacion,IdTabla,IdTipo )
	SELECT
	N.IdOperacion,
	N.IdTabla,
	N.IdTipoNotificacion 
	FROM dbo.Notificacion N
	WHERE N.IdProveedor = @IdProveedor
	--AND N.IdTipoNotificacion <> 8 -- aprobacion carta CN/ no tiene ta_operacion
	AND N.Activo = 1

	
	-- APROBACIONES

	-- requisición
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 4 -- aprobación de requisición
	AND 
	IdTabla IN
	(
		SELECT 
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 4 
	)

	-- pedido
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 6 -- aprobación de pedido
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 6 
	)

	-- factura
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 5 -- aprobación de factura
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 5 
	)

	-- pedimento comprobante
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 9 -- aprobación de comprobante
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 9 
	)

	-- compra directa
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 7 -- aprobación de compra directa
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 7 
	)

	-- factura sin flujo
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 1 -- factura sin flujo de aprobación asignado
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion = 1 -- cambio de estatus "sin flujo" a pendiente
		AND N.IdTipo = 1 
	)

	-- comprobante sin flujo
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 2 -- comprobante sin flujo de aprobación asignado
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM dbo.TA_Operacion O
		INNER JOIN @Operacion N
			ON N.IdOperacion = O.IdOperacion
		WHERE O.IdEstatusOperacion = 1 -- cambio de estatus "sin flujo" a pendiente
		AND N.IdTipo = 2 
	)

	-- carta CN
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 8 -- aprobación carta CN
	AND 
	IdTabla IN
	(
		SELECT 
		AP.IdAceptacionPedido
		FROM dbo.MM_AceptacionCartaPCN AP
		INNER JOIN @Operacion N
			ON AP.IdAceptacionPedido = N.IdOperacion
		WHERE AP.IdEstatus <> 1 -- significa que cambio el estatus
		AND N.IdTipo = 8 
		GROUP BY AP.IdAceptacionPedido
	)

	SELECT 'success';
	
END

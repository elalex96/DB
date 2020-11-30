-- =============================================
-- Author:		<Jose Roman>
-- Create date: <15-08-2018>
-- Description:	<Funcion que consulta los flujos de aprobacion >
-- =============================================
create FUNCTION FN_FlujoSerialNoAprobados
( 
    @IdUsuario INT, 
    @IdProveedor INT,
	@IdTipoOperacion INT
) 
RETURNS @FlujosNoAprobados TABLE(IdOperacion INT) 
 
BEGIN 

	DECLARE @FlujoSerial TABLE(IdOperacion INT, NoSecuencia INT)

	--Se obtienen los flujos de tipo serial que el aprobador aun no ha aprobado
	INSERT INTO @FlujoSerial
	(
		IdOperacion, NoSecuencia
	)
	SELECT O.IdOperacion, t.NoSecuencia
	FROM dbo.TA_Operacion o
		INNER JOIN dbo.TA_FlujoTarea ft ON ft.IdFlujoTarea = o.IdFlujoTarea
		INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdOperacion = o.IdOperacion
		INNER JOIN dbo.TA_Tarea t ON t.IdTarea = tao.IdTarea
	WHERE t.IdAprobador = @IdUsuario 
		AND O.IdTipoOperacion = @IdTipoOperacion 
		AND O.IdProveedor = @IdProveedor 
		AND ISNULL(O.IdEstatusEliminado,0) <> 1  --> que no esten eliminadas
		AND ft.IdTipoFlujo = 1 -- solo aprobaciones de tipo serial
		AND t.NoSecuencia > 1  -- Donde el aprobador no sea el primer aprobador
		AND t.IdEstatus = 1    -- Y que no este aprobado

	-- de los flujos aun no aprobados se obtienen los que aun no cuenten con una aprobacion previa y por lo tanto seran excluidos de la consulta
	INSERT INTO @FlujosNoAprobados
	(
		IdOperacion
	)
	SELECT o.IdOperacion
	FROM dbo.TA_Operacion o
		INNER JOIN dbo.TA_FlujoTarea ft ON ft.IdFlujoTarea = o.IdFlujoTarea
		INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdOperacion = o.IdOperacion
		INNER JOIN dbo.TA_Tarea t ON t.IdTarea = tao.IdTarea
		INNER JOIN @FlujoSerial tb ON tb.IdOperacion = o.IdOperacion AND t.NoSecuencia = (tb.NoSecuencia - 1)
	WHERE t.IdAprobador <> @IdUsuario -- Se excluye el usuario aprobador actual
		AND t.IdEstatus <> 2 

    RETURN 
END
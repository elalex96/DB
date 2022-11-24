-- =============================================
-- Author:	Daniel AC
-- Create date: 03/08/2022
-- Description:	<Funcion que consulta las operaciones que son seriales y les toca aprobar al usuario actual >
-- =============================================
CREATE FUNCTION [dbo].[FN_FlujoSerialNoAprobados]
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
	FROM TA_Operacion o
		JOIN dbo.TA_FlujoTarea ft 
			ON o.IdFlujoTarea = ft.IdFlujoTarea  		
		JOIN dbo.TA_Tarea t 
			ON o.IdOperacion = t.IdOperacion 
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
		JOIN dbo.TA_FlujoTarea ft 
			ON o.IdFlujoTarea=ft.IdFlujoTarea 
		JOIN dbo.TA_Tarea t 
			ON O.IdOperacion  = t.IdOperacion 
			AND t.Activo = 1	-- Que esten activos
		JOIN @FlujoSerial tb 
			ON o.IdOperacion  = tb.IdOperacion 
			AND t.NoSecuencia = (tb.NoSecuencia - 1)
	WHERE t.IdAprobador <> @IdUsuario -- Se excluye el usuario aprobador actual
		AND t.IdEstatus <> 2 

    RETURN 
END

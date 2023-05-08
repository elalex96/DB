-- =============================================
-- Author: Pedro Acu�a
-- Create date: 04/05/2018
-- Description: ingresar la linea de tiempo que sera la que me indique cuantas versiones rechazos ah hecho el usuario y se va al historico
-- =============================================

CREATE PROCEDURE SP_MA_WSIngresarLineaTiempo @IdDocumento INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdLineaTiempoAnterior INT, @IdLineaTiempoNueva INT

		--obtener la ultima linea de la operacion 
		SELECT TOP 1
					@IdLineaTiempoAnterior = linea.IdLineaTiempo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		WHERE		linea.IdDocumento = @IdDocumento
		ORDER BY	linea.IdLineaTiempo DESC

		INSERT INTO Adinco.dbo.MA_LineaTiempo
			( IdDocumento, FechaCreacion )
		VALUES
			( @IdDocumento ,	-- IdOperacion - int
			  GETDATE ()		-- FechaCreacion - datetime
		)

		SELECT	@IdLineaTiempoNueva = @@IDENTITY

		SELECT	ISNULL(@IdLineaTiempoAnterior, 0) idLineaAnterior, @IdLineaTiempoNueva idLineaNueva
	END
--------------------------------------------------------------------------------------------------------------

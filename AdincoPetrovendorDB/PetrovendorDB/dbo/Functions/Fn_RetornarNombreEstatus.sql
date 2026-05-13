-- =============================================
-- Author: Pedro Acu�a
-- Create date: 18/06/2018
-- Description: retornar el nombre del estatus de Ta_Estatus
-- =============================================

CREATE FUNCTION Fn_RetornarNombreEstatus
	( @IdEstatus INT )
RETURNS NVARCHAR(100)
AS
	BEGIN
		DECLARE @NombreEstatus NVARCHAR(100)

		SELECT	@NombreEstatus = Nombre
		FROM	dbo.TA_Estatus
		WHERE	IdEstatus = @IdEstatus

		RETURN @NombreEstatus
	END
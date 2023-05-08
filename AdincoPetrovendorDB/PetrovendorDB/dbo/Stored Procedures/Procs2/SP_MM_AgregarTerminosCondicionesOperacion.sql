
CREATE PROCEDURE [dbo].[SP_MM_AgregarTerminosCondicionesOperacion]
	@IdOperacion INT,
	@IdTerminosCondiciones int
AS
BEGIN
	
	INSERT INTO dbo.TA_TerminosCondicionesOperacion
	(
	    IdOperacion,
	    IdTerminosYCondiciones,
		TerminosCondicionesTexto
	)
	VALUES
	(   @IdOperacion, -- IdOperacion - int
	    @IdTerminosCondiciones,  -- IdTerminosYCondiciones - int
		(SELECT TOP 1 Documento FROM dbo.TC_TerminosYCondicionesDocV2 WHERE IdTerminosYCondiciones = @IdTerminosCondiciones)
	);
END


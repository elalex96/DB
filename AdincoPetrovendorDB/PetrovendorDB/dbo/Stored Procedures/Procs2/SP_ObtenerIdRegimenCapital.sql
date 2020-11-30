CREATE PROCEDURE [dbo].[SP_ObtenerIdRegimenCapital](@RegimenCapital NVARCHAR(200))
AS
BEGIN
	DECLARE @IdRegimenCapital INT

	SELECT @IdRegimenCapital = IdRegimenCapital FROM dbo.RegimenCapital WHERE Regimen = @RegimenCapital

	--Sino encuentra el regimen capital entonces retorno no aplica
	IF(ISNULL(@IdRegimenCapital, 0) = 0)
	BEGIN
		SELECT @IdRegimenCapital = 5 --No aplica
	END	

	--Retorno el id del regimen capital
	SELECT @IdRegimenCapital
END	

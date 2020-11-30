-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <27-09-2019>
-- Description:	<recuperar el flujo filtrado por el centro de costo>
-- =============================================
CREATE PROCEDURE SP_ObtenerFlujoPorCentroCosto @IdCentroCosto INT
AS
BEGIN
	DECLARE @IdFlujoSeleccionado INT 
	DECLARE @IsActivoFlujo BIT 
	DECLARE @NombreCentroCosto NVARCHAR(MAX)

    SELECT @IdFlujoSeleccionado=rel.IdFlujo
    FROM dbo.CC_CentroCosto c
        LEFT JOIN dbo.RelacionCentroCostoFlujoAprob rel
            ON rel.IdCentroCosto = c.IdCentroCosto
    WHERE c.IsActivo = 1
          AND c.IdCentroCosto = @IdCentroCosto


	SELECT @NombreCentroCosto=CentroCosto 
	FROM dbo.CC_CentroCosto 
	WHERE IdCentroCosto=@IdCentrocosto
	
	SELECT @IsActivoFlujo=Activo 
	FROM dbo.TA_FlujoTarea 
	WHERE IdFlujoTarea=@IdFlujoSeleccionado


	SELECT @IdFlujoSeleccionado,ISNULL(@IsActivoFlujo,0),ISNULL(@NombreCentroCosto,'Centro de costo no encontrado')

END



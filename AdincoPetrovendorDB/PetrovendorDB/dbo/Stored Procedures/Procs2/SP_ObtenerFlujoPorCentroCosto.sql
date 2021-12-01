USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ObtenerFlujoPorCentroCosto]    Script Date: 26/11/2021 01:52:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <27-09-2019>
-- Description:	<recuperar el flujo filtrado por el centro de costo>
-- =============================================
ALTER PROCEDURE [dbo].[SP_ObtenerFlujoPorCentroCosto] @IdCentroCosto INT
AS
BEGIN
	DECLARE @IdFlujoSeleccionado INT 
	DECLARE @IsActivoFlujo BIT 
	DECLARE @NombreCentroCosto NVARCHAR(MAX)

    SELECT @IdFlujoSeleccionado=rel.IdFlujo
    FROM dbo.CC_CentroCosto c (NOLOCK)
        LEFT JOIN dbo.RelacionCentroCostoFlujoAprob rel
            ON rel.IdCentroCosto = c.IdCentroCosto
    WHERE c.IsActivo = 1
          AND c.IdCentroCosto = @IdCentroCosto


	SELECT @NombreCentroCosto=CentroCosto 
	FROM dbo.CC_CentroCosto (NOLOCK)
	WHERE IdCentroCosto=@IdCentrocosto
	
	SELECT @IsActivoFlujo=Activo 
	FROM dbo.TA_FlujoTarea (NOLOCK)
	WHERE IdFlujoTarea=@IdFlujoSeleccionado


	SELECT @IdFlujoSeleccionado,ISNULL(@IsActivoFlujo,0),ISNULL(@NombreCentroCosto,'Centro de costo no encontrado')

END



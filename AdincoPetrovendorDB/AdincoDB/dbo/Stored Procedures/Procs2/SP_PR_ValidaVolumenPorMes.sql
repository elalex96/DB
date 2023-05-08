-- =============================================
-- Author:		Manuel Cruz
-- Create date: 27-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_ValidaVolumenPorMes]
    -- Add the parameters for the stored procedure here
    @IdContrato INT,
    @IdUsuario INT,
    @MesReporte DATE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    IF EXISTS (   SELECT *
                    FROM dbo.PR_VolumenMensualProduccionPetroleo
                   WHERE IdContrato = @IdContrato
                     AND MesReporte = @MesReporte)
    BEGIN
        SELECT 'true' AS Existe,
               1 AS Editar;
    END;
    ELSE
    BEGIN
        SELECT 'false' AS Existe,
               0 AS Editar;
    END;
END;
-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se agrega el filtro aplicacion >
-- =============================================
-- =============================================
-- Author:		DAC
-- Modified date: <07/03/2023>
-- Description:	AGREGADO DE OPTIMIZACÓN
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarIdModulo]
    @aspx NVARCHAR(MAX),
    @Aplicacion INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT IdModulo
    FROM dbo.Modulo (NOLOCK)
    WHERE URL_MODULO = @aspx
          AND Aplicacion = @Aplicacion


END


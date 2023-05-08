-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidadesAdmin] 
	-- Add the parameters for the stored procedure here
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdUnidad, Unidad, UMB, IsActivo FROM dbo.PV_MM_MaterialUnidad WHERE IsEliminado = 0
END

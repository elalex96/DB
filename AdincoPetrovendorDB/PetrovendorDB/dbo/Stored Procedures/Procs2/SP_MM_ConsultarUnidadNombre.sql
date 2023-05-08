-- =============================================
-- Author:		<Alexander G>
-- Create date: <02/01/2018>
-- Description:	<Sp para consultar el IdUnidad del la unidad por el nombre de la misma>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidadNombre] 
	-- Add the parameters for the stored procedure here
	@NombreUnidad NVARCHAR(100),

	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP 1 IdUnidad FROM dbo.PV_MM_MaterialUnidad WHERE Unidad = @NombreUnidad
END

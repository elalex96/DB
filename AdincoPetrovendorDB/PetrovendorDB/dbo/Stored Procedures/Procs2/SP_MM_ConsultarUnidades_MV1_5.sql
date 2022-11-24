-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidades_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdUnidad INT,
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Unidad 
	FROM dbo.PV_MM_MaterialUnidad (NOLOCK)
	WHERE IdUnidad = @IdUnidad
END

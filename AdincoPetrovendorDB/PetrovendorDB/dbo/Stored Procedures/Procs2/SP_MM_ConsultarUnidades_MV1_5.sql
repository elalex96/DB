-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidades_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdUnidad INT,

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
	SELECT Unidad FROM dbo.PV_MM_MaterialUnidad WHERE IdUnidad = @IdUnidad
END

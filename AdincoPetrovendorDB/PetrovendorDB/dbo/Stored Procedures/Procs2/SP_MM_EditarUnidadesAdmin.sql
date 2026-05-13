-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_EditarUnidadesAdmin] 
	-- Add the parameters for the stored procedure here
	@IdUnidad INT,
	@Unidad NVARCHAR(MAX),
	@UMB NVARCHAR(MAX),
	@IsActivo BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.PV_MM_MaterialUnidad
	SET Unidad = @Unidad,
		UMB = @UMB,
		IsActivo = @IsActivo
	WHERE IdUnidad = @IdUnidad
END

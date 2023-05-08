-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarUnidadesAdmin] 
	-- Add the parameters for the stored procedure here
	@Unidad NVARCHAR(MAX),
	@UMB NVARCHAR(MAX),
	@IsActivo BIT,
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
	INSERT dbo.PV_MM_MaterialUnidad
	(
	    Unidad,
	    UMB,
	    IsActivo,
		IsEliminado
	)
	VALUES
	(   @Unidad,       -- Unidad - nvarchar(50)
	    @UMB,       -- UMB - nvarchar(50)
	    @IsActivo,
		0
	    )
END

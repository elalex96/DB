-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_AD_EditarAceptacionFactura
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@EstatusAprobacion NVARCHAR(MAX),
	@FechaCarga DATETIME,
	@FechaCargaPDF DATETIME,
	@IdAceptacionFactura INT,
	@Num INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdEstatus INT = (SELECT TOP 1 IdTipoValidacionDoc FROM dbo.S_TipoValidacionDoc WHERE TipoValidacion = @EstatusAprobacion)

    -- Insert statements for procedure here
	UPDATE dbo.MM_AceptacionFactura
	SET IdFactura = @IdFactura,
		IdEstatus = @IdEstatus,
		FechaCargaPDF = @FechaCargaPDF,
		FechaCargaXML = @FechaCargaPDF
	WHERE IdAceptacionFactura = @IdAceptacionFactura
END

-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12-09-2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_MPY_InsMaterialesPedidoImportado]
	-- Add the parameters for the stored procedure here
	@DescripcionCorta NVARCHAR(MAX), 
	@DescripcionLarga NVARCHAR(MAX), 
	@Unidad NVARCHAR(MAX), 
	@IDM NVARCHAR(MAX),
	@IdAceptacionPedidoDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MPY_MM_AceptacionPedidoDetalle
	SET DescripcionCorta = @DescripcionCorta,
		DescripcionLarga = @DescripcionLarga,
		Detalle = @DescripcionCorta,
		Unidad = @Unidad,
		SAPNumber = @IDM
	WHERE detalle = @IDM and
	isnull(detalle,'' ) <> ''
	

	SELECT 'SUCCESS'
END
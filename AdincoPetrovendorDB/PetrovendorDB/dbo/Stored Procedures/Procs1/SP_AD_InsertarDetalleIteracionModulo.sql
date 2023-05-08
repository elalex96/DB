
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_InsertarDetalleIteracionModulo] 
	-- Add the parameters for the stored procedure here
	@IdIteracion INT,
	@DescripcionLarga NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.RegistroIteracionesDetalle
	(
	    IdIteracion,
	    DescripcionLarga,
	    FechaRegistro,
	    IsEliminado
	)
	VALUES
	(   @IdIteracion,         -- IdIteracion - int
	    @DescripcionLarga,       -- DescripcionLarga - nvarchar(max)
	    GETDATE(), -- FechaRegistro - datetime
	    0       -- IsEliminado - bit
	    )
END


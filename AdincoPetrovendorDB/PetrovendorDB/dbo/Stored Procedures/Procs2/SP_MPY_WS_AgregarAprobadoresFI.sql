-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/07/2018
-- Description:	Insertar aprobadores de factura
-- =============================================
CREATE procedure [dbo].[SP_MPY_WS_AgregarAprobadoresFI]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@IdProveedor NVARCHAR(MAX),
	@Nombre NVARCHAR(MAX),
	@Correo NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.MPY_FI_Aprobadores
	(
	    IdAceptacionPedido,
	    IdProveedor,
	    Nombre,
	    Correo
	)
	VALUES
	(   @IdAceptacionPedido,        -- IdAceptacionPedido - int
	    @IdProveedor,      -- IdProveedor - nvarchar(20)
	    @Nombre,      -- Nombre - nvarchar(max)
	    @Correo
	    )
END

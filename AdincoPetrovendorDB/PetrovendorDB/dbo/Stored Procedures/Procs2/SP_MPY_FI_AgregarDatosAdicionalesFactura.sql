-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/11/2018
-- Description:	Agregar datos adicionales a la factura para Murphy
-- =============================================
CREATE procedure [dbo].[SP_MPY_FI_AgregarDatosAdicionalesFactura]
	-- Add the parameters for the stored procedure here
	@CuentaContable VARCHAR(50),
	@CuentaCSH VARCHAR(50),
	@IdAceptacionFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MPY_MM_AceptacionFactura
	SET CuentaContable = @CuentaContable,
		CuentaCSH = @CuentaCSH
	WHERE IdAceptacionFactura = @IdAceptacionFactura

	SELECT 'SUCCESS'
END

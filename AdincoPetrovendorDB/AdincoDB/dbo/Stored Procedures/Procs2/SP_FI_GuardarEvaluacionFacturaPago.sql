-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/05/2018
-- Description:	Insercion del estatus de pago de la factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_GuardarEvaluacionFacturaPago]
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@IdContrato INT,
	@IdUsuarioAprobador INT,
	@IdEstatus INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.FI_AprobacionFactura
	(
	    IdFactura,
	    IdContrato,
	    IdUsuarioAprobador,
	    IdEstatus
	)
	VALUES
	(   @IdFactura, -- IdFactura - int
	    @IdContrato, -- IdContrato - int
	    @IdUsuarioAprobador, -- IdUsuarioAprobador - int
	    @IdEstatus  -- IdEstatus - int
	    )

	SELECT @@IDENTITY
END

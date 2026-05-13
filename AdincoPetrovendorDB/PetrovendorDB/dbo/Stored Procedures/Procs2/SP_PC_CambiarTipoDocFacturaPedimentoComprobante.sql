-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	Registrar un nuevo pedimento comprobante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CambiarTipoDocFacturaPedimentoComprobante]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @CvTipoDocFacturacion INT,
	@IdPedimentoComprobante INT 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	UPDATE dbo.FI_PedimentoComprobante
	SET CvTipoDocFacturacion= @CvTipoDocFacturacion
	WHERE IdPedimentoComprobante=@IdPedimentoComprobante

	SELECT 'SUCCESS'
END;


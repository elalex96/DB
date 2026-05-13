-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Consultar comprobante
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultarComprobante]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdPedimentoComprobante INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT 
	PC.FolioComprobante,
	PC.FechaPago,
	PC.IdFormaPago,
	PC.IdMoneda,
	PC.CvTipoDocFacturacion,
	D.IdDocumento,
	D.NombreExtensionArchivo,	
	D.DocumentoByte
	FROM dbo.FI_PedimentoComprobante PC
	LEFT JOIN dbo.FI_Documento D ON D.IdPedimentoComprobante= PC.IdPedimentoComprobante
	WHERE PC.IdPedimentoComprobante=@IdPedimentoComprobante



END;

 
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 24-04-2018
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[SP_CO_EstadoRegistroPDFRefacturas]
	-- Add the parameters for the stored procedure here
@IdRegistro INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @TipoArchivo INT;
DECLARE @IdDoc INT;
DECLARE @IdFac INT;
--
SELECT @TipoArchivo = CvTipoDocFacturacion
FROM dbo.CO_Registro
WHERE IdRegistro = @IdRegistro;
--
--SELECT @TipoArchivo;
--
IF @TipoArchivo = 1
    BEGIN
        SELECT @IdDoc = IdFactura
        FROM dbo.CO_Registro
        WHERE IdRegistro = @IdRegistro;
	   --
	   Select @IdFac=idFacturaPadre From FI_RelacionRefacturas where idFacturaHijo=@IdDoc;

	   SELECT DocumentoByte,NombreExtensionArchivo FROM dbo.FI_Documento WHERE IdFactura = @IdFac
    END;
   
END
--SP_CO_EstadoRegistroPDF 7086

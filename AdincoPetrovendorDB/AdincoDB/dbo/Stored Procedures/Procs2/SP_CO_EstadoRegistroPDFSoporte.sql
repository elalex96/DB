-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/06/2018
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[SP_CO_EstadoRegistroPDFSoporte]
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
Declare @DocSup int;
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
	
	Select @DocSup= DocumentoSoporteId from FI_RelacionSoporteFactura where IdFactura=@IdDoc;

		select 
			DocumentoSoporteId,
			Bucket,
			Folder,
			UUIDAmazon,
			NombreArchivo,
			Meta,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl
		from FI_DocumentoSoporte doc
		where DocumentoSoporteId = @DocSup
	
    END;
    ELSE
    BEGIN
        SELECT @IdDoc = IdPedimentoComprobante
        FROM dbo.CO_Registro
        WHERE IdRegistro = @IdRegistro;
	   --
	
	Select @DocSup= DocumentoSoporteId from FI_RelacionSoporteFactura where IdPedimentoComprobante=@IdDoc;

		select 
			DocumentoSoporteId,
			Bucket,
			Folder,
			UUIDAmazon,
			NombreArchivo,
			Meta,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl
		from FI_DocumentoSoporte doc
		where DocumentoSoporteId = @DocSup
	
    END;
END
--SP_CO_EstadoRegistroPDF 7086

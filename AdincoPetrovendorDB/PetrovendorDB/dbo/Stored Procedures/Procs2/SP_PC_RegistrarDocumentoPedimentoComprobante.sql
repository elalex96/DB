-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Agregar o actualiza documento pdf de comprobante o pedimento 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_RegistrarDocumentoPedimentoComprobante]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdPedimentoComprobante INT,
    @DocumentoPDF IMAGE,
    @CvTipoDocFacturacion INT,
    @IdDocumento INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @FI_TipoDocumento INT = 0;
    DECLARE @NombreExtensionArchivo NVARCHAR(200) = 0;
    DECLARE @EXISTE_ARCHIVO INT = 0;

    IF @CvTipoDocFacturacion = 2 ----PEDIMENTO CTE EN UTL
    BEGIN
        SET @FI_TipoDocumento = 4; --Pedimento de Importacion FI_TipoDocumento ADINCO
        SET @NombreExtensionArchivo = CONCAT('PI_', @IdPedimentoComprobante, '.pdf');
    END;
    IF @CvTipoDocFacturacion = 3 ----COMPROBANTE CTE EN UTL
    BEGIN
        SET @FI_TipoDocumento = 5; --Comprobante Extranjero FI_TipoDocumento ADINCO
        SET @NombreExtensionArchivo = CONCAT('PE_', @IdPedimentoComprobante, '.pdf');
    END;

    SELECT @EXISTE_ARCHIVO = COUNT(IdDocumento)
    FROM dbo.FI_Documento
    WHERE IdPedimentoComprobante = @IdPedimentoComprobante;



    IF @EXISTE_ARCHIVO = 0
    BEGIN
        INSERT INTO [dbo].[FI_Documento]
        (
            [IdTipoDocumento],
            [IdPedimentoComprobante],
            [NombreExtensionArchivo],
            [IdUsuario],
            [FechaCarga],
            [IsEliminado],
            [DocumentoByte]
        )
        VALUES
        (@FI_TipoDocumento, @IdPedimentoComprobante, @NombreExtensionArchivo, @IdUsuario, GETDATE(), 0, @DocumentoPDF);
    END;
    ELSE
    BEGIN

        SELECT @IdDocumento = IdDocumento
        FROM dbo.FI_Documento
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        UPDATE dbo.FI_Documento
        SET [IdTipoDocumento] = @FI_TipoDocumento,
            [IdPedimentoComprobante] = @IdPedimentoComprobante,
            [NombreExtensionArchivo] = @NombreExtensionArchivo,
            [IdUsuario] = @IdUsuario,
            [FechaCarga] = GETDATE(),
            [IsEliminado] = 0,
            [DocumentoByte] = @DocumentoPDF
        WHERE IdDocumento = @IdDocumento;
    END;

    SELECT 'SUCESSS';

END;



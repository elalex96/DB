-- =============================================
-- Author:        Reyna Olvera
-- Create date: 27/06/2018
-- Description:    Guarda el archivo xml de la factura
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_InsertaArchivoXml]
    -- Add the parameters for the stored procedure here
    @ArchivoXml IMAGE,
    @Hash256 NVARCHAR(MAX),
    @IdOper INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
 
    SET NOCOUNT ON;
 
    DECLARE @facturas INT;
 
    SELECT @facturas = COUNT(IdFactura)
    FROM FI_ArchivoXml
    WHERE IdFactura = @IdOper;
 
    IF @facturas = 0
    BEGIN
        INSERT INTO FI_ArchivoXml
        (
            ArchivoXml,
            HashSHA256,
            IdFactura,
            IdContrato,
            CreadoPor,
            CreadoEl,
            Activo
        )
        VALUES
        (@ArchivoXml, @Hash256, @IdOper, @IdContrato, @IdUsuario, GETDATE(), 1);
 
        --Devuelve error o no
        IF @@ERROR <> 0
            SELECT 'false' AS msj;
        ELSE
            SELECT 'true' AS msj;
 
    END;
    ELSE
    BEGIN
 
        UPDATE FI_ArchivoXml
        SET ArchivoXml = @ArchivoXml,
            HashSHA256 = @Hash256,
            IdContrato = @IdContrato,
            ModificadoPor = @IdUsuario,
            ModificadoEl = GETDATE(),
            Activo = 1
        WHERE IdFactura = @IdOper;
 

        IF @@ERROR <> 0
            SELECT 'false' AS msj;
        ELSE
            SELECT 'true' AS msj;
 
    END;
 
END;